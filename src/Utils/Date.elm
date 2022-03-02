module Utils.Date exposing (relativeDateLabel, toZonedPosix)

import Calendar
import Clock
import DateTime
import Text
import Time


relativeDateLabel :
    { today : Calendar.Date
    , date : Calendar.Date
    , unitedStatesDateNotation : Bool
    }
    -> Text.Text
relativeDateLabel { today, date, unitedStatesDateNotation } =
    if today == date then
        Text.Today

    else if Calendar.decrementDay today == date then
        Text.Yesterday

    else if Calendar.incrementDay today == date then
        Text.Tomorrow

    else if
        let
            diff =
                Calendar.getDayDiff date today
        in
        diff > 0 && diff <= 4
    then
        Calendar.getWeekday date
            |> Text.Weekday

    else
        let
            day =
                Calendar.getDay date

            month =
                Calendar.getMonth date

            year =
                Calendar.getYear date
        in
        if unitedStatesDateNotation then
            Text.UsaDate month day year

        else
            Text.InternationalDate day month year


toZonedPosix : Time.Zone -> Time.Posix -> Time.Posix
toZonedPosix zone posix =
    let
        offset =
            DateTime.getTimezoneOffset zone posix

        millis =
            Time.posixToMillis posix
    in
    Time.millisToPosix (millis + offset)
