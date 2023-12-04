module Ui exposing
    ( Viewport(..)
    , accentButton
    , blackBackgroundStyles
    , fromScreenWidth
    , linkLikeButton
    , linkLikeButtonSmall
    , modalContent
    , whiteBackgroundStyles
    )

import Colors
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events
import Element.Font as Font
import Element.Input as Input
import Element.Region
import Html.Attributes
import Text
import Utils


backgroundTransition : Attribute msg
backgroundTransition =
    Element.htmlAttribute <|
        Html.Attributes.style "transition" "background-color 0.19s linear"



--- EMPHASIS


{-| A button with focus styles and accent color
-}
accentButton :
    { color : Element.Color
    , onPress : Maybe msg
    , label : Element msg
    }
    -> Element msg
accentButton { color, onPress, label } =
    Input.button
        ([ Font.color color
         , Border.width 1
         , Border.color Colors.transparent
         ]
            ++ overflowClickableRegion 6
        )
        { onPress = onPress
        , label = label
        }


whiteBackgroundStyles : List (Element.Attribute msg)
whiteBackgroundStyles =
    [ Background.color Colors.whiteBackground
    , Font.color Colors.blackText
    , backgroundTransition
    ]


blackBackgroundStyles : List (Element.Attribute msg)
blackBackgroundStyles =
    [ Background.color Colors.blackText
    , Font.color Colors.whiteBackground
    , backgroundTransition
    ]


modalContent { viewport, header, body, footer, onClose } =
    let
        ( padding, spacing ) =
            case viewport of
                Mobile ->
                    ( 24, 24 )

                Desktop ->
                    ( 48, 32 )

        content =
            Element.column
                ([ Element.width
                    (case viewport of
                        Mobile ->
                            Element.fill

                        Desktop ->
                            Element.maximum 500 Element.fill
                    )
                 , Element.centerX
                 , Element.height
                    (case viewport of
                        Mobile ->
                            Element.fill

                        Desktop ->
                            Element.shrink
                    )
                 , Element.padding padding
                 , Element.spacing (spacing * 2)
                 , Border.rounded 16
                 ]
                    ++ whiteBackgroundStyles
                )
                [ Element.column
                    [ Element.width Element.fill
                    , Element.spacing spacing
                    ]
                    ([ header
                        |> Element.el
                            [ Element.Region.heading 1
                            , Font.semiBold
                            ]
                     ]
                        ++ body
                    )
                , footer
                ]
    in
    Element.column
        [ Element.width Element.fill
        , Element.height Element.fill
        , Element.padding 32
        , Element.behindContent
            (Element.el
                [ Element.width Element.fill
                , Element.height Element.fill
                , Background.color (Element.rgba 0 0 0 0.23)
                , Element.Events.onClick onClose
                ]
                Element.none
            )
        ]
        [ content
        ]



--- Utils


{-| Makes the clickable region of an element larger without affecting the layout.

This makes buttons easier to click on mobile devices.

Shouldn't use this on elements with padding or "width fill".

-}
overflowClickableRegion : Int -> List (Attribute msg)
overflowClickableRegion value =
    [ Element.htmlAttribute (Html.Attributes.style "padding" <| String.fromInt value ++ "px")
    , Element.htmlAttribute (Html.Attributes.style "margin" <| "-" ++ String.fromInt value ++ "px")
    ]



--- Link


{-| The buttons "Done" and "Cancel" that can be seen in settings and in edit mode.
-}
linkLikeButton :
    { onPress : msg
    , bold : Bool
    , label : Text.Text
    , language : Text.Language
    }
    -> Element msg
linkLikeButton { onPress, label, language, bold } =
    Input.button
        ([ Font.color
            (case label of
                Text.Delete ->
                    Colors.red

                _ ->
                    Colors.accent
            )
         , if bold then
            Font.semiBold

           else
            Font.regular
         , Border.color Colors.transparent
         , Border.width 1
         ]
            ++ overflowClickableRegion 12
        )
        { onPress = Just onPress
        , label = Text.text16 language label
        }


linkLikeButtonSmall :
    { onPress : Maybe msg
    , label : Text.Text
    , language : Text.Language
    }
    -> Element msg
linkLikeButtonSmall { onPress, label, language } =
    Input.button
        ([ Font.color Colors.accent
         , Border.width 1
         , Border.color Colors.transparent
         , Element.focused
            [ Border.color Colors.accent
            ]
         ]
            ++ overflowClickableRegion 8
        )
        { onPress = onPress
        , label = Text.text13 language label
        }



--- Viewport


type Viewport
    = Desktop
    | Mobile


fromScreenWidth : Int -> Viewport
fromScreenWidth screenWidth =
    if screenWidth < 650 then
        Mobile

    else
        Desktop
