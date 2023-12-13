module CreateRecord exposing
    ( Config
    , setStartTime
    , store
    , subscriptions
    )

import Clock
import DateTime
import LocalStorage
import Text
import Time
import Utils.Date
import Utils.Duration
import Utils.Time


duration : { a | currentTime : Time.Posix, startTime : Time.Posix } -> Utils.Duration.Duration
duration config =
    Utils.Duration.fromTimeDifference config.startTime config.currentTime


setStartTime :
    { a | currentTime : Time.Posix, timezone : Time.Zone }
    -> Clock.Time
    -> Result Text.Text Time.Posix
setStartTime { currentTime, timezone } startClockTime =
    let
        newStart =
            DateTime.fromDateAndTime
                (Utils.Date.fromZoneAndPosix timezone currentTime)
                startClockTime
                |> DateTime.toPosix
                |> Utils.Date.fromZonedPosix timezone
    in
    if Time.posixToMillis newStart < Time.posixToMillis currentTime then
        Ok newStart

    else
        Err Text.InvalidFutureTime



---


store : LocalStorage.Store Time.Posix
store =
    LocalStorage.store
        { key = "createForm"
        , encode = Utils.Time.encode
        , decoder = Utils.Time.decoder
        }



--- VIEW


type alias Config msg =
    { elapsedTime : Text.Text
    , pressedStop : msg
    , pressedEnter : msg
    , pressedEscape : msg
    , pressedChangeStartTime : msg
    , language : Text.Language
    , modalIsOpen : Bool
    }


subscriptions :
    { currentTime : Time.Posix
    , gotCurrentTime : Time.Posix -> msg
    , startTime : Time.Posix
    }
    -> Sub msg
subscriptions config =
    Time.every
        (duration config
            |> Utils.Duration.secondsBeforeTheLabelChanges
            |> toFloat
            |> (*) 1000
        )
        config.gotCurrentTime
