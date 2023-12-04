module CreateRecord exposing
    ( Config
    , descriptionInputId
    , setStartTime
    , store
    , subscriptions
    , view
    )

import Clock
import Colors
import DateTime
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Html.Attributes
import Icons
import Json.Decode
import Json.Encode
import LocalStorage
import Text
import Time
import Ui
import Utils.Date
import Utils.Duration
import Utils.Events
import Utils.Time


duration : { a | currentTime : Time.Posix, startTime : Time.Posix } -> Utils.Duration.Duration
duration config =
    Utils.Duration.fromTimeDifference config.startTime config.currentTime


setStartTime :
    { a | currentTime : Time.Posix, timeZone : Time.Zone }
    -> Clock.Time
    -> Result Text.Text Time.Posix
setStartTime { currentTime, timeZone } startClockTime =
    let
        newStart =
            DateTime.fromDateAndTime
                (Utils.Date.fromZoneAndPosix timeZone currentTime)
                startClockTime
                |> DateTime.toPosix
                |> Utils.Date.fromZonedPosix timeZone
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


view : Config msg -> Element msg
view config =
    let
        font color =
            [ Element.Font.semiBold
            , Element.Font.color color
            ]

        stopButton =
            Element.Input.button
                [ Element.Font.color Colors.lightGrayText
                , Element.focused
                    [ Element.Font.color Colors.accent
                    ]
                ]
                { onPress =
                    if config.modalIsOpen then
                        Nothing

                    else
                        Just config.pressedStop
                , label = Icons.stopButton
                }
    in
    Element.row
        [ Element.spacing 24
        , Element.width Element.fill
        ]
        [ Element.column
            [ Element.spacing 9
            , Element.width Element.fill
            ]
            [ Element.row
                [ Element.spacing 10
                , Element.width Element.fill
                ]
                [ Element.el
                    [ Element.Font.color Colors.blackishText
                    , Element.alignBottom
                    ]
                    (Text.text12 config.language config.elapsedTime)
                , Ui.linkLikeButtonSmall
                    { onPress =
                        if config.modalIsOpen then
                            Nothing

                        else
                            Just config.pressedChangeStartTime
                    , label = Text.ChangeStartTimeButton
                    , language = config.language
                    }
                    |> Element.el [ Element.alignRight ]
                ]
            ]
        , stopButton
        ]


descriptionInputId : String
descriptionInputId =
    "create-form-description-input"


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
