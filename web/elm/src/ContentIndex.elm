module ContentIndex where

import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (class, classList, disabled, for, href, key, id, style, type')
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
  , filter : String
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

init : (Model, Effects Action)
init =
  ( Model [] "", fetchContents "" )


-- UPDATE

type VoteDirection = Up | Down
type Action
  = SetContents (Maybe (List Content))
  | UpdateFilter String
  | RequestVote Content VoteDirection
  | ReceivedVoteResult (Maybe String)

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    SetContents contents ->
      let
        newContents = Maybe.withDefault model.contents contents
        newModel = { model | contents = newContents }
      in
        ( newModel, Effects.none )

    UpdateFilter filterStr ->
      let
        newModel = { model | filter = filterStr }
      in
        ( newModel, fetchContents filterStr )

    RequestVote content voteDirection ->
      ( model, sendVote content voteDirection )

    ReceivedVoteResult maybeVoteResult ->
      case maybeVoteResult of
        Just "ok" ->
          ( model, fetchContents model.filter )
        _ ->
          ( model, Effects.none )

view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ div [ class "bs-callout" ] [ viewSearchForm address model ]
    , div [] (List.map (viewContent address) model.contents)
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
      [ text "⬆" ]
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
      [ text "⬇" ]
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

viewSearchForm : Signal.Address Action -> Model -> Html
viewSearchForm address model =
  form [ class "form-inline" ]
    [ div [ class "form-group" ]
      [ label [ for "filterInput" ] [ text "Search for something" ]
      , input
        [ on "input" targetValue (\str -> Signal.message address (UpdateFilter str))
        , type' "text"
        , class "form-control"
        , id "filterInput"
        ] []
      ]
    , a
      [ type' "submit", class "btn btn-default"
      , href ("/contents/new?label=" ++ model.filter)
      ]
      [ text "Create a new one" ]
  ]


-- EFFECTS

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
