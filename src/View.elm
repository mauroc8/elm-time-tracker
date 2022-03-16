module View exposing
    ( BackgroundColor(..)
    , ButtonHandler
    , Emphasis(..)
    , Viewport(..)
    , button
    , columnWithHorizontalDivider
    , disabled
    , enabled
    , fromScreenWidth
    , horizontalDivider
    , linkLikeButton
    , overflowClickableRegion
    , recordListAlternativeBackgroundColor
    , recordListBackgroundColor
    , recordListButton
    , recordListHorizontalDivider
    , settingsBackgroundColor
    , settingsToggle
    , sidebarBackgroundColor
    )

import Browser
import Browser.Dom
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
import Text exposing (Language)



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
    Element.htmlAttribute <|
        Html.Attributes.style "transition" "background-color 0.23s ease-in"


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
        , backgroundTransition bgColor
        ]
        Element.none


columnWithHorizontalDivider : BackgroundColor -> List (Element.Attribute msg) -> List (Element msg) -> Element msg
columnWithHorizontalDivider bgColor attrs children =
    Element.column
        ([ Element.width Element.fill
         , Element.spacing 1
         , Background.color <|
            -- Divider color
            case bgColor of
                White ->
                    Colors.grayBackground

                Gray ->
                    Colors.darkGrayBackground
         ]
            ++ attrs
        )
        (children
            |> List.map
                (Element.el
                    [ Element.width Element.fill
                    , Background.color <|
                        -- Background color
                        case bgColor of
                            White ->
                                Colors.whiteBackground

                            Gray ->
                                Colors.grayBackground
                    ]
                )
        )



--- EMPHASIS


{-| This type describes which section of the default view will be _emphasized_ with a white
background. The other section will have a gray background.

Some buttons in the de-emphasized section will be disabled.

NOTE: Move to DefaultView.elm?

-}
type Emphasis
    = RecordList
    | Sidebar


recordListHorizontalDivider : Emphasis -> Element msg
recordListHorizontalDivider emphasis =
    let
        bgColor =
            case emphasis of
                RecordList ->
                    White

                Sidebar ->
                    Gray
    in
    horizontalDivider bgColor


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


{-| A button in the "RecordList" area of the UI (the search bar + the list of records)
-}
recordListButton :
    { emphasis : Emphasis
    , onClick : msg
    , label : Element msg
    }
    -> Element msg
recordListButton { emphasis, onClick, label } =
    button
        ([ Font.color (recordListButtonColor emphasis)
         , Border.width 1
         , Border.color Colors.transparent
         ]
         -- ++ overflowClickableRegion 8
        )
        { onPress =
            case emphasis of
                RecordList ->
                    enabled onClick

                Sidebar ->
                    disabled
        , label = label
        }


recordListButtonColor : Emphasis -> Element.Color
recordListButtonColor emphasis =
    case emphasis of
        RecordList ->
            Colors.accent

        Sidebar ->
            Colors.lighterGrayText


settingsBackgroundColor : List (Element.Attribute msg)
settingsBackgroundColor =
    [ backgroundColor Gray
    , backgroundTransition Gray
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
        ([ Font.color Colors.accent
         , if bold then
            Font.semiBold

           else
            Font.regular
         , Border.color Colors.transparent
         , Border.width 1
         ]
            ++ overflowClickableRegion 16
        )
        { onPress = Just onPress
        , label = Text.text16 language label
        }



--- Toggle (checkbox)


settingsToggle :
    { checked : Bool
    , onChange : Bool -> msg
    , label : Text.Text
    , language : Text.Language
    , padding : Int
    }
    -> Element msg
settingsToggle { checked, onChange, label, language, padding } =
    Input.checkbox
        [ Element.width Element.fill, Element.padding padding ]
        { onChange = onChange
        , checked = checked
        , label =
            Input.labelLeft [ Element.width Element.fill ]
                (Text.text14 language label
                    |> Element.el [ Element.centerY ]
                )
        , icon =
            \value ->
                if value then
                    Icons.toggleOn

                else
                    Icons.toggleOff
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
