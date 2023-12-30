module Utils.Duration exposing
    ( Duration
    , add
    , fromSeconds
    , fromTimeDifference
    , label
    , secondsBeforeTheLabelChanges
    , toSeconds
    )

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


toSeconds : Duration -> Int
toSeconds (DurationInSeconds s) =
    s


add : Duration -> Duration -> Duration
add (DurationInSeconds a) (DurationInSeconds b) =
    DurationInSeconds (a + b)



---


label : Duration -> Text.Text
label (DurationInSeconds totalSeconds) =
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
            totalMinutes - totalHours * 60
    in
    case ( days, hours, minutes ) of
        ( 0, 0, 0 ) ->
            let
                seconds =
                    totalSeconds - totalMinutes * 60
            in
            -- Only shows seconds if there are no minutes, hours or days
            secondsToText seconds

        _ ->
            [ daysToText days
            , hoursToText hours
            , minutesToText minutes
            ]
                |> List.filterMap identity
                |> Text.Words


daysToText : Int -> Maybe Text.Text
daysToText days =
    case days of
        0 ->
            Nothing

        _ ->
            Text.Words
                [ Text.Integer days
                , Text.Days
                ]
                |> Just


hoursToText : Int -> Maybe Text.Text
hoursToText h =
    case h of
        0 ->
            Nothing

        _ ->
            Text.Words
                [ Text.Integer h
                , Text.Hours
                ]
                |> Just


minutesToText : Int -> Maybe Text.Text
minutesToText m =
    case m of
        0 ->
            Nothing

        _ ->
            Text.Words
                [ Text.Integer m
                , Text.Minutes
                ]
                |> Just


secondsToText : Int -> Text.Text
secondsToText s =
    Text.Words
        [ Text.Integer s
        , Text.Seconds
        ]


{-| Given a `duration`, this function returns the amount of seconds that need to be added
to that duration such that `toString duration /= toString addedDuration`.
-}
secondsBeforeTheLabelChanges : Duration -> Int
secondsBeforeTheLabelChanges (DurationInSeconds duration) =
    if duration < 60 then
        -- The result of toString changes every second in the first minute
        1

    else
        -- But then it changes every minute
        60 - (duration |> modBy 60)
