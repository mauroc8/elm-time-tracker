module Utils.Duration exposing
    ( Duration
    , fromSeconds
    , fromTimeDifference
    , lessThan
    , toString
    )

import DateTime exposing (DateTime)
import Time



---


type Duration
    = DurationInSeconds Int


fromTimeDifference : Time.Posix -> Time.Posix -> Duration
fromTimeDifference time0 time1 =
    abs
        (Time.posixToMillis time0
            - Time.posixToMillis time1
        )
        |> fromMillis


fromMillis : Int -> Duration
fromMillis ms =
    DurationInSeconds (ms // 1000)


fromSeconds : Int -> Duration
fromSeconds s =
    DurationInSeconds s


{-| The args are reversed, use it in a pipeline.
-}
lessThan : Duration -> Duration -> Bool
lessThan (DurationInSeconds duration0) (DurationInSeconds duration1) =
    duration1 < duration0



---


toString : Duration -> String
toString (DurationInSeconds totalSeconds) =
    let
        totalMinutes =
            totalSeconds // 60

        totalHours =
            totalMinutes // 60

        days =
            totalHours // 24

        hours =
            totalHours - days * 24

        minutes =
            totalMinutes - hours * 60

        seconds =
            totalSeconds - minutes * 60
    in
    case ( hours, minutes, seconds ) of
        ( 0, 0, 1 ) ->
            "1 second"

        ( 0, 0, s ) ->
            String.fromInt s ++ " seconds"

        ( h, m, _ ) ->
            [ hoursToString h
            , minutesToString m
            ]
                |> List.filterMap identity
                |> String.join " "


hoursToString : Int -> Maybe String
hoursToString h =
    case h of
        0 ->
            Nothing

        1 ->
            Just "1 hour"

        _ ->
            Just (String.fromInt h ++ " hours")


minutesToString : Int -> Maybe String
minutesToString h =
    case h of
        0 ->
            Nothing

        1 ->
            Just "1 minute"

        _ ->
            Just (String.fromInt h ++ " minutes")
