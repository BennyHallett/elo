module Elo.Persistence exposing (stateJson, decodeUsers)

import Json.Encode as Enc
import Json.Decode exposing (..)

stateJson model =
  Enc.list (List.map userJson model.users)

userJson user =
  Enc.object
    [
      ("name", Enc.string user.name),
      ("score", Enc.int user.score)
    ]

decodeUsers =
  list (object2 (,) ("name" := string) ("score" := int))
