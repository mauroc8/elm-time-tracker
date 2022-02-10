module Lang exposing (Lang(..))

import Calendar exposing (Date)
import Clock exposing (Time)
import Time


type Lang
    = English
    | Spanish



--- DateLabel


type DateLabel
    = Today
    | Tomorrow
    | Yesterday
    | LastWeekday Time.Weekday
    | OtherDate Date


relativeDateLabel :
    { today : Date
    , otherDate : Date
    }
    -> DateLabel
relativeDateLabel { today, otherDate } =
    if today == otherDate then
        Today

    else if Calendar.incrementDay today == otherDate then
        Tomorrow

    else if Calendar.decrementDay today == otherDate then
        Yesterday

    else if
        let
            dayDiff =
                Calendar.getDayDiff otherDate today
        in
        (dayDiff > 0)
            && (dayDiff < 5)
    then
        LastWeekday (Calendar.getWeekday otherDate)

    else
        OtherDate otherDate


dateLabelToString : Lang -> DateLabel -> String
dateLabelToString lang dateLabel =
    case ( lang, dateLabel ) of
        ( English, Today ) ->
            "Today"

        ( English, Yesterday ) ->
            "Yesterday"

        ( English, Tomorrow ) ->
            "Tomorrow"

        ( Spanish, Today ) ->
            "Hoy"

        ( Spanish, Yesterday ) ->
            "Ayer"

        ( Spanish, Tomorrow ) ->
            "Mañana"

        ( lang_, LastWeekday weekday ) ->
            weekdayToString lang_ weekday

        _ ->
            Debug.todo "dateLabelToString"



--- Weekday


weekdayToString : Lang -> Time.Weekday -> String
weekdayToString lang weekday =
    case ( lang, weekday ) of
        ( English, Time.Mon ) ->
            "Monday"

        ( English, Time.Tue ) ->
            "Tuesday"

        _ ->
            Debug.todo "weekdayToString"
