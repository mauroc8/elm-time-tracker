module Record exposing
    ( Config
    , ConfigStatus(..)
    , Id
    , Record
    , RecordData
    , view
    )

import Calendar
import Clock
import DateTime exposing (DateTime)
import Element exposing (Element)
import Time


type alias Record =
    { description : String
    , startDate : Calendar.Date
    , startTime : Clock.Time
    , durationInSeconds : Int
    }


type Id
    = Id Int


type alias RecordData =
    { id : Id
    , description : String
    , startDateTime : Time.Posix
    , durationInSeconds : Int
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
