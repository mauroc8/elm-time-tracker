module Utils.Date exposing (relativeDateLabel, toZonedPosix)

import Calendar
import Clock
import DateTime
import Time


relativeDateLabel :
    { today : Calendar.Date
    , date : Calendar.Date
    , unitedStatesDateNotation : Bool
    }
    -> String
relativeDateLabel { today, date, unitedStatesDateNotation } =
    if today == date then
        "today"

    else if Calendar.decrementDay today == date then
        "yesterday"

    else if Calendar.incrementDay today == date then
        "tomorrow"

    else if
        let
            diff =
                Calendar.getDayDiff date today
        in
        diff > 0 && diff <= 4
    then
        Calendar.getWeekday date
            |> weekdayToString

    else
        let
            day =
                Calendar.getDay date
                    |> String.fromInt

            month =
                Calendar.getMonth date
                    |> monthToString

            year =
                Calendar.getYear date
                    |> String.fromInt
        in
        if unitedStatesDateNotation then
            String.join "/"
                [ month
                , day
                , year
                ]

        else
            String.join "/"
                [ day
                , month
                , year
                ]


weekdayToString : Time.Weekday -> String
weekdayToString weekday =
    case weekday of
        Time.Mon ->
            "monday"

        Time.Tue ->
            "tuesday"

        Time.Wed ->
            "wednesday"

        Time.Thu ->
            "thursday"

        Time.Fri ->
            "friday"

        Time.Sat ->
            "saturday"

        Time.Sun ->
            "sunday"


monthToString : Time.Month -> String
monthToString month =
    case month of
        Time.Jan ->
            "1"

        Time.Feb ->
            "2"

        Time.Mar ->
            "3"

        Time.Apr ->
            "4"

        Time.May ->
            "5"

        Time.Jun ->
            "6"

        Time.Jul ->
            "7"

        Time.Aug ->
            "8"

        Time.Sep ->
            "9"

        Time.Oct ->
            "10"

        Time.Nov ->
            "11"

        Time.Dec ->
            "12"


toZonedPosix : Time.Zone -> Time.Posix -> Time.Posix
toZonedPosix zone posix =
    let
        offset =
            DateTime.getTimezoneOffset zone posix

        millis =
            Time.posixToMillis posix
    in
    Time.millisToPosix (millis + offset)
