module RecordList exposing
    ( Config(..)
    , RecordList
    , decoder
    , delete
    , empty
    , encode
    , fromList
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
import Json.Decode
import Json.Encode
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


fromList : List Record -> RecordList
fromList list =
    Dict.fromList
        (List.map (\record -> ( Time.posixToMillis record.startDateTime, record )) list)
        |> RecordList


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


decoder : Json.Decode.Decoder RecordList
decoder =
    Json.Decode.list Record.decoder
        |> Json.Decode.map fromList


encode : RecordList -> Json.Encode.Value
encode recordList =
    recordList
        |> toList
        |> Json.Encode.list Record.encode



---


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
        -- The dict is ordered by startDateTime. The order should be from latest to earliest startDateTime
        |> List.reverse
        -- The super intelligent garbage collector (for performance reasons there can't be many records)
        -- TODO: Check if 100 is too low
        |> List.take 100


push : Record -> RecordList -> RecordList
push record (RecordList records) =
    Dict.insert (Time.posixToMillis record.startDateTime) record records
        |> RecordList


delete : Record.Id -> RecordList -> RecordList
delete id (RecordList records) =
    Dict.filter (\_ record -> record.id /= id)
        records
        |> RecordList



--- VIEW


type Config msg
    = NoSearchResults
    | EmptyRecords
    | ManyRecords (List (Record.Config msg))


view : { a | viewport : View.Viewport, language : Text.Language, emphasis : Emphasis } -> Config msg -> Element msg
view ({ emphasis } as context) config =
    case config of
        EmptyRecords ->
            emptyState context
                { message = Text.PressTheStartButtonToCreateARecord
                }
                |> emptyBodyLayout emphasis

        NoSearchResults ->
            emptyState context
                { message = Text.NothingFound
                }
                |> emptyBodyLayout emphasis

        ManyRecords records ->
            records
                |> List.map (Record.view context)
                |> List.intersperse (View.recordListHorizontalDivider emphasis)
                |> bodyWithRecordsLayout emphasis


emptyState : { a | language : Text.Language } -> { message : Text.Text } -> Element msg
emptyState { language } { message } =
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
        ]
        [ Element.column
            [ Element.width Element.fill
            ]
            children
        , View.recordListHorizontalDivider emphasis
        ]
