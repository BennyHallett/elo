module Elo.SelectHandler exposing (onSelect)

import Json.Decode as Json
import Html.Events exposing (on)
import Html exposing (Attribute)

targetSelectedIndex = Json.at ["target", "selectedIndex"] Json.int

onSelect : (String -> msg) -> Attribute Int
onSelect message =
    on "change" (Json.map message targetSelectedIndex)
