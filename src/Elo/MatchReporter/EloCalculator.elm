module Elo.MatchReporter.EloCalculator exposing (newScore)

import Elo.User.Types exposing (User)

k : number
k = 30

newScore : User -> User -> Int -> Int -> Int
newScore p1 p2 p1Goals p2Goals =
  round((toFloat p1.score) + k * ((winner p1Goals p2Goals) - (expected_winner (toFloat (p1.score - p2.score)))))

expected_winner : Float -> Float
expected_winner diff =
  1 / ((10 ^ (diff / 400 * -1)) + 1)

winner : Int -> Int -> Float
winner p1 p2 =
  case (compare p1 p2) of
      LT -> 0
      EQ -> 0.5
      GT -> 1

score_diff : Int -> Int -> Int
score_diff p1 p2 =
  let
    diff = p1 - p2
  in
    case (compare diff 0) of
      LT -> diff * -1
      EQ -> 0
      GT -> diff

