module Elo.Model exposing (Model, init, Msg)

import Elo.User.Types as User

type alias Model =
    {
        users : List User.User,
        newUserName : String,
        chosenPlayerOne : String,
        chosenPlayerOneScore : Int,
        chosenPlayerTwo : String,
        chosenPlayerTwoScore : Int,
        debug : String
    }

init =
  ({ users = [], newUserName = "", chosenPlayerOne = "", chosenPlayerOneScore = 0, chosenPlayerTwo = "", chosenPlayerTwoScore = 0, debug = "" }, Cmd.none)

type Msg = AddUser
         | InputUserName String
         | SetPlayerOne String
         | SetPlayerOneScore String
         | SetPlayerTwo String
         | SetPlayerTwoScore String
         | ReportMatch
