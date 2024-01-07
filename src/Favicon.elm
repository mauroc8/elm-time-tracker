port module Favicon exposing (play, stop)

import Json.Decode
import Json.Encode


port setFavicon : String -> Cmd msg


play : Cmd msg
play =
    setFavicon "play"


stop : Cmd msg
stop =
    setFavicon "stop"
