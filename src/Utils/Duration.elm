module Utils.Duration exposing
    ( Duration
    , fromSeconds
    , fromTimeDifference
    , secondsNeededToChangeTheResultOfToString
    , toText
    )

import DateTime exposing (DateTime)
import Text
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



---


toText : Duration -> Text.Text
toText (DurationInSeconds totalSeconds) =
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
            Text.JoinWords
                [ Text.Integer 1
                , Text.Second
                ]

        ( 0, 0, s ) ->
            Text.JoinWords
                [ Text.Integer s
                , Text.Seconds
                ]

        ( h, m, _ ) ->
            [ hoursToString h
            , minutesToString m
            ]
                |> List.filterMap identity
                |> Text.JoinWords


hoursToString : Int -> Maybe Text.Text
hoursToString h =
    case h of
        0 ->
            Nothing

        1 ->
            Text.JoinWords
                [ Text.Integer 1
                , Text.Hour
                ]
                |> Just

        _ ->
            Text.JoinWords
                [ Text.Integer h
                , Text.Hours
                ]
                |> Just


minutesToString : Int -> Maybe Text.Text
minutesToString m =
    case m of
        0 ->
            Nothing

        1 ->
            Text.JoinWords
                [ Text.Integer 1
                , Text.Minute
                ]
                |> Just

        _ ->
            Text.JoinWords
                [ Text.Integer m
                , Text.Minutes
                ]
                |> Just


{-| Given a `duration`, this function returns the amount of seconds that need to be added
to that duration such that `toString duration /= toString addedDuration`.
-}
secondsNeededToChangeTheResultOfToString : Duration -> Int
secondsNeededToChangeTheResultOfToString (DurationInSeconds duration) =
    if duration < 60 then
        -- The result of toString changes every second in the first minute
        1

    else
        -- But then it changes every minute
        60 - (duration |> modBy 60)
