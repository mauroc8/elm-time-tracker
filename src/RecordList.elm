module RecordList exposing
    ( RecordList
    , decoder
    , delete
    , empty
    , encode
    , push
    , search
    , toList
    , view
    )

import Colors
import Dict exposing (Dict)
import Element exposing (Element)
import Element.Font
import Json.Decode
import Json.Encode
import Levenshtein
import Record exposing (Record)
import Text
import Time
import Utils.Date
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
        -- Note: If we estimate 20 DOM nodes per record, 500 hits the recommended maximum of 10.000
        |> List.take 500


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


view :
    { a
        | viewport : View.Viewport
        , language : Text.Language
        , emphasis : Emphasis
        , records : RecordList
        , clickedDeleteButton : Record.Id -> msg
        , currentTime : Time.Posix
        , dateNotation : Utils.Date.Notation
        , timeZone : Time.Zone
    }
    -> Element msg
view ({ emphasis, records } as config) =
    case toList records of
        [] ->
            emptyState config
                { message =
                    case emphasis of
                        View.RecordList ->
                            Text.PressTheStartButtonToCreateARecord

                        View.Sidebar ->
                            Text.String ""
                }
                |> emptyBodyLayout

        recordsList ->
            recordsList
                |> List.map (Record.view config)
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


emptyBodyLayout : Element msg -> Element msg
emptyBodyLayout =
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
