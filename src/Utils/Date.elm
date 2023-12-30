module Utils.Date exposing
    ( Notation
    , defaultNotation
    , encodeNotation
    , fromZoneAndPosix
    , notationDecoder
    , relativeDateLabel
    , toLabel
    , toPosix
    , toUtc0Posix
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


{-| Shifts a date relative to the current timezone.

Example: If the current timezone is UTC -3 and the input timestamp is `2020-01-01 12:00:00 UTC -3`,
then the output would be `2020-01-01 12:00:00 UTC 0`. It preserves the calendar date and clock time but changes the timezone to UTC 0.

Notice that the input timestamp is equivalent to `2020-01-01 15:00 UTC 0`, so it returned a different timestamp.

However, using the output, we can read the _current_ calendar date and clock time without needing to keep the current timezone
around: we always assume UTC 0.

This is actually the assumption that the `PanagiotisGeorgiadis/elm-datetime` package makes.
The functions `Calendar.fromPosix`, `Clock.fromPosix` and `DateTime.fromPosix` all assume its `Time.Posix` argument
is a UTC 0 timestamp.

We need this function to interface with that package.

-}
toUtc0Posix : Time.Zone -> Time.Posix -> Time.Posix
toUtc0Posix zone posix =
    Time.millisToPosix (Time.posixToMillis posix + DateTime.getTimezoneOffset zone posix)


{-| This is how I'd need `DateTime.toPosix` to be implemented by default.
-}
toPosix : Time.Zone -> DateTime.DateTime -> Time.Posix
toPosix timezone date =
    date
        |> DateTime.toPosix
        |> fromUtc0Posix timezone


{-| The package `PanagiotisGeorgiadis/elm-datetime` returns timestamps that assume we're in UTC 0 and
represent certain calendar dates and clock times.

A calendar date and clock time has a different timestamp if we read it in the _current_ timezone or in _UTC 0_ timezone.

This function converts a timestamp that was generated based on some calendar date and clock time assuming
_UTC 0_ timezone (like the package does) to a timestamp that assumes the _current_ timezone (like we need,
for example, to store it accurately in the localStorage).

-}
fromUtc0Posix : Time.Zone -> Time.Posix -> Time.Posix
fromUtc0Posix zone posix =
    Time.millisToPosix (Time.posixToMillis posix - DateTime.getTimezoneOffset zone posix)


{-| I wish this function was part of the Calendar package .\_.
-}
fromZoneAndPosix : Time.Zone -> Time.Posix -> Calendar.Date
fromZoneAndPosix timezone time =
    Calendar.fromPosix (toUtc0Posix timezone time)


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
