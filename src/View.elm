module View exposing
    ( BackgroundColor(..)
    , ButtonHandler
    , Emphasis(..)
    , button
    , disabled
    , enabled
    , fontSize12
    , fontSize13
    , fontSize14
    , fontSize16
    , fontSize24
    , horizontalDividerFromColor
    , horizontalDividerFromEmphasis
    , linkLikeButton
    , overflowClickableRegion
    , recordListAlternativeBackgroundColor
    , recordListBackgroundColor
    , recordListButtonColor
    , settingsBackgroundColor
    , settingsToggle
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



--- Button


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
        ( extraAttrs, onPress ) =
            case config.onPress of
                Disabled ->
                    ( [ Element.htmlAttribute (Html.Attributes.attribute "aria-disabled" "true")
                      , Element.htmlAttribute (Html.Attributes.style "cursor" "default")
                      ]
                    , Nothing
                    )

                Enabled msg ->
                    ( [], Just msg )
    in
    Input.button
        (attrs ++ extraAttrs)
        { onPress = onPress
        , label = config.label
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


backgroundTransition : BackgroundColor -> Attribute msg
backgroundTransition color =
    let
        easing =
            case color of
                Gray ->
                    "ease-in"

                White ->
                    "ease-out"
    in
    Element.htmlAttribute <|
        Html.Attributes.style "transition" <|
            "background-color 0.23s "
                ++ easing


horizontalDividerFromColor : BackgroundColor -> Element msg
horizontalDividerFromColor color =
    Element.el
        [ Element.width Element.fill
        , Element.height <| Element.px 1
        , backgroundColor color
        , backgroundTransition color
        ]
        Element.none



--- EMPHASIS


{-| This type describes which section of the default view will be _emphasized_ with a white
background. The other section will have a gray background.

Some buttons in the de-emphasized section will be disabled.

-}
type Emphasis
    = RecordList
    | Sidebar


horizontalDividerFromEmphasis : Emphasis -> Element msg
horizontalDividerFromEmphasis emphasis =
    let
        color =
            case emphasis of
                RecordList ->
                    Gray

                Sidebar ->
                    White
    in
    horizontalDividerFromColor color


recordListAlternativeBackgroundColor : Emphasis -> Element.Color
recordListAlternativeBackgroundColor emphasis =
    case emphasis of
        RecordList ->
            Colors.grayBackground

        Sidebar ->
            Colors.whiteBackground


recordListBackgroundColor : Emphasis -> List (Element.Attribute msg)
recordListBackgroundColor emphasis =
    let
        color =
            case emphasis of
                RecordList ->
                    White

                Sidebar ->
                    Gray
    in
    [ backgroundColor color
    , backgroundTransition color
    ]


sidebarBackgroundColor : Emphasis -> List (Element.Attribute msg)
sidebarBackgroundColor emphasis =
    let
        color =
            case emphasis of
                RecordList ->
                    Gray

                Sidebar ->
                    White
    in
    [ backgroundColor color
    , backgroundTransition color
    ]


recordListButtonColor : Emphasis -> Element.Color
recordListButtonColor emphasis =
    case emphasis of
        RecordList ->
            Colors.accent

        Sidebar ->
            Colors.grayText


settingsBackgroundColor : List (Element.Attribute msg)
settingsBackgroundColor =
    [ backgroundColor Gray
    , backgroundTransition Gray
    ]



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



--- Link


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



--- Toggle (checkbox)


settingsToggle :
    { checked : Bool
    , onChange : Bool -> msg
    , label : String
    , padding : Int
    }
    -> Element msg
settingsToggle { checked, onChange, label, padding } =
    Input.checkbox
        [ Element.width Element.fill, Element.padding padding ]
        { onChange = onChange
        , checked = checked
        , label =
            Input.labelLeft [ Element.width Element.fill ]
                (Element.text label
                    |> Element.el [ Element.centerY ]
                )
        , icon =
            \value ->
                if value then
                    Icons.toggleOn

                else
                    Icons.toggleOff
        }



--- FONT SIZE


fontSize12 : List (Attribute msg)
fontSize12 =
    fontSize { lineHeight = 9, value = 12 }


fontSize13 : List (Attribute msg)
fontSize13 =
    fontSize { lineHeight = 11, value = 13 }


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
    -> List (Attribute msg)
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
