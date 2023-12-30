module CreateRecord exposing
    ( store
    , subscriptions
    )

import LocalStorage
import Time
import Utils.Duration
import Utils.Time


duration : { a | currentTime : Time.Posix, startTime : Time.Posix } -> Utils.Duration.Duration
duration config =
    Utils.Duration.fromTimeDifference config.startTime config.currentTime



---


store : LocalStorage.Store Time.Posix
store =
    LocalStorage.store
        { key = "createForm"
        , encode = Utils.Time.encode
        , decoder = Utils.Time.decoder
        }



--- VIEW


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
