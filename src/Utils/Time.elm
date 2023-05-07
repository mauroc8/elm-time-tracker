module Utils.Time exposing
    ( fromHhMm
    , fromZoneAndPosix
    , toHhMm
    , toStringWithAmPm
    )

import Clock
import DateTime
import Text
import Time
import Utils.Date


fromHhMm : String -> Result Text.Text Clock.Time
fromHhMm string =
    let
        listOfNumbers =
            String.split ":" string
                |> List.map String.toInt
    in
    case listOfNumbers of
        [ Just hours, Just minutes ] ->
            Clock.fromRawParts
                { hours = hours
                , minutes = minutes
                , seconds = 0
                , milliseconds = 0
                }
                |> Result.fromMaybe Text.InvalidTime

        _ ->
            Err Text.InvalidTimeFormat


toHhMm : Clock.Time -> String
toHhMm time =
    [ Clock.getHours time
    , Clock.getMinutes time
    ]
        |> List.map
            (\n ->
                if n < 10 then
                    "0"
                        ++ String.fromInt n

                else
                    String.fromInt n
            )
        |> String.join ":"


toStringWithAmPm : Clock.Time -> String
toStringWithAmPm time =
    let
        minutes =
            Clock.getMinutes time

        ( hours, amPm ) =
            getHoursAndMeridiem time
    in
    String.fromInt hours
        ++ ":"
        ++ (String.fromInt minutes |> String.padLeft 2 '0')
        ++ " "
        ++ meridiemToString amPm


{-| For example `3 pm` can be represented as `( 3, Pm )`
-}
type AmPm
    = Pm
    | Am


getHoursAndMeridiem : Clock.Time -> ( Int, AmPm )
getHoursAndMeridiem time =
    let
        hours =
            Clock.getHours time
    in
    if hours > 12 then
        ( hours - 12, Pm )

    else
        ( hours, Am )


meridiemToString : AmPm -> String
meridiemToString amPm =
    case amPm of
        Pm ->
            "pm"

        Am ->
            "am"


fromZoneAndPosix : Time.Zone -> Time.Posix -> Clock.Time
fromZoneAndPosix zone posix =
    Utils.Date.toZonedPosix zone posix
        |> Clock.fromPosix

