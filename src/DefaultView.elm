module DefaultView exposing (Config, view)

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
import RecordList
import Settings
import Sidebar
import Text exposing (Language)
import View exposing (Emphasis)


type alias Config msg =
    { emphasis : Emphasis
    , searchQuery : String
    , records : RecordList.Config msg
    , sidebar : Sidebar.Config msg
    , clickedSettings : msg
    , changedSearchQuery : String -> msg
    , language : Text.Language
    , viewport : View.Viewport
    }


view : Config msg -> Element msg
view ({ emphasis, records, sidebar, viewport } as config) =
    let
        viewRecordListWithSearch =
            [ -- Search
              searchSection config
                |> withHeaderLayout config
                |> withHorizontalDivider emphasis

            -- RecordList
            , RecordList.view config records
            ]

        viewSidebar =
            [ Sidebar.view sidebar
                |> Element.el
                    [ Element.width (Element.fill |> Element.maximum 600)
                    , Element.padding 24
                    , Element.centerX
                    ]
                |> Element.el
                    (Element.width Element.fill :: View.sidebarBackgroundColor emphasis)
            ]
    in
    case viewport of
        View.Mobile ->
            Element.column
                [ Element.width Element.fill
                , Element.height Element.fill
                ]
                (Element.column
                    [ Element.width Element.fill
                    , Element.height Element.fill
                    , Element.scrollbarX
                    ]
                    viewRecordListWithSearch
                    :: viewSidebar
                )

        View.Desktop ->
            Element.column
                [ Element.width Element.fill
                , Element.height Element.fill
                , Element.scrollbarX
                ]
                (viewSidebar
                    ++ [ Element.column
                            [ Element.width (Element.fill |> Element.maximum 600)
                            , Element.centerX
                            , Element.height Element.fill
                            ]
                            viewRecordListWithSearch
                       ]
                )



--- SEARCH


searchSection : Config msg -> Element msg
searchSection ({ emphasis, searchQuery, changedSearchQuery, clickedSettings, viewport } as config) =
    Element.row
        [ Element.spacing 16
        , Element.width Element.fill
        ]
    <|
        case viewport of
            View.Mobile ->
                [ settingsButton config
                , searchInput config
                ]

            View.Desktop ->
                [ searchInput config
                , settingsButton config
                ]


withHeaderLayout : { config | emphasis : View.Emphasis, viewport : View.Viewport } -> Element msg -> Element msg
withHeaderLayout { emphasis, viewport } =
    let
        padding =
            case viewport of
                View.Mobile ->
                    Element.padding 16

                View.Desktop ->
                    Element.paddingXY 0 16
    in
    Element.el
        [ padding
        , Element.width Element.fill
        ]


withHorizontalDivider : Emphasis -> Element msg -> Element msg
withHorizontalDivider emphasis el =
    Element.column
        [ Element.width Element.fill
        ]
        [ el
        , View.recordListHorizontalDivider emphasis
        ]


settingsButton :
    { a
        | emphasis : Emphasis
        , clickedSettings : msg
    }
    -> Element msg
settingsButton { emphasis, clickedSettings } =
    View.recordListButton
        { emphasis = emphasis
        , onClick = clickedSettings
        , label = Icons.options
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
        [ Background.color (View.recordListAlternativeBackgroundColor emphasis)
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
                    ( Colors.lighterGrayText, View.disabled )

                Searching msg ->
                    ( Colors.grayText, View.enabled msg )
    in
    View.button
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
