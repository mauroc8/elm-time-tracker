module CreateForm exposing (Config, CreateForm, empty)

import Time



--- Create Form


type alias CreateForm =
    { start : Time.Posix
    , description : String
    }


empty : Time.Posix -> CreateForm
empty time =
    { start = time
    , description = ""
    }



--- VIEW


type alias Config msg =
    { description : String
    , elapsedTime : String
    , changedDescription : String -> msg
    , pressedStop : msg
    }
