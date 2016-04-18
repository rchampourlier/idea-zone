module ContentIndex where

import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (class, for, href, id, type')
import Html.Events exposing (..)
import Http
import Json.Decode exposing ((:=))
import Json.Decode as Json
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
  , status : String
  , contentType : String
  }

init : (Model, Effects Action)
init =
  ( Model [] "", fetchContents "" )


-- UPDATE
type Action
  = SetContents (Maybe (List Content))
  | UpdateFilter String

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

view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ div [ class "bs-callout" ] [ viewSearchForm address model ]
    , div [] (List.map viewContent model.contents)
    ]

viewContent : Content -> Html
viewContent content =
  a [ href ("/contents/" ++ (toString content.id)) ]
    [ div [ class "bs-callout" ]
      [ h4 [] [ text content.label ]
      , div [] [ text content.description ]
      , span [ class "label label-success"] [ text content.status ]
      ]
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
      Json.object5 (\id label desc status cType -> (Content id label desc status cType))
        ("id" := Json.int)
        ("label" := Json.string)
        ("description" := Json.string)
        ("status" := Json.string)
        ("type" := Json.string)
  in
    Json.at ["data"] (Json.list content)


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
