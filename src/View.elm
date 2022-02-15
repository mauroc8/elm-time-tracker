module View exposing
    ( ButtonHandler
    , Emphasis(..)
    , button
    , disabled
    , enabled
    , fontSize14
    , fontSize16
    , fontSize24
    , horizontalDivider
    , linkLikeButton
    , overflowClickableRegion
    , recordListAlternativeBackgroundColor
    , recordListBackgroundColor
    , recordListButtonColor
    , sidebarBackgroundColor
    )

import Browser
import Colors
import DateTime
import Dict exposing (Dict)
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font exposing (Font)
import Element.Input as Input
import Element.Region
import Html exposing (Html)
import Html.Attributes
import Icons



--- Type disabled


{-| Not sure if necessary but I'm adding `aria-disabled` to buttons when `onPress = Nothing`
-}
type ButtonHandler msg
    = Enabled msg
    | Disabled


enabled : msg -> ButtonHandler msg
enabled msg =
    Enabled msg


disabled : ButtonHandler msg
disabled =
    Disabled


toMaybe : ButtonHandler msg -> Maybe msg
toMaybe pressHandler =
    case pressHandler of
        Enabled msg ->
            Just msg

        Disabled ->
            Nothing


button :
    List (Attribute msg)
    ->
        { onPress : ButtonHandler msg
        , label : Element msg
        }
    -> Element msg
button attrs config =
    let
        a11yAttrs =
            case config.onPress of
                Disabled ->
                    [ Element.htmlAttribute (Html.Attributes.attribute "aria-disabled" "true")
                    , Element.htmlAttribute (Html.Attributes.style "cursor" "default")
                    ]

                Enabled _ ->
                    []
    in
    Input.button
        (attrs ++ a11yAttrs)
        { onPress = toMaybe config.onPress
        , label = config.label
        }



--- EMPHASIS


{-| This type describes which section of the default view will be _emphasized_ with a white
background. The other section will have a gray background.

Some buttons in the de-emphasized section will be disabled.

-}
type Emphasis
    = RecordList
    | Sidebar


horizontalDivider : Emphasis -> Element msg
horizontalDivider emphasis =
    Element.el
        [ Element.width Element.fill
        , Element.height <| Element.px 1
        , Background.color (recordListAlternativeBackgroundColor emphasis)
        ]
        Element.none


recordListAlternativeBackgroundColor : Emphasis -> Element.Color
recordListAlternativeBackgroundColor emphasis =
    case emphasis of
        RecordList ->
            Colors.grayBackground

        Sidebar ->
            Colors.whiteBackground


recordListBackgroundColor : Emphasis -> Element.Attr decorative msg
recordListBackgroundColor emphasis =
    Background.color <|
        case emphasis of
            RecordList ->
                Colors.whiteBackground

            Sidebar ->
                Colors.grayBackground


sidebarBackgroundColor : Emphasis -> Element.Attr decorative msg
sidebarBackgroundColor emphasis =
    Background.color <|
        case emphasis of
            RecordList ->
                Colors.grayBackground

            Sidebar ->
                Colors.whiteBackground


recordListButtonColor : Emphasis -> Element.Color
recordListButtonColor emphasis =
    case emphasis of
        RecordList ->
            Colors.accent

        Sidebar ->
            Colors.grayText



--- Utils


{-| Makes the clickable region of an element larger without affecting the layout.

This makes buttons easier to click on mobile devices.

Shouldn't use this on elements with padding.

-}
overflowClickableRegion : Int -> List (Attribute msg)
overflowClickableRegion value =
    [ Element.htmlAttribute (Html.Attributes.style "padding" <| String.fromInt value ++ "px")
    , Element.htmlAttribute (Html.Attributes.style "margin" <| "-" ++ String.fromInt value ++ "px")
    ]



--- Components


{-| The buttons "Done" and "Cancel" that can be seen in settings and in edit mode.
-}
linkLikeButton :
    { onPress : msg
    , label : String
    , bold : Bool
    }
    -> Element msg
linkLikeButton { onPress, label, bold } =
    Input.button
        ([ Font.color Colors.accent
         , if bold then
            Font.semiBold

           else
            Font.regular
         ]
            ++ overflowClickableRegion 16
            ++ fontSize16
        )
        { onPress = Just onPress
        , label = Element.text label
        }



--- FONT SIZE


fontSize14 : List (Attribute msg)
fontSize14 =
    fontSize { lineHeight = 10, value = 14 }


fontSize16 : List (Attribute msg)
fontSize16 =
    fontSize { lineHeight = 12, value = 16 }


fontSize24 : List (Attribute msg)
fontSize24 =
    fontSize { lineHeight = 19, value = 24 }


fontSize :
    { a
        | lineHeight : Int
        , value : Int
    }
    -> List (Element.Attr () msg)
fontSize { lineHeight, value } =
    [ Font.size value
    , lineHeightAttr lineHeight
    ]


lineHeightAttr : Int -> Attribute msg
lineHeightAttr value =
    Element.htmlAttribute
        (Html.Attributes.style
            "line-height"
            (String.fromInt value ++ "px")
        )
