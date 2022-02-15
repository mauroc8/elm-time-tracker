module RecordList exposing
    ( Config(..)
    , Records
    , empty
    , search
    , toList
    , view
    )

import Colors
import Dict exposing (Dict)
import Element exposing (Element)
import Element.Font
import Levenshtein
import Record exposing (Record)
import View exposing (Emphasis)



--- Records


type Records
    = Records (Dict Int Record)


empty : Records
empty =
    Records Dict.empty


search : String -> Records -> Records
search query (Records records) =
    let
        queryLength =
            String.length query
    in
    records
        |> Dict.filter
            (\key record ->
                Levenshtein.distance
                    query
                    (String.left
                        queryLength
                        record.description
                    )
                    <= (queryLength // 3)
            )
        |> Records


toList : Records -> List ( Int, Record )
toList (Records records) =
    Dict.toList records



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
                |> List.intersperse (View.horizontalDivider emphasis)
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
        , View.recordListBackgroundColor emphasis
        , Element.padding 16
        ]


bodyWithRecordsLayout : Emphasis -> List (Element msg) -> Element msg
bodyWithRecordsLayout emphasis =
    Element.column
        [ Element.width Element.fill
        , Element.height Element.fill
        , View.recordListBackgroundColor emphasis
        ]
