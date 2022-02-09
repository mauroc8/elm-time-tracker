module View exposing
    ( BodyConfig
    , BodyContent
    , Emphasis
    , HeaderConfig
    , body
    , bodyWithNoRecords
    , bodyWithNoSearchResults
    , bodyWithRecords
    , deemphasize
    , footer
    , header
    , highlight
    , settings
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
import Lang exposing (Lang)
import Records exposing (Records)



-- EMPHASIS


type Emphasis
    = Highlight
    | Deemphasize


highlight =
    Highlight


deemphasize =
    Deemphasize


{-| -}
backgroundColor emphasis =
    Background.color <|
        if emphasis == Highlight then
            Colors.background.white

        else
            Colors.background.gray


dividerColor emphasis =
    if emphasis == Highlight then
        Colors.background.gray

    else
        Colors.background.white


interactionColor emphasis =
    if emphasis == Highlight then
        Colors.accent

    else
        Colors.text.gray



--- FONT SIZE


type FontSize
    = FontSize { lineHeight : Int } Int


fontSize14 =
    FontSize { lineHeight = 10 } 14


fontSize16 =
    FontSize { lineHeight = 12 } 16


fontSize24 =
    FontSize { lineHeight = 19 } 24


fontSize : FontSize -> List (Attribute msg)
fontSize (FontSize { lineHeight } value) =
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



--- HEADER


type alias HeaderConfig msg =
    { emphasis : Emphasis
    , searchQuery : String
    , onSearchQueryChange : String -> msg
    }


header ({ emphasis } as config) =
    Element.row
        [ Element.padding 16
        , Element.spacing 16
        , Border.widthEach { top = 0, right = 0, bottom = 1, left = 0 }
        , backgroundColor emphasis
        , Border.color (dividerColor emphasis)
        , Element.width Element.fill
        ]
        [ settingsButton config
        , searchInput config
        ]


settingsButton { emphasis } =
    Input.button
        [ Font.color (interactionColor emphasis)
        , Border.width 1
        , Border.color Colors.transparent
        ]
        { onPress = Nothing
        , label = Icons.options
        }


searchInput ({ emphasis, searchQuery, onSearchQueryChange } as config) =
    Input.search
        ([ Background.color (dividerColor emphasis)
         , Border.rounded 8
         , Font.color Colors.text.black
         , Border.width 0
         , Element.padding (10 - 1)
         , Border.width 1
         , Border.color Colors.transparent
         , Element.inFront (searchButton (searchButtonConfig config))
         ]
            ++ fontSize fontSize16
        )
        { onChange = onSearchQueryChange
        , text = searchQuery
        , placeholder =
            Just <|
                Input.placeholder
                    ([ Font.color Colors.text.lightGray
                     ]
                        ++ fontSize fontSize16
                    )
                    (Element.text "Search...")
        , label =
            Input.labelHidden "Search"
        }


type SearchButtonConfig clearSearchMsg
    = NotSearching
    | Searching clearSearchMsg


searchButtonConfig { searchQuery, onSearchQueryChange } =
    if String.isEmpty searchQuery then
        NotSearching

    else
        Searching (onSearchQueryChange "")


searchButton config =
    let
        attrs =
            [ Element.padding 10
            , Element.alignRight
            ]
    in
    case config of
        NotSearching ->
            Element.el
                ([ Font.color Colors.text.black ]
                    ++ attrs
                )
                Icons.search

        Searching msg ->
            Input.button
                ([ Font.color Colors.accent ]
                    ++ attrs
                )
                { onPress = Just msg
                , label =
                    Element.el
                        [ Element.Region.description "Clear search"
                        ]
                        Icons.x
                }



--- BODY


type BodyContent
    = NoRecords
    | NoSearchResults
    | WithRecords Records


bodyWithNoRecords =
    NoRecords


bodyWithNoSearchResults =
    NoSearchResults


bodyWithRecords =
    WithRecords


type alias BodyConfig =
    { content : BodyContent
    , emphasis : Emphasis
    }


body ({ content, emphasis } as config) =
    Element.el
        [ Element.padding 16
        , Element.width Element.fill
        , Element.height Element.fill
        , backgroundColor emphasis
        ]
        (bodyContent config)


bodyContent { content, emphasis } =
    case content of
        NoRecords ->
            Element.el
                ([ Element.centerX
                 , Element.centerY
                 , Font.color Colors.text.lighterGray
                 , backgroundColor emphasis
                 , Font.semiBold
                 ]
                    ++ fontSize fontSize16
                )
                (Element.text
                    "Press the Start button to create a record"
                )

        NoSearchResults ->
            Debug.todo ""

        WithRecords records ->
            Debug.todo ""



--- FOOTER


footer =
    Element.column
        [ Element.padding 24
        , Element.width Element.fill
        ]
        []



--- SETTINGS


settings =
    Element.column
        [ Element.width Element.fill
        , Element.height Element.fill
        , Element.padding 24
        , Element.spacing 24
        , Background.color Colors.background.gray
        ]
        [ settingsHeader
        , settingsBody
        , settingsFooter
        ]


settingsHeader =
    Element.el
        ([ Element.Region.heading 1
         , Font.semiBold
         ]
            ++ fontSize fontSize24
        )
        (Element.text "Settings")


settingsBody =
    Element.column
        [ Element.spacing 16
        , Element.width Element.fill
        ]
        [ settingsGroup
            [ Element.text "USA date notation (mm/dd/yy)"
            ]
        , settingsGroup
            [ Element.text "English"
            , Element.text "Español"
            ]
        ]


settingsGroup children =
    Element.column
        [ Border.rounded 8
        , Background.color Colors.background.white
        , Element.width Element.fill
        ]
        (List.map
            (Element.el
                ([ Element.padding 16
                 , Element.width Element.fill
                 ]
                    ++ fontSize fontSize14
                )
            )
            children
            |> List.intersperse
                (Element.el
                    [ Element.width Element.fill
                    , Element.height (Element.px 1)
                    , Background.color Colors.background.gray
                    ]
                    Element.none
                )
        )


settingsFooter =
    Element.row
        [ Element.alignBottom
        , Element.width Element.fill
        ]
        [ Element.text "Cancel"
        , Element.el [ Element.alignRight ] (Element.text "Done")
        ]
