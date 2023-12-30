module RecordList exposing
    ( RecordList
    , delete
    , duration
    , empty
    , find
    , fromDate
    , push
    , store
    , toList
    , view
    )

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes
import Json.Decode
import Json.Encode
import Levenshtein
import LocalStorage
import Record exposing (Record)
import Text exposing (Language)
import Time
import Ui
import Ui.HorizontalSeparator
import Utils.Date
import Utils.Duration
import Utils.Time



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


store : LocalStorage.Store RecordList
store =
    LocalStorage.store
        { key = "recordList"
        , encode = encode
        , decoder = decoder
        }


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
        -- Note: If we estimate 10 DOM nodes per record, 1000 hits the recommended maximum of 10.000
        |> List.take 1000


push : Record -> RecordList -> RecordList
push record (RecordList records) =
    Dict.insert (Time.posixToMillis record.startDateTime) record records
        |> RecordList


delete : Record.Id -> RecordList -> RecordList
delete id (RecordList records) =
    Dict.filter (\_ record -> record.id /= id)
        records
        |> RecordList


find : Record.Id -> RecordList -> Maybe Record.Record
find id recordList =
    recordList
        |> toList
        |> List.filter (\r -> r.id == id)
        |> List.head


splitFromDate : Time.Zone -> Time.Posix -> RecordList -> ( RecordList, RecordList )
splitFromDate timezone timestamp (RecordList records) =
    let
        today =
            Utils.Date.fromZoneAndPosix timezone timestamp
    in
    Dict.partition (\_ record -> Record.startDate timezone record == today)
        records
        |> Tuple.mapBoth RecordList RecordList


{-| Filters the records by date
-}
fromDate : Time.Zone -> Time.Posix -> RecordList -> RecordList
fromDate timezone timestamp recordList =
    splitFromDate timezone timestamp recordList |> Tuple.first


duration : RecordList -> Utils.Duration.Duration
duration recordList =
    recordList
        |> toList
        |> List.foldl (\record total -> total + record.durationInSeconds) 0
        |> Utils.Duration.fromSeconds



---


view ({ timezone, currentTime } as config) records =
    Ui.column
        [ Ui.style "max-width" "400px", Ui.fillWidth, Ui.fillHeight, Ui.spacing 32 ]
        (viewRecordsSplitByDate config records)


viewRecordsSplitByDate ({ timezone } as config) records =
    let
        mostRecentRecord =
            records |> toList |> List.head
    in
    case mostRecentRecord of
        Just record ->
            let
                ( recordsFromDate, recordsFromOtherDates ) =
                    splitFromDate timezone record.startDateTime records
            in
            viewRecordsFromDate config recordsFromDate
                :: viewRecordsSplitByDate config recordsFromOtherDates

        Nothing ->
            []


viewRecordsFromDate :
    { a
        | timezone : Time.Zone
        , currentTime : Time.Posix
        , language : Language
        , dateNotation : Utils.Date.Notation
        , onDelete : Record.Id -> msg
    }
    -> RecordList
    -> Html msg
viewRecordsFromDate ({ timezone, currentTime, language, dateNotation } as config) records =
    let
        timestamp =
            records
                |> toList
                |> List.head
                |> Maybe.map .startDateTime
                |> Maybe.withDefault currentTime

        date =
            Utils.Date.fromZoneAndPosix timezone

        text =
            Text.toHtml language

        dateLabel =
            Utils.Date.relativeDateLabel
                { today = date currentTime
                , dateNotation = dateNotation
                , date = date timestamp
                }

        totalDuration =
            duration records
                |> Utils.Duration.label
    in
    Ui.column
        [ Ui.fillWidth
        , Ui.spaceBetween
        , Ui.spacing 6
        , Ui.style "font-size" "1.25rem"
        ]
        ([ Ui.row
            [ Ui.fillWidth
            , Ui.spacing 16
            , Ui.centerY
            , Ui.style "font-weight" "bold"
            , Ui.style "font-size" "1rem"
            ]
            [ Ui.column [ Ui.style "text-transform" "uppercase" ] [ text dateLabel ]
            , Ui.filler []
            , Ui.column [] [ text totalDuration ]
            , Ui.box 12 []
            ]
         ]
            ++ (records
                    |> toList
                    |> List.reverse
                    |> List.map (\record -> Record.view config record)
               )
            |> List.intersperse
                (Ui.row [ Ui.spacing 16, Ui.fillWidth, Ui.centerY ]
                    [ Ui.HorizontalSeparator.render
                    , Html.div [ Html.Attributes.style "width" "12px" ] []
                    ]
                )
        )
