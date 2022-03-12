module CreateForm exposing
    ( Config
    , CreateForm
    , decoder
    , descriptionInputId
    , duration
    , encode
    , new
    , subscriptions
    , view
    )

import Colors
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font exposing (Font)
import Element.Input
import Html.Attributes
import Html.Events
import Icons
import Json.Decode
import Json.Encode
import Text
import Time
import Utils.Duration
import Utils.Events
import View



--- Create Form


type alias CreateForm =
    { start : Time.Posix
    , description : String
    }


new : String -> Time.Posix -> CreateForm
new description time =
    { start = time
    , description = description
    }


duration : { currentTime : Time.Posix } -> CreateForm -> Utils.Duration.Duration
duration { currentTime } { start } =
    Utils.Duration.fromTimeDifference start currentTime


decoder : Json.Decode.Decoder CreateForm
decoder =
    Json.Decode.map2 CreateForm
        (Json.Decode.field "start" decodePosix)
        (Json.Decode.field "description" Json.Decode.string)


decodePosix : Json.Decode.Decoder Time.Posix
decodePosix =
    Json.Decode.int
        |> Json.Decode.map Time.millisToPosix



---


encode createForm =
    Json.Encode.object
        [ ( "start", encodePosix createForm.start )
        , ( "description", Json.Encode.string createForm.description )
        ]


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
    , language : Text.Language
    }


view : Config msg -> Element msg
view config =
    let
        font color =
            [ Element.Font.semiBold
            , Element.Font.color color
            ]
    in
    Element.row
        [ Element.spacing 24
        , Element.width Element.fill
        ]
        [ Element.column
            [ Element.spacing 10
            , Element.width Element.fill
            ]
            [ Element.Input.text
                ([ -- Layout
                   Element.width Element.fill
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
                { onChange = config.changedDescription
                , text = config.description
                , placeholder =
                    Just
                        (Element.Input.placeholder
                            (font Colors.lightGrayText)
                            (Text.text16 config.language Text.WhatAreYouWorkingOn)
                        )
                , label =
                    Element.Input.labelHidden (Text.toString config.language Text.DescriptionLabel)
                }
            , Element.el
                [ Element.Font.color Colors.blackishText
                ]
                (Text.text12 config.language config.elapsedTime)
            ]
        , View.button
            []
            { onPress = View.enabled config.pressedStop
            , label = Icons.stopButton
            }
        ]


descriptionInputId : String
descriptionInputId =
    "create-form-description-input"


subscriptions :
    { currentTime : Time.Posix
    , gotCurrentTime : Time.Posix -> msg
    }
    -> CreateForm
    -> Sub msg
subscriptions { currentTime, gotCurrentTime } createForm =
    Time.every
        (duration { currentTime = currentTime } createForm
            |> Utils.Duration.secondsNeededToChangeTheResultOfToString
            |> (*) 1000
            |> toFloat
        )
        gotCurrentTime
