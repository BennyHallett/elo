module Elo.User.View exposing (render)

import Elo.User.Types exposing (User)
import Html exposing (Html, div, text, ol, li, span,  h2)
import Html.Attributes exposing (class)

render : List User -> Html msg
render users =
  div [class "lhs"] [div [] [h2 [] [text "Current Standings"], (playerList users)]]

playerList : List User -> Html msg
playerList users =
  ol [class "player-list"] (List.map renderPlayer users)

renderPlayer : User -> Html msg
renderPlayer user =
    li [class "player"] [
         span [class "player-name"] [text user.name],
         span [class "player-score"] [text (toString user.score)]
        ]
