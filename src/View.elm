module View exposing
    ( BackgroundColor(..)
    , ButtonHandler
    , Emphasis(..)
    , Viewport(..)
    , button
    , disabled
    , enabled
    , fromScreenWidth
    , horizontalDivider
    , linkLikeButton
    , recordListAlternativeBackgroundColor
    , recordListBackgroundColor
    , recordListButton
    , recordListHorizontalDivider
    , settingsBackgroundColor
    , sidebarBackgroundColor
    , underlinedButton
    )

import Colors
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region
import Html.Attributes
import Text
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
            Colors.darkGrayBackground


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
    , backgroundTransition
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
    , backgroundTransition
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
            ++ overflowClickableRegion 6
        )
        { onPress =
            case emphasis of
                RecordList ->
                    enabled onClick

                Sidebar ->
                    disabled
        , label = label
        }
        |> Element.el []


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
    , backgroundTransition
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
            ++ overflowClickableRegion 12
        )
        { onPress = Just onPress
        , label = Text.text16 language label
        }


underlinedButton :
    { onPress : msg
    , label : Text.Text
    , language : Text.Language
    }
    -> Element msg
underlinedButton { onPress, label, language } =
    Input.button
        [ Font.underline
        , Font.color Colors.grayText
        ]
        { onPress = Just onPress
        , label = Text.text13 language label
        }


searchInput :
    { a
        | emphasis : Emphasis
        , searchQuery : String
        , changedSearchQuery : String -> msg
        , language : Text.Language
    }
    -> Element msg
searchInput ({ emphasis, searchQuery, changedSearchQuery, language } as config) =
    let
        padding =
            10

        border =
            1

        actualPadding =
            padding - border

        paddedSearchIconWidth =
            34
    in
    Input.search
        [ Background.color (recordListAlternativeBackgroundColor emphasis)
        , Border.rounded 8
        , Font.color Colors.blackText
        , Border.width 0
        , Element.inFront searchIcon
        , Element.paddingEach
            { top = actualPadding
            , left = paddedSearchIconWidth
            , right = actualPadding
            , bottom = actualPadding
            }
        , Border.width border
        , Border.color Colors.transparent
        , Element.inFront (clearButton language (searchButtonConfig config))
        , Font.size 16
        ]
        { onChange = changedSearchQuery
        , text = searchQuery
        , placeholder =
            Just <|
                Input.placeholder
                    [ Font.color Colors.lightGrayText ]
                    (Text.text16 language Text.SearchPlaceholder)
        , label =
            Input.labelHidden (Text.toString language Text.Search)
        }



type SearchButtonConfig clearSearchMsg
    = NotSearching
    | Searching clearSearchMsg

searchButtonConfig :
    { a
        | searchQuery : String
        , changedSearchQuery : String -> b
    }
    -> SearchButtonConfig b
searchButtonConfig { searchQuery, changedSearchQuery } =
    if String.isEmpty searchQuery then
        NotSearching

    else
        Searching (changedSearchQuery "")


searchIcon : Element msg
searchIcon =
    Element.el
        [ Font.color Colors.blackText
        , Element.padding 10
        , Element.alignLeft
        ]
        Icons.search


clearButton : Text.Language -> SearchButtonConfig msg -> Element msg
clearButton language config =
    let
        ( fontColor, onPress ) =
            case config of
                NotSearching ->
                    ( Colors.lighterGrayText, disabled )

                Searching msg ->
                    ( Colors.grayText, enabled msg )
    in
    button
        [ Element.padding 10
        , Element.alignRight
        , Font.color fontColor
        , Element.focused
            [ Font.color Colors.accent
            ]
        ]
        { onPress = onPress
        , label =
            Element.el
                [ Element.Region.description
                    (Text.toString language Text.ClearSearch)
                ]
                Icons.xButton
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
