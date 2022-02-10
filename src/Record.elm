module Record exposing
    ( Id
    , Record
    , RecordData
    , description
    )

import Calendar
import Clock
import DateTime exposing (DateTime)
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


description : Record -> String
description record =
    record.description
