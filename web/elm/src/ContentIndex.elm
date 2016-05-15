module ContentIndex where

import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, disabled, for, href, key, id, size, style, type')
import Html.Events exposing (..)
import Http
import Json.Decode exposing ((:=))
import Json.Decode as Json
import String
import StartApp
import Task

port adminArea : Bool
port contentBasePath : String


-- MODEL

type alias Model =
  { contents : List Content
  , contentTypes : List ContentType
  , filterStr : String
  }
type alias Vote =
  { id : Int
  , voteType : String
  }
type alias Content =
  { id : Int
  , label : String
  , description : String
  , officialAnswer: String
  , status : String
  , contentType : String
  , voteScore : Int
  , voteForCurrentUser : Maybe Vote
  }
type alias ContentType =
  { id : Int
  , label : String
  , active : Bool
  }

init : (Model, Effects Action)
init =
  let
    actions = Effects.batch
      [ fetchContents ""
      , fetchContentTypes
      ]
  in
    ( Model [] [] "", actions )


-- UPDATE

type VoteDirection = Up | Down
type Action
  = SetContents (Maybe (List Content))
  | SetContentTypes (Maybe (List ContentType))
  | UpdateFilter String
  | RequestVote Content VoteDirection
  | ReceivedVoteResult (Maybe String)
  | ToggleContentType ContentType

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    SetContents contents ->
      let
        newContents = Maybe.withDefault model.contents contents
        newModel = { model | contents = newContents }
      in
        ( newModel, Effects.none )

    SetContentTypes contentTypes ->
      let
        newContentTypes = Maybe.withDefault model.contentTypes contentTypes
        newModel = { model | contentTypes = newContentTypes }
      in
        ( newModel, Effects.none )

    UpdateFilter inputFilterStr ->
      let
        newModel = { model | filterStr = inputFilterStr }
      in
        ( newModel, fetchContents inputFilterStr )

    RequestVote content voteDirection ->
      ( model, sendVote content voteDirection )

    ReceivedVoteResult maybeVoteResult ->
      case maybeVoteResult of
        Just "ok" ->
          ( model, fetchContents model.filterStr )
        _ ->
          ( model, Effects.none )

    ToggleContentType contentType ->
      let
        updateContentType ct =
          if ct.id == contentType.id
            then { ct | active = not ct.active }
            else ct
        newModel = { model | contentTypes = List.map updateContentType model.contentTypes }
      in
        ( newModel, Effects.none )

view : Signal.Address Action -> Model -> Html
view address model =
  let
    withActiveContentType content =
      let contentType = List.filter (\ct -> ct.label == content.contentType) model.contentTypes |> List.head
      in
        case contentType of
          Just matchingContentType -> matchingContentType.active
          Nothing -> True
    visibleContents = List.filter withActiveContentType model.contents
  in
    div []
      [ viewFilter address model
      , div [] (List.map (viewContent address) visibleContents)
      ]

viewContent : Signal.Address Action -> Content -> Html
viewContent address content =
  let
    contentPath = contentBasePath ++ toString(content.id)
  in
    div [ class "content" ]
      [ viewContentVoteComponent address content
      , node "area" [ class "panel panel-default", href contentPath ]
        [ div [ class "panel-heading" ]
          [ h3 [ class "panel-title" ] [ text content.label ]
          , viewContentType content.contentType
          , viewContentStatus content.status
          ]
        , div [ class "panel-body" ]
          [ div [] [ text content.description ] ]
        , div [ class "panel-footer" ]
          [ viewContentOfficialAnswer content.officialAnswer
          ]
        ]
      ]

viewContentVoteComponent : Signal.Address Action -> Content -> Html
viewContentVoteComponent address content =
  let
    buttonsDisabled = case content.voteForCurrentUser of
      Nothing -> { up = False, down = False }
      Just vote -> case vote.voteType of
        "for" -> { up = True, down = False }
        "against" -> { up = False, down = True }
        _ -> { up = False, down = False }
    voteUpButton = span
      [ classList
        [ ("disabled", buttonsDisabled.up)
        , ("btn btn-default content__vote__button", True)
        ]
      , onClick address (RequestVote content Up)
      ]
      [ span [ class "glyphicon glyphicon-arrow-up", attribute "aria-hidden" "true" ] [] ]
    voteScore = span
      [ class "content__vote__score" ]
      [ text (toString content.voteScore) ]
    voteDownButton = span
      [ classList
        [ ("disabled", buttonsDisabled.down)
        , ("btn btn-default content__vote__button", True)
        ]
      , onClick address (RequestVote content Down)
      , disabled buttonsDisabled.down
      ]
      [ span [ class "glyphicon glyphicon-arrow-down", attribute "aria-hidden" "true" ] [] ]
  in
    div [ class "content__vote" ]
      [ voteUpButton
      , voteScore
      , voteDownButton
      ]

viewContentType : String -> Html
viewContentType contentType =
  span [ class ("content__type label label-default") ] [ text contentType ]

viewContentStatus : String -> Html
viewContentStatus status =
  let
    labelColor = case status of
      "new" -> "label-danger"
      "in_progress" -> "label-warning"
      "solved" -> "label-success"
      _ -> "label-default"
    statusText = case status of
      "new" -> "new"
      "in_progress" -> "in progress"
      "solved" -> "solved"
      _ -> ""
  in
    span [ class ("content__status label " ++ labelColor) ] [ text statusText ]

viewContentOfficialAnswer : String -> Html
viewContentOfficialAnswer officialAnswer =
  case String.isEmpty officialAnswer of
    True -> em [] [ text "No official answer yet." ]
    False ->
      div [ class "official-answer" ]
        [ span [ class "official-answer__header" ] [ text "Official answer:" ]
        , span [] [ text officialAnswer ]
        ]

viewFilter : Signal.Address Action -> Model -> Html
viewFilter address model =
  div [ class "filter-panel bs-callout" ]
    [ viewFilterText address model
    , viewFilterContentTypes address model
    ]

viewFilterText : Signal.Address Action -> Model -> Html
viewFilterText address model =
  form [ class "form-inline" ]
    [ div [ class "form-group" ]
      [ label [ for "filterInput" ] [ text "Search for something" ]
      , input
        [ on "input" targetValue (\str -> Signal.message address (UpdateFilter str))
        , type' "text"
        , class "form-control"
        , id "filterInput"
        , size 50
        ] []
      ]
    , a
      [ type' "submit", class "btn btn-default"
      , href ("/contents/new?label=" ++ model.filterStr)
      ]
      [ text "Create a new one" ]
    ]

viewFilterContentTypes : Signal.Address Action -> Model -> Html
viewFilterContentTypes address model =
  let
    pill contentType =
      li
        [ attribute "role" "presentation"
        , classList [ ("active", contentType.active) ]
        , onClick address (ToggleContentType contentType)
        ]
        [ a [ href "#" ] [ text contentType.label ] ]
    pills = List.map pill model.contentTypes
  in
    ul [ class "nav nav-pills" ] pills


-- EFFECTS

fetchContentTypes : Effects Action
fetchContentTypes =
  let
    url = Http.url "/api/content_types" []
  in
    Http.get decodeContentTypes url
      |> Task.toMaybe
      |> Task.map SetContentTypes
      |> Effects.task

decodeContentTypes : Json.Decoder (List ContentType)
decodeContentTypes =
  let
    contentType = Json.object2
      (\id label -> (ContentType id label True))
      ("id" := Json.int)
      ("label" := Json.string)
  in
    Json.at ["data"] (Json.list contentType)

fetchContents : String -> Effects Action
fetchContents filterStr =
  let
    includeHidden = case adminArea of
      True -> "true"
      False -> "false"
    url = Http.url "/api/contents" [ ("filter", filterStr), ("include_hidden", includeHidden) ]
  in
    Http.get decodeContents url
      |> Task.toMaybe
      |> Task.map SetContents
      |> Effects.task

decodeContents : Json.Decoder (List Content)
decodeContents =
  let
    content =
      Json.object8
        (\id label desc oAnswer status cType voteScore voted -> (Content id label desc oAnswer status cType voteScore voted))
        ("id" := Json.int)
        ("label" := Json.string)
        ("description" := Json.string)
        ("officialAnswer" := Json.string)
        ("status" := Json.string)
        ("type" := Json.string)
        ("voteScore" := Json.int)
        (Json.maybe ("voteForCurrentUser" := decodeVote))
  in
    Json.at ["data"] (Json.list content)

decodeVote : Json.Decoder (Vote)
decodeVote =
  Json.object2 (\id voteType -> (Vote id voteType))
    ("id" := Json.int)
    ("voteType" := Json.string)

sendVote : Content -> VoteDirection -> Effects Action
sendVote content voteDirection =
  let
    maybeVote = content.voteForCurrentUser
    contentId = toString(content.id)
    votePath = case maybeVote of
      Nothing -> "/api/contents/" ++ contentId ++ "/votes"
      Just vote -> "/api/contents/" ++ contentId ++ "/votes/" ++ toString(vote.id)
    updateParams = case maybeVote of
      Nothing -> []
      Just vote -> [("id", toString(vote.id))]
    params =
      [ ("vote[vote_type]", (voteType maybeVote voteDirection))
      , ("content_id", contentId)
      ] ++ updateParams
    verb = case maybeVote of
      Nothing -> "POST"
      Just _ -> "PUT"
    request =
      { verb = verb
      , headers = []
      , url = Http.url votePath params
      , body = Http.empty
      }
  in
    Http.fromJson decodeVoteResult (Http.send Http.defaultSettings request)
      |> Task.toMaybe
      |> Task.map ReceivedVoteResult
      |> Effects.task

voteType : Maybe Vote -> VoteDirection -> String
voteType maybeVote direction =
  case (maybeVote, direction) of
    (Nothing, Up) -> "for"
    (Nothing, Down) -> "against"
    (Just vote, _) ->
      case (vote.voteType, direction) of
        ("for", Up) -> "for"
        ("for", Down) -> "neutral"
        ("neutral", Up) -> "for"
        ("neutral", Down) -> "against"
        ("against", Up) -> "neutral"
        ("against", Down) -> "against"
        (_, _) -> "neutral"

decodeVoteResult : Json.Decoder String
decodeVoteResult =
  Json.at ["status"] Json.string


-- APP

app : StartApp.App Model
app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }

main : Signal Html
main = app.html

port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks
