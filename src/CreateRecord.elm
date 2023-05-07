module CreateRecord exposing
    ( Config
    , CreateRecord
    , decoder
    , descriptionInputId
    , encode
    , new
    , subscriptions
    , view
    , setStartTime
    )

import Colors
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Input
import Element.Font
import Html.Attributes
import Icons
import Json.Decode
import Json.Encode
import Text
import DateTime
import Time
import Clock
import Utils.Duration
import Utils.Date
import Utils.Time
import Utils.Events
import View



--- Create Form


type alias CreateRecord =
    { start : Time.Posix
    , description : String
    }


new : String -> Time.Posix -> CreateRecord
new description time =
    { start = time
    , description = description
    }


duration : { currentTime : Time.Posix } -> CreateRecord -> Utils.Duration.Duration
duration { currentTime } { start } =
    Utils.Duration.fromTimeDifference start currentTime


setStartTime : { ctx | currentTime : Time.Posix, timeZone : Time.Zone }
    -> Clock.Time
    -> CreateRecord
    -> Result Text.Text CreateRecord
setStartTime { currentTime, timeZone } startTime { start, description } =
    let
        newStart =
            DateTime.fromDateAndTime
                (Utils.Date.fromZoneAndPosix timeZone currentTime)
                startTime
                |> DateTime.toPosix
                |> Utils.Date.fromZonedPosix timeZone
    in
    if Time.posixToMillis newStart < Time.posixToMillis currentTime then
        { description = description
        , start = newStart
        }
            |> Ok

    else
        Err Text.InvalidFutureTime

decoder : Json.Decode.Decoder CreateRecord
decoder =
    Json.Decode.map2 CreateRecord
        (Json.Decode.field "start" decodePosix)
        (Json.Decode.field "description" Json.Decode.string)


decodePosix : Json.Decode.Decoder Time.Posix
decodePosix =
    Json.Decode.int
        |> Json.Decode.map Time.millisToPosix



---


encode : CreateRecord -> Json.Encode.Value
encode createForm =
    Json.Encode.object
        [ ( "start", encodePosix createForm.start )
        , ( "description", Json.Encode.string createForm.description )
        ]


encodePosix : Time.Posix -> Json.Encode.Value
encodePosix posix =
    Json.Encode.int (Time.posixToMillis posix)



--- VIEW


type alias Config msg =
    { description : String
    , changedDescription : String -> msg
    , elapsedTime : Text.Text
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

        descriptionInput =
            View.input
                ([ -- Layout
                   Element.width Element.fill
                 , Element.height (Element.px 32)
                 , Element.paddingXY 0 6

                 -- Background
                 , Element.Background.color Colors.transparent

                 -- Border
                 , Element.Border.widthEach
                    { bottom = 1
                    , left = 0
                    , right = 0
                    , top = 0
                    }
                 , Element.Border.rounded 0
                 , Element.Border.color Colors.lighterGrayText
                 , Element.focused
                    [ Element.Border.color Colors.accent
                    ]

                 -- Focus
                 , Element.htmlAttribute <|
                    Html.Attributes.id descriptionInputId

                 -- Key events
                 , Utils.Events.onKeyDown
                    [ ( "Enter", config.pressedEnter )
                    , ( "Escape", config.pressedEscape )
                    ]
                 ]
                    ++ font Colors.blackText
                )
                { onChange =
                    View.enabled config.changedDescription
                        |> View.disableIf config.modalIsOpen
                , text = config.description
                , placeholder = Just (Text.text16 config.language Text.WhatAreYouWorkingOn)
                , label =
                    Text.toString config.language Text.DescriptionLabel
                        |> Element.Input.labelHidden
                }
                |> Element.el
                    [ Element.width Element.fill

                    -- A bit of custom CSS adds a running animation on the input's border.
                    , Element.htmlAttribute (Html.Attributes.class "input-border-animation")
                    ]

        stopButton =
            View.button
                [ Element.Font.color Colors.lightGrayText
                , Element.focused
                    [ Element.Font.color Colors.accent
                    ]
                ]
                { onPress =
                    View.enabled config.pressedStop
                        |> View.disableIf config.modalIsOpen
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
            [ descriptionInput
            , Element.row
                [ Element.spacing 10
                , Element.width Element.fill
                ]
                [ Element.el
                    [ Element.Font.color Colors.blackishText
                    , Element.alignBottom
                    ]
                    (Text.text12 config.language config.elapsedTime)
                , View.linkLikeButtonSmall
                    { onPress =
                        View.enabled config.pressedChangeStartTime
                            |> View.disableIf config.modalIsOpen
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
    }
    -> CreateRecord
    -> Sub msg
subscriptions { currentTime, gotCurrentTime } createForm =
    Time.every
        (duration { currentTime = currentTime } createForm
            |> Utils.Duration.secondsBeforeTheLabelChanges
            |> toFloat
            |> (*) 1000
        )
        gotCurrentTime
