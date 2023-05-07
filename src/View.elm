module View exposing
    ( BackgroundColor(..)
    , Emphasis(..)
    , PressEvent
    , Viewport(..)
    , accentButton
    , button
    , cancelConfirmButtons
    , disableIf
    , disabled
    , enabled
    , fromScreenWidth
    , grayBackgroundStyles
    , grayGradientBackgroundStyles
    , input
    , horizontalDivider
    , linkLikeButton
    , linkLikeButtonSmall
    , modalContent
    , recordListAlternativeBackgroundColor
    , recordListBackgroundColor
    , recordListHorizontalDivider
    , sidebarBackgroundColor
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



--- Button


{-| Not sure if necessary but I'm using `aria-disabled` (instead of `disabed`) in buttons
when `onPress = Nothing`
-}
type PressEvent msg
    = Enabled msg
    | Disabled


enabled : msg -> PressEvent msg
enabled msg =
    Enabled msg


disabled : PressEvent msg
disabled =
    Disabled


disableIf : Bool -> PressEvent msg -> PressEvent msg
disableIf bool handler =
    case bool of
        True ->
            Disabled

        False ->
            handler


button :
    List (Attribute msg)
    ->
        { onPress : PressEvent msg
        , label : Element msg
        }
    -> Element msg
button attrs config =
    case config.onPress of
        Disabled ->
            Element.el
                (Element.htmlAttribute (Html.Attributes.attribute "aria-disabled" "true")
                    :: attrs
                )
                config.label

        Enabled msg ->
            Input.button
                attrs
                { onPress = Just msg
                , label = config.label
                }


input attrs config =
    let
        placeholderStyles =
            [ Font.semiBold
            , Font.color Colors.lightGrayText
            ]
    in
    case config.onChange of
        Disabled ->
            Element.el
                (Element.htmlAttribute (Html.Attributes.attribute "aria-disabled" "true")
                    :: attrs
                )
                (if config.text == "" then
                    config.placeholder
                        |> Maybe.withDefault (Element.text "")
                        |> Element.el placeholderStyles

                 else
                    Element.text config.text
                )

        Enabled msg ->
            Input.text
                attrs
                { onChange = msg
                , text = config.text
                , label = config.label
                , placeholder =
                    config.placeholder
                        |> Maybe.map (Input.placeholder placeholderStyles)
                }



--- Background Color


type BackgroundColor
    = Gray
    | White


backgroundColor : BackgroundColor -> Attribute msg
backgroundColor color =
    Background.color <|
        case color of
            White ->
                Colors.whiteBackground

            Gray ->
                Colors.grayBackground


backgroundTransition : Attribute msg
backgroundTransition =
    Element.htmlAttribute <|
        Html.Attributes.style "transition" "background-color 0.19s linear"


horizontalDivider : BackgroundColor -> Element msg
horizontalDivider bgColor =
    Element.el
        [ Element.width Element.fill
        , Element.height <| Element.px 1
        , Background.color <|
            case bgColor of
                White ->
                    Colors.grayBackground

                Gray ->
                    Colors.darkGrayBackground
        , backgroundTransition
        ]
        Element.none



--- EMPHASIS


{-| This type describes which section of the main view will be _emphasized_ with a white
background. The other section will have a gray background.
-}
type Emphasis
    = RecordList
    | TopBar


recordListHorizontalDivider : Emphasis -> Element msg
recordListHorizontalDivider emphasis =
    let
        bgColor =
            case emphasis of
                RecordList ->
                    White

                TopBar ->
                    Gray
    in
    horizontalDivider bgColor


recordListAlternativeBackgroundColor : Emphasis -> Element.Color
recordListAlternativeBackgroundColor emphasis =
    case emphasis of
        RecordList ->
            Colors.grayBackground

        TopBar ->
            Colors.darkGrayBackground


recordListBackgroundColor : Emphasis -> List (Element.Attribute msg)
recordListBackgroundColor emphasis =
    let
        color =
            case emphasis of
                RecordList ->
                    White

                TopBar ->
                    Gray
    in
    [ backgroundColor color
    , backgroundTransition
    ]


sidebarBackgroundColor : Emphasis -> List (Element.Attribute msg)
sidebarBackgroundColor emphasis =
    case emphasis of
        RecordList ->
            grayBackgroundStyles

        TopBar ->
            whiteBackgroundStyles


{-| A button with focus styles and accent color
-}
accentButton :
    { onPress : PressEvent msg
    , label : Element msg
    }
    -> Element msg
accentButton { onPress, label } =
    button
        ([ Font.color (accentButtonColor onPress)
         , Border.width 1
         , Border.color Colors.transparent
         ]
            ++ overflowClickableRegion 6
        )
        { onPress = onPress
        , label = label
        }
        |> Element.el []


accentButtonColor : PressEvent msg -> Element.Color
accentButtonColor onPress =
    case onPress of
        Disabled ->
            Colors.lighterGrayText

        Enabled _ ->
            Colors.accent


whiteBackgroundStyles : List (Element.Attribute msg)
whiteBackgroundStyles =
    [ backgroundColor White
    , backgroundTransition
    ]


grayBackgroundStyles : List (Element.Attribute msg)
grayBackgroundStyles =
    [ backgroundColor Gray
    , backgroundTransition
    ]


grayGradientBackgroundStyles : List (Element.Attribute msg)
grayGradientBackgroundStyles =
    [ Background.color Colors.darkGrayBackground
    , Background.gradient
        { angle = pi
        , steps =
            [ Element.rgba 0 0 0 0
            , Element.rgba 0 0 0 0
            , Element.rgba 0 0 0 0
            , Element.rgba 0 0 0 0.3
            ]
        }
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


{-| The footer of the modal, that has two buttons. The left one is a "Cancel" button
and the right one confirms an operation.
-}
cancelConfirmButtons { onCancel, onConfirm, confirmText, language, viewport } =
    Element.row
        [ Element.alignBottom
        , Element.width Element.fill
        , Element.spacing 32
        ]
        [ linkLikeButton
            { onPress = onCancel
            , label = Text.Cancel
            , language = language
            , bold = False
            }
            |> Element.el
                [ case viewport of
                    Mobile ->
                        Utils.emptyAttribute

                    Desktop ->
                        Element.alignRight
                ]
        , linkLikeButton
            { onPress = onConfirm
            , label = confirmText
            , language = language
            , bold = True
            }
            |> Element.el
                [ Element.alignRight ]
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
    { onPress : PressEvent msg
    , label : Text.Text
    , language : Text.Language
    }
    -> Element msg
linkLikeButtonSmall { onPress, label, language } =
    button
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
