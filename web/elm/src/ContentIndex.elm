module ContentIndex where

import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (class, for, href, key, id, style, type')
import Html.Events exposing (..)
import Http
import Json.Decode exposing ((:=))
import Json.Decode as Json
import String
import StartApp
import Task

-- MODEL

type alias Model =
  { contents : List Content
  , filter : String
  }
type alias Content =
  { id : Int
  , label : String
  , description : String
  , officialAnswer: String
  , status : String
  , contentType : String
  , voteScore : Int
  , voteForCurrentUser : Maybe String
  }

init : (Model, Effects Action)
init =
  ( Model [] "", fetchContents "" )


-- UPDATE

type VoteType = Up | Down
type Action
  = SetContents (Maybe (List Content))
  | UpdateFilter String
  | RequestVote Content VoteType
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

    RequestVote content voteType ->
      ( model, sendVote content voteType )

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
  div [ class "view-content" ]
    [ viewContentVoteComponent address content
    -- , span [ href ("/contents/" ++ (toString content.id)), key (toString content.id) ]
    , div [ class "panel panel-default" ]
      [ div [ class "panel-heading" ]
        [ h3 [ class "panel-title" ] [ text content.label ]
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
    voteUpButton = a
      [ class "btn btn-default view-content__vote__button"
      , onClick address (RequestVote content Up)
      ]
      [ text "⬆" ]
    voteScore = span
      [ class "view-content__vote__score" ]
      [ text (toString content.voteScore) ]
    voteDownButton = span
      [ class "btn btn-default view-content__vote__button"
      , onClick address (RequestVote content Down)
      ]
      [ text "⬇" ]
  in
    div [ class "view-content__vote" ]
      [ voteUpButton
      , voteScore
      , voteDownButton
      ]

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
    span [ class ("view-content__status label " ++ labelColor) ] [ text statusText ]

viewContentOfficialAnswer : String -> Html
viewContentOfficialAnswer officialAnswer =
  case String.isEmpty officialAnswer of
    True -> div [] [ text "No official answer yet" ]
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
    url = Http.url "/api/contents" [ ("filter", filterStr) ]
  in
    Http.get decodeContents url
      |> Task.toMaybe
      |> Task.map SetContents
      |> Effects.task

decodeContents: Json.Decoder (List Content)
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
        (Json.maybe ("voteForCurrentUser" := Json.string))
  in
    Json.at ["data"] (Json.list content)

sendVote : Content -> VoteType -> Effects Action
sendVote content voteType =
  let
    voteTypeStr = case voteType of
      Up -> "for"
      Down -> "Down"
    url = Http.url "/api/votes" [ ("vote[content_id]", toString content.id), ("vote[vote_type]", voteTypeStr) ]
  in
    Http.post decodeVoteResult url Http.empty
      |> Task.toMaybe
      |> Task.map ReceivedVoteResult
      |> Effects.task

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
