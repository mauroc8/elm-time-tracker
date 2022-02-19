module Record exposing
    ( Config
    , ConfigStatus(..)
    , Id
    , Record
    , decoder
    , fromCreateForm
    , view
    )

import Calendar
import Clock
import CreateForm
import DateTime exposing (DateTime)
import Element exposing (Element)
import Json.Decode
import Time


posixDecoder =
    Json.Decode.int |> Json.Decode.map Time.millisToPosix



--- ID


type Id
    = Id Int


idDecoder =
    Json.Decode.int |> Json.Decode.map Id



--- RECORD


type alias Record =
    { id : Id
    , description : String
    , startDateTime : Time.Posix
    , durationInSeconds : Int
    }


decoder : Json.Decode.Decoder Record
decoder =
    Json.Decode.map4 Record
        (Json.Decode.field "id" idDecoder)
        (Json.Decode.field "description" Json.Decode.string)
        (Json.Decode.field "startDateTime" posixDecoder)
        (Json.Decode.field "durationInSecods" Json.Decode.int)


fromCreateForm : Time.Posix -> CreateForm.CreateForm -> Record
fromCreateForm now { description, start } =
    { id = Id (Time.posixToMillis now)
    , description = description
    , startDateTime = start
    , durationInSeconds = (Time.posixToMillis now - Time.posixToMillis start) // 1000
    }



--- VIEW


view : Config msg -> Element msg
view { description, date, duration, status } =
    Element.column []
        [ Element.text description
        ]


type alias Config msg =
    { description : String
    , date : String
    , duration : String
    , status : ConfigStatus msg
    }


type ConfigStatus msg
    = Selected
        { startTime : String
        , endTime : String
        , clickedDeleteButton : Int -> msg
        , clickedEditButton : Int -> msg
        , clickedResumeButton : Int -> msg
        }
    | NotSelected
        { select : Int -> msg
        }
