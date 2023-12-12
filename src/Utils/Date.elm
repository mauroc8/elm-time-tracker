module Utils.Date exposing
    ( Notation
    , defaultNotation
    , encodeNotation
    , fromZoneAndPosix
    , fromZonedPosix
    , notationDecoder
    , relativeDateLabel
    , toLabel
    , toZonedPosix
    , usaNotation
    , weekdayToInt
    )

import Calendar
import DateTime
import Json.Decode
import Json.Encode
import Text
import Time
import Utils



---


{-| The UnitedStates date notation is MM/DD/YYYY, while the default date notation
is DD/MM/YYYY.

Note: I'm sorry for not supporting other date notations

-}
type Notation
    = UnitedStates
    | Default


defaultNotation : Notation
defaultNotation =
    Default


notationDecoder : Json.Decode.Decoder Notation
notationDecoder =
    Json.Decode.oneOf
        [ Utils.decodeLiteral UnitedStates "UnitedStates"
        , Utils.decodeLiteral Default "Default"
        ]


encodeNotation : Notation -> Json.Encode.Value
encodeNotation notation =
    case notation of
        UnitedStates ->
            Json.Encode.string "UnitedStates"

        Default ->
            Json.Encode.string "Default"


usaNotation : Notation
usaNotation =
    UnitedStates



---


toLabel : Notation -> Calendar.Date -> Text.Text
toLabel notation date =
    case notation of
        UnitedStates ->
            Text.UsaDate
                (Calendar.getMonth date)
                (Calendar.getDay date)
                (Calendar.getYear date)

        Default ->
            Text.InternationalDate
                (Calendar.getDay date)
                (Calendar.getMonth date)
                (Calendar.getYear date)


{-| Returns a description of a date relative to the current date.
For example: "yesterday", "a week ago", etc.
-}
relativeDateLabel :
    { today : Calendar.Date
    , date : Calendar.Date
    , dateNotation : Notation
    }
    -> Text.Text
relativeDateLabel { today, date, dateNotation } =
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
        case dateNotation of
            UnitedStates ->
                Text.UsaDate month day year

            Default ->
                Text.InternationalDate day month year



---


{-| Shifts a date's hour relative to the time zone.

Converts a posix time to a "zoned" posix, where getting
the hour, for example, will behave like javascript's `Date#getHour`, rather
than `Date#getUTCHour`.

-}
toZonedPosix : Time.Zone -> Time.Posix -> Time.Posix
toZonedPosix zone posix =
    let
        { offset, millis } =
            offsetAndMillis zone posix
    in
    Time.millisToPosix (millis + offset)


fromZonedPosix : Time.Zone -> Time.Posix -> Time.Posix
fromZonedPosix zone posix =
    let
        { offset, millis } =
            offsetAndMillis zone posix
    in
    Time.millisToPosix (millis - offset)


offsetAndMillis : Time.Zone -> Time.Posix -> { offset : Int, millis : Int }
offsetAndMillis zone posix =
    { offset =
        DateTime.getTimezoneOffset zone posix
    , millis =
        Time.posixToMillis posix
    }


{-| I wish this function was part of the Calendar package .\_.
-}
fromZoneAndPosix : Time.Zone -> Time.Posix -> Calendar.Date
fromZoneAndPosix timeZone time =
    Calendar.fromPosix (toZonedPosix timeZone time)


weekdayToInt : Time.Weekday -> Int
weekdayToInt weekday =
    case weekday of
        Time.Mon ->
            0

        Time.Tue ->
            1

        Time.Wed ->
            2

        Time.Thu ->
            3

        Time.Fri ->
            4

        Time.Sat ->
            5

        Time.Sun ->
            6
