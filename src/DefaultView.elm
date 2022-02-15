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
import Settings exposing (Language)
import Sidebar
import View exposing (Emphasis)


type alias Config msg =
    { emphasis : Emphasis
    , searchQuery : String
    , records : RecordList.Config msg
    , sidebar : Sidebar.Config msg
    , clickedSettings : msg
    , changedSearchQuery : String -> msg
    }


view : Config msg -> Element msg
view ({ emphasis, searchQuery, records, sidebar, clickedSettings, changedSearchQuery } as config) =
    Element.column
        [ Element.width Element.fill
        , Element.height Element.fill
        ]
        [ -- Search
          searchSection config
            |> withHeaderLayout
            |> withHorizontalDivider emphasis

        -- RecordList
        , RecordList.view config records

        -- Sidebar
        , Sidebar.view sidebar
            |> withFooterLayout emphasis
        ]



--- SEARCH


searchSection : Config msg -> Element msg
searchSection ({ emphasis, searchQuery, changedSearchQuery, clickedSettings } as config) =
    Element.row
        [ Element.spacing 16
        , View.recordListBackgroundColor emphasis
        , Element.width Element.fill
        ]
        [ settingsButton config
        , searchInput config
        ]


withHeaderLayout : Element msg -> Element msg
withHeaderLayout =
    Element.el
        [ Element.padding 16
        , Element.width Element.fill
        ]


withHorizontalDivider : Emphasis -> Element msg -> Element msg
withHorizontalDivider emphasis el =
    Element.column
        [ Element.width Element.fill
        ]
        [ el
        , View.horizontalDivider emphasis
        ]


withFooterLayout : Emphasis -> Element msg -> Element msg
withFooterLayout emphasis =
    Element.el
        [ Element.width Element.fill
        , Element.padding 24
        , View.sidebarBackgroundColor emphasis
        ]


settingsButton :
    { a
        | emphasis : Emphasis
        , clickedSettings : msg
    }
    -> Element msg
settingsButton { emphasis, clickedSettings } =
    Input.button
        ([ Font.color (View.recordListButtonColor emphasis)
         , Border.width 1
         , Border.color Colors.transparent
         ]
            ++ View.overflowClickableRegion 12
        )
        { onPress = Just clickedSettings
        , label = Icons.options
        }


searchInput :
    { a
        | emphasis : Emphasis
        , searchQuery : String
        , changedSearchQuery : String -> msg
    }
    -> Element msg
searchInput ({ emphasis, searchQuery, changedSearchQuery } as config) =
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
        ([ Background.color (View.recordListAlternativeBackgroundColor emphasis)
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
         , Element.inFront (clearButton (searchButtonConfig config))
         ]
            ++ View.fontSize16
        )
        { onChange = changedSearchQuery
        , text = searchQuery
        , placeholder =
            Just <|
                Input.placeholder
                    ([ Font.color Colors.lightGrayText
                     ]
                        ++ View.fontSize16
                    )
                    (Element.text "Search…")
        , label =
            Input.labelHidden "Search"
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


clearButton : SearchButtonConfig msg -> Element msg
clearButton config =
    let
        ( fontColor, onPress ) =
            case config of
                NotSearching ->
                    ( Colors.lighterGrayText, View.disabled )

                Searching msg ->
                    ( Colors.accent, View.enabled msg )
    in
    View.button
        [ Element.padding 10
        , Element.alignRight
        , Font.color fontColor
        ]
        { onPress = onPress
        , label =
            Element.el
                [ Element.Region.description "Clear search"
                ]
                Icons.xButton
        }
