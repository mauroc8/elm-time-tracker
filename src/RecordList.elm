module RecordList exposing
    ( RecordList
    , delete
    , empty
    , find
    , push
    , store
    , toList
    , view
    , viewSummary
    )

import Calendar
import Colors
import Dict exposing (Dict)
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Icons
import Json.Decode
import Json.Encode
import Levenshtein
import LocalStorage
import Record exposing (Record)
import Text
import Time
import Ui
import Utils.Date
import Utils.Duration



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



--- VIEW


view :
    { a
        | viewport : Ui.Viewport
        , language : Text.Language
        , records : RecordList
        , clickedDeleteButton : Record.Id -> msg
        , currentTime : Time.Posix
        , dateNotation : Utils.Date.Notation
        , timeZone : Time.Zone
        , modalIsOpen : Bool
    }
    -> Element msg
view ({ records } as config) =
    case toList records of
        [] ->
            emptyState config
                { message = Text.PressTheStartButtonToCreateARecord
                }
                |> emptyBodyLayout

        recordsList ->
            recordsList
                |> List.map (Record.view config)
                |> (\list -> list ++ [ information config ])
                |> Element.column
                    [ Element.width Element.fill
                    , Element.height Element.fill
                    ]


information { language } =
    Element.paragraph
        [ Element.spacing 8
        , Element.paddingXY 0 16
        , Element.width Element.fill
        , Element.Font.color Colors.grayText
        ]
        [ Text.text13 language Text.CommentAboutStorage ]


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


viewSummary { viewport, clickedSettings, records, timeZone, currentTime, language } =
    let
        padding =
            case viewport of
                Ui.Mobile ->
                    Element.padding 16

                Ui.Desktop ->
                    Element.paddingXY 0 16

        settingsButton =
            Ui.accentButton
                { onPress = Just clickedSettings
                , label = Icons.options
                , color = Colors.accent
                }

        today =
            Utils.Date.fromZoneAndPosix timeZone currentTime

        todayRecords =
            records
                |> toList
                |> List.filter (\record -> Record.startDate timeZone record == today)

        recordListDuration recordList =
            recordList
                |> List.foldl (\record total -> total + record.durationInSeconds) 0
                |> Utils.Duration.fromSeconds

        todaysTotal =
            summaryCard language
                Text.TodaysTotal
                (Utils.Duration.label (recordListDuration todayRecords))

        todaysWeekday =
            Calendar.getWeekday today
                |> Utils.Date.weekdayToInt

        thisWeeksRecords =
            records
                |> toList
                |> List.filter
                    (\record ->
                        let
                            recordDate =
                                Record.startDate timeZone record

                            dateDiff =
                                Calendar.getDayDiff recordDate today
                        in
                        0
                            <= dateDiff
                            && dateDiff
                            <= todaysWeekday
                    )

        thisWeeksTotal =
            summaryCard language
                Text.ThisWeeksTotal
                (Utils.Duration.label (recordListDuration thisWeeksRecords))
    in
    Element.el
        [ padding
        , Element.width Element.fill
        ]
        (Element.row
            [ Element.spacing 16
            , Element.width Element.fill
            ]
            [ todaysTotal
                |> Element.el [ Element.centerX ]
            , thisWeeksTotal
                |> Element.el [ Element.centerX ]
            , settingsButton
                |> Element.el [ Element.alignRight ]
            ]
        )


summaryCard language label value =
    Element.column
        [ Element.spacing 8
        , Element.Background.color Colors.darkGrayBackground
        , Element.padding 12
        , Element.Border.rounded 8
        , Element.width (Element.minimum 160 Element.shrink)
        ]
        [ Text.text12 language label
            |> Element.el [ Element.Font.semiBold ]
        , Text.text14 language value
        ]
