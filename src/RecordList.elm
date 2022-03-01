module RecordList exposing
    ( Config(..)
    , RecordList
    , delete
    , empty
    , getById
    , push
    , search
    , toList
    , view
    )

import Colors
import Dict exposing (Dict)
import Dict.Extra
import Element exposing (Element)
import Element.Font
import Levenshtein
import Record exposing (Record)
import Text
import Time
import View exposing (Emphasis)



--- Records


{-| A list of records ordered by start time.
-}
type RecordList
    = RecordList (Dict Int Record)


empty : RecordList
empty =
    RecordList Dict.empty


search : String -> RecordList -> RecordList
search query (RecordList records) =
    if query == "" then
        RecordList records

    else
        records
            |> Dict.filter
                (\_ record ->
                    record.description
                        |> matchesSearchQuery query
                )
            |> RecordList


matchesSearchQuery : String -> String -> Bool
matchesSearchQuery query str =
    let
        queryLength =
            String.length query
    in
    Levenshtein.distance
        query
        (String.left
            queryLength
            str
        )
        <= (queryLength // 3)


toList : RecordList -> List Record
toList (RecordList records) =
    Dict.toList records
        |> List.map Tuple.second
        |> List.reverse


push : Record -> RecordList -> RecordList
push record (RecordList records) =
    Dict.insert (Time.posixToMillis record.startDateTime) record records
        |> RecordList


delete : Record.Id -> RecordList -> RecordList
delete id (RecordList records) =
    Dict.filter (\_ record -> record.id /= id)
        records
        |> RecordList


findById : Record.Id -> RecordList -> Maybe Record
findById id (RecordList records) =
    Dict.Extra.find
        (\_ record -> record.id == id)
        records
        |> Maybe.map Tuple.second



--- VIEW


type Config msg
    = NoSearchResults
    | EmptyRecords
    | ManyRecords (List (Record.Config msg))


view : { a | language : Text.Language, emphasis : Emphasis } -> Config msg -> Element msg
view { emphasis, language } config =
    case config of
        EmptyRecords ->
            emptyState
                { message = Text.PressTheStartButtonToCreateARecord
                , language = language
                }
                |> emptyBodyLayout emphasis

        NoSearchResults ->
            emptyState
                { message = Text.NothingFound
                , language = language
                }
                |> emptyBodyLayout emphasis

        ManyRecords records ->
            records
                |> List.map (Record.view emphasis)
                |> List.intersperse (View.recordListHorizontalDivider emphasis)
                |> bodyWithRecordsLayout emphasis


emptyState : { language : Text.Language, message : Text.Text } -> Element msg
emptyState { language, message } =
    Element.paragraph
        [ Element.centerY
        , Element.width Element.fill
        , Element.Font.center
        , Element.Font.color Colors.lighterGrayText
        , Element.Font.semiBold
        ]
        [ Text.text16 language message ]


emptyBodyLayout : Emphasis -> Element msg -> Element msg
emptyBodyLayout emphasis =
    Element.el
        [ Element.width Element.fill
        , Element.height Element.fill
        , Element.padding 16
        ]


bodyWithRecordsLayout : Emphasis -> List (Element msg) -> Element msg
bodyWithRecordsLayout emphasis children =
    Element.column
        [ Element.width Element.fill
        , Element.height Element.fill
        , Element.scrollbarY
        ]
        [ Element.column
            [ Element.width Element.fill
            ]
            children
        , View.recordListHorizontalDivider emphasis
        ]


getById : Record.Id -> RecordList -> Maybe Record.Record
getById id (RecordList records) =
    Dict.Extra.find (\_ record -> record.id == id) records
        |> Maybe.map Tuple.second
