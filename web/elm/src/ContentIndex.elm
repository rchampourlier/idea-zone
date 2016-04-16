module ContentIndex where

import Effects exposing (Effects, Never)
import Html exposing (..)
-- import Html.Attributes exposing (..)
-- import Html.Events exposing (..)
import StartApp
import Task

-- MODEL

type alias Model = String

init : (Model, Effects Action)
init =
  ( "Hello from Elm.ContentIndex!", Effects.none )


-- UPDATE
type Action = None

update : Action -> Model -> (Model, Effects Action)
update action model =
  ( model, Effects.none )

view : Signal.Address Action -> Model -> Html
view address model =
  div [] [ text model ]

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
