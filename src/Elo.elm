port module Elo exposing (..)

import Html exposing (Html, button, div, text, input, ol, li, span, select, option, node, h2)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, on)
import Html.App as App
import String
import Result
import Elo.Header.View as HeaderView
import Elo.User.View as UserView
import Elo.Model as Model
import Elo.User.Types as UserModel
import Elo.Persistence exposing (stateJson, decodeUsers)
import Json.Encode
import Json.Decode
import Task
import Elo.MatchReporter.EloCalculator as Calc

main =
  App.program { init = Model.init, view = view, update = update, subscriptions = subscriptions }

type Msg = AddUser
         | InputUserName String
         | SetPlayerOne String
         | SetPlayerOneScore String
         | SetPlayerTwo String
         | SetPlayerTwoScore String
         | ReportMatch
         | SaveState
         | Init String

update : Msg -> Model.Model -> (Model.Model, Cmd Msg)
update msg model =
  case msg of
    AddUser ->
        ({model | newUserName = "", users = List.append model.users [{name = model.newUserName, score = 1500}]}, saveTask)
    InputUserName name ->
      ({model | newUserName = name}, Cmd.none)
    SetPlayerOne p1 ->
      ({model | chosenPlayerOne = p1}, Cmd.none)
    SetPlayerOneScore p1 ->
      ({model | chosenPlayerOneScore = (Result.withDefault 0 (String.toInt p1))}, Cmd.none)
    SetPlayerTwo p2 ->
      ({model | chosenPlayerTwo = p2}, Cmd.none)
    SetPlayerTwoScore p2 ->
      ({model | chosenPlayerTwoScore = (Result.withDefault 0 (String.toInt p2))}, Cmd.none)
    ReportMatch ->
      ({model | users = (reportMatch model), chosenPlayerOne = "", chosenPlayerTwo = "", chosenPlayerOneScore = 0, chosenPlayerTwoScore = 0}, saveTask)
    SaveState ->
      (model, save (stateJson model))
    Init data ->
      ({model | users = (List.map tupleToPlayer (Result.withDefault [] (Json.Decode.decodeString decodeUsers data)))}, Cmd.none)

tupleToPlayer (name, score) =
  {name = name, score = score}

saveTask : Cmd Msg
saveTask =
  Task.perform (\_ -> Debug.crash "Should never happen") identity (Task.succeed SaveState)

view model =
    let
        matchReporter =
            div [class "match-reporter"] [
                 h2 [] [text "Report a match"],
                 select [class "player-select", name "player-one", onInput SetPlayerOne] (playerSelectOptions model.users model.chosenPlayerOne),
                 select [class "score-select", name "player-one-score", onInput SetPlayerOneScore] (scoreSelectOptions model.chosenPlayerOneScore),
                 div [class "vs-text"] [text "vs"],
                 select [class "player-select", name "player-two", onInput SetPlayerTwo] (playerSelectOptions model.users model.chosenPlayerTwo),
                 select [class "score-select", name "player-two-score", onInput SetPlayerTwoScore] (scoreSelectOptions model.chosenPlayerTwoScore),
                 button [class "button", onClick ReportMatch] [text "Report match"]
                ]

        sidebar =
            div [class "rhs"] [
                 div [class "player-input"] [h2 [] [text "Add a player"], input [placeholder "Player Name", onInput InputUserName, value model.newUserName] [],
                                                 button [class "button", onClick AddUser] [text "Add Player"]],
                     matchReporter
            ]

    in
      div [] [
            HeaderView.render,
            div [class "container"] [
              UserView.render model.users,
              sidebar
            ]
          ]

scoreSelectOptions : Int -> List (Html Msg)
scoreSelectOptions selectedValue =
  let
    attr =
      (\v ->
         case v == selectedValue of
           True -> [selected True]
           False -> []
      )
  in
    List.map (\v -> option (attr v) [text (toString v)]) [0..10]


playerSelectOptions : List (UserModel.User) -> String -> List (Html Msg)
playerSelectOptions users selectedValue =
  let
    attr =
      (\m ->
         case m.name == selectedValue of
           True -> [selected True]
           False -> []
      )
  in
    List.append [option [] [text ""]] (List.map (\user -> option (attr user) [text user.name]) users)


toInt num =
    Result.withDefault 0 (String.toInt (toString num))

reportMatch : Model.Model -> List UserModel.User
reportMatch model =
    let
        p1 =
            Maybe.withDefault {name = "", score = 0} (List.head (List.filter (\player -> player.name == model.chosenPlayerOne) model.users))

        p2 =
            Maybe.withDefault {name = "", score = 0} (List.head (List.filter (\player -> player.name == model.chosenPlayerTwo) model.users))

        remaining =
            List.filter (\player -> player.name /= model.chosenPlayerOne && player.name /= model.chosenPlayerTwo) model.users

        p1ns =
          Calc.newScore p1 p2 model.chosenPlayerOneScore model.chosenPlayerTwoScore

        p2ns =
          Calc.newScore p2 p1 model.chosenPlayerTwoScore model.chosenPlayerOneScore

    in
      List.reverse (List.sortBy .score (List.append remaining [{name = p1.name, score = p1ns}, {name = p2.name, score = p2ns}]))


-- PORTS

port save : Json.Encode.Value -> Cmd msg

port load : (String -> msg) -> Sub msg

subscriptions : Model.Model -> Sub Msg
subscriptions model =
  load Init
