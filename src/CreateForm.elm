module CreateForm exposing (Config, CreateForm, descriptionInputId, duration, new, subscriptions, view)

import Colors
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font exposing (Font)
import Element.Input
import Html.Attributes
import Html.Events
import Icons
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



--- VIEW


type alias Config msg =
    { description : String
    , elapsedTime : String
    , changedDescription : String -> msg
    , pressedStop : msg
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
                 , Element.Border.color Colors.accent
                 , Element.Border.rounded 0

                 -- Focus
                 , Element.htmlAttribute <|
                    Html.Attributes.id descriptionInputId

                 -- Key events
                 , Utils.Events.onEnter config.pressedStop
                 , Utils.Events.onEscape config.pressedEscape
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
                (Text.text12 config.language (Text.Unlocalized config.elapsedTime))
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
        (Utils.Duration.secondsNeededToChangeTheResultOfToString
            (duration { currentTime = currentTime } createForm)
            |> (*) 1000
            |> toFloat
        )
        gotCurrentTime
