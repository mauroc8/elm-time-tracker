module Record exposing
    ( Config
    , ConfigStatus(..)
    , Id
    , Record
    , config
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
    Element.column
        [ Element.padding 16
        ]
        [ Element.text description
        , Element.text duration
        ]


type alias Config msg =
    { description : String
    , date : String
    , duration : String
    , status : ConfigStatus msg
    }


config : { a | selectRecord : Id -> msg } -> Record -> Config msg
config { selectRecord } record =
    { description = record.description
    , date = "today"
    , duration = "15 minutes"
    , status =
        NotSelected
            { select = selectRecord
            }
    }


type ConfigStatus msg
    = Selected
        { startTime : String
        , endTime : String
        , clickedDeleteButton : Id -> msg
        , clickedEditButton : Id -> msg
        , clickedResumeButton : Id -> msg
        }
    | NotSelected
        { select : Id -> msg
        }
