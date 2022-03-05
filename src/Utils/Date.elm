module Utils.Date exposing (Notation, encodeNotation, notationDecoder, relativeDateLabel, toZonedPosix, unitedStatesNotation, westernNotation)

import Calendar
import Clock
import DateTime
import Json.Decode
import Json.Encode
import Text
import Time
import Utils



---


type Notation
    = UnitedStates
    | Western


westernNotation : Notation
westernNotation =
    Western


notationToString : Notation -> String
notationToString notation =
    case notation of
        UnitedStates ->
            "UnitedStates"

        Western ->
            "RestOfOccident"


notationDecoder : Json.Decode.Decoder Notation
notationDecoder =
    Json.Decode.oneOf
        [ Utils.decodeLiteral UnitedStates (notationToString UnitedStates)
        , Utils.decodeLiteral Western (notationToString Western)
        ]


encodeNotation : Notation -> Json.Encode.Value
encodeNotation notation =
    Json.Encode.string (notationToString notation)


unitedStatesNotation : Notation
unitedStatesNotation =
    UnitedStates



---


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

            Western ->
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
        offset =
            DateTime.getTimezoneOffset zone posix

        millis =
            Time.posixToMillis posix
    in
    Time.millisToPosix (millis + offset)
