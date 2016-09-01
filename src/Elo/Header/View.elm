module Elo.Header.View exposing (render)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)

render : Html msg
render =
    div [class "header"] [text "Football ELO Tracker"]
