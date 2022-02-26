module RecordList exposing
    ( Config(..)
    , RecordList
    , delete
    , empty
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
    records
        |> Dict.filter
            (\key record ->
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


view : { a | emphasis : Emphasis } -> Config msg -> Element msg
view { emphasis } config =
    case config of
        EmptyRecords ->
            emptyState
                { message = "Press the Start button to create a record"
                }
                |> emptyBodyLayout emphasis

        NoSearchResults ->
            emptyState
                { message = "Nothing found"
                }
                |> emptyBodyLayout emphasis

        ManyRecords records ->
            records
                |> List.map Record.view
                |> List.intersperse (View.horizontalDividerFromEmphasis emphasis)
                |> bodyWithRecordsLayout emphasis


emptyState : { a | message : String } -> Element msg
emptyState { message } =
    Element.paragraph
        ([ Element.centerY
         , Element.width Element.fill
         , Element.Font.center
         , Element.Font.color Colors.lighterGrayText
         , Element.Font.semiBold
         ]
            ++ View.fontSize16
        )
        [ Element.text message ]


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
        , View.horizontalDividerFromEmphasis emphasis
        ]
