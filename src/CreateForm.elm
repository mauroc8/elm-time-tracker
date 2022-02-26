module CreateForm exposing (Config, CreateForm, empty, view)

import Colors
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font exposing (Font)
import Element.Input
import Icons
import Time
import View



--- Create Form


type alias CreateForm =
    { start : Time.Posix
    , description : String
    }


empty : Time.Posix -> CreateForm
empty time =
    { start = time
    , description = ""
    }



--- VIEW


type alias Config msg =
    { description : String
    , elapsedTime : String
    , changedDescription : String -> msg
    , pressedStop : msg
    }


view : Config msg -> Element msg
view config =
    let
        font color =
            [ Element.Font.semiBold
            , Element.Font.color color
            ]
                ++ View.fontSize16
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
                 ]
                    ++ font Colors.blackishText
                )
                { onChange = config.changedDescription
                , text = config.description
                , placeholder =
                    Just
                        (Element.Input.placeholder
                            (font Colors.lightGrayText)
                            (Element.text "what are you working on?")
                        )
                , label =
                    Element.Input.labelHidden "Description"
                }
            , Element.el
                ([ Element.Font.color Colors.blackishText
                 ]
                    ++ View.fontSize12
                )
                (Element.text config.elapsedTime)
            ]
        , View.button
            []
            { onPress = View.enabled config.pressedStop
            , label = Icons.stopButton
            }
        ]
