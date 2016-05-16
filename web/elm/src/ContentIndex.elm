module ContentIndex exposing (..)

import Debug
import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (attribute, class, classList, disabled, for, href, id, name, size, style, type')
import Html.Events exposing (..)
import Http
import Json.Decode exposing ((:=))
import Json.Decode as Json
import String
import Task exposing (..)


-- MODEL

type alias Config =
  { adminArea : Bool
  , contentBasePath : String
  }
type alias Model =
  { config : Config
  , contents : List Content
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

init : Config -> (Model, Cmd Msg)
init config =
  let
    actions = Cmd.batch
      [ fetchContents config.adminArea ""
      , fetchContentTypes
      ]
  in
    ( Model config [] [] "", actions )


-- UPDATE

type VoteDirection = Up | Down
type Msg
  = SetContents (List Content)
  | SetContentTypes (List ContentType)
  | UpdateFilter String
  | RequestVote Content VoteDirection
  | ReceivedVoteResult String
  | ToggleContentType ContentType
  | HandleError String

update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    SetContents contents -> ( { model | contents = contents }, Cmd.none )
    SetContentTypes contentTypes -> ( { model | contentTypes = contentTypes }, Cmd.none )

    UpdateFilter inputFilterStr ->
      let
        newModel = { model | filterStr = inputFilterStr }
      in
        ( newModel, fetchContents model.config.adminArea inputFilterStr )

    RequestVote content voteDirection ->
      ( model, sendVote content voteDirection )

    ReceivedVoteResult voteResult ->
      ( model, fetchContents model.config.adminArea model.filterStr )

    ToggleContentType contentType ->
      let
        updateContentType ct =
          if ct.id == contentType.id
            then { ct | active = not ct.active }
            else ct
        newModel = { model | contentTypes = List.map updateContentType model.contentTypes }
      in
        ( newModel, Cmd.none )

    HandleError string ->
      Debug.log string
      ( model, Cmd.none )

view : Model -> Html Msg
view model =
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
      [ viewFilter model
      , div [] (List.map (viewContent model.config.contentBasePath) visibleContents)
      ]

viewContent : String -> Content -> Html Msg
viewContent basePath content =
  let
    contentPath = basePath ++ toString(content.id)
  in
    div [ class "content" ]
      [ viewContentVoteComponent content
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

viewContentVoteComponent : Content -> Html Msg
viewContentVoteComponent content =
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
      , onClick (RequestVote content Up)
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
      , onClick (RequestVote content Down)
      , disabled buttonsDisabled.down
      ]
      [ span [ class "glyphicon glyphicon-arrow-down", attribute "aria-hidden" "true" ] [] ]
  in
    div [ class "content__vote" ]
      [ voteUpButton
      , voteScore
      , voteDownButton
      ]

viewContentType : String -> Html Msg
viewContentType contentType =
  span [ class ("content__type label label-default") ] [ text contentType ]

viewContentStatus : String -> Html Msg
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

viewContentOfficialAnswer : String -> Html Msg
viewContentOfficialAnswer officialAnswer =
  case String.isEmpty officialAnswer of
    True -> em [] [ text "No official answer yet." ]
    False ->
      div [ class "official-answer" ]
        [ span [ class "official-answer__header" ] [ text "Official answer:" ]
        , span [] [ text officialAnswer ]
        ]

viewFilter : Model -> Html Msg
viewFilter model =
  div [ class "filter-panel bs-callout" ]
    [ viewFilterText model
    , viewFilterContentTypes model
    ]

viewFilterText : Model -> Html Msg
viewFilterText model =
  form [ class "form-inline", id "filter-text" ]
    [ div [ class "form-group" ]
      [ label [ for "filter-input" ] [ text "Search for something" ]
      , input
        [ onInput UpdateFilter
        , type' "text"
        , class "form-control"
        , name "filter-text"
        , size 50
        ] []
      ]
    , a
      [ type' "submit", class "btn btn-default"
      , href ("/contents/new?label=" ++ model.filterStr)
      ]
      [ text "Create a new one" ]
    ]

viewFilterContentTypes : Model -> Html Msg
viewFilterContentTypes model =
  let
    pill contentType =
      li
        [ attribute "role" "presentation"
        , classList [ ("active", contentType.active) ]
        , onClick (ToggleContentType contentType)
        ]
        [ a [ href "#" ] [ text contentType.label ] ]
    pills = List.map pill model.contentTypes
  in
    ul [ class "nav nav-pills" ] pills


-- EFFECTS

handleHttpError : Http.Error -> Msg
handleHttpError err =
  let
    errorMessage = case err of
      Http.Timeout -> "Timeout"
      Http.NetworkError -> "NetworkError"
      Http.UnexpectedPayload message -> "UnexpectedPayload " ++ message
      Http.BadResponse code message -> "BadResponse " ++ (toString code) ++ " " ++ message
  in
    HandleError errorMessage

fetchContentTypes : Cmd Msg
fetchContentTypes =
  Http.get decodeContentTypes "/api/content_types"
    |> Task.perform handleHttpError (\contentTypes -> SetContentTypes contentTypes)

decodeContentTypes : Json.Decoder (List ContentType)
decodeContentTypes =
  let
    contentType = Json.object2
      (\id label -> (ContentType id label True))
      ("id" := Json.int)
      ("label" := Json.string)
  in
    Json.at ["data"] (Json.list contentType)

fetchContents : Bool -> String -> Cmd Msg
fetchContents adminArea filterStr =
  let
    includeHidden = case adminArea of
      True -> "true"
      False -> "false"
    url = Http.url "/api/contents" [ ("filter", filterStr), ("include_hidden", includeHidden) ]
  in
    Http.get decodeContents url
      |> Task.perform handleHttpError (\contents -> SetContents contents)

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

sendVote : Content -> VoteDirection -> Cmd Msg
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
      |> Task.perform handleHttpError (\voteResult -> ReceivedVoteResult voteResult)


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

main : Program Config
main =
  Html.programWithFlags
    { init = init
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
    }
