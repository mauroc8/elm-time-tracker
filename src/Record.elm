module Record exposing
    ( Id
    , Record
    , decoder
    , encode
    , fromStartAndCurrentTime
    , startDate
    , view
    )

import Calendar
import Clock
import Colors
import CreateRecord
import Element exposing (Element)
import Element.Font
import Element.Keyed
import Icons
import Json.Decode
import Json.Encode
import Text
import Time
import Ui
import Utils.Date
import Utils.Duration
import Utils.Time


posixDecoder : Json.Decode.Decoder Time.Posix
posixDecoder =
    Json.Decode.int |> Json.Decode.map Time.millisToPosix


decodePosix : Time.Posix -> Json.Encode.Value
decodePosix posix =
    Json.Encode.int (Time.posixToMillis posix)



--- ID


type Id
    = Id Int


idDecoder : Json.Decode.Decoder Id
idDecoder =
    Json.Decode.int |> Json.Decode.map Id


encodeId : Id -> Json.Encode.Value
encodeId (Id id) =
    Json.Encode.int id



--- RECORD


type alias Record =
    { id : Id
    , startDateTime : Time.Posix
    , durationInSeconds : Int
    }


decoder : Json.Decode.Decoder Record
decoder =
    Json.Decode.map3 Record
        (Json.Decode.field "id" idDecoder)
        (Json.Decode.field "startDateTime" posixDecoder)
        (Json.Decode.field "durationInSecods" Json.Decode.int)


fromStartAndCurrentTime : Time.Posix -> Time.Posix -> Record
fromStartAndCurrentTime now start =
    { id = Id (Time.posixToMillis now)
    , startDateTime = start
    , durationInSeconds = (Time.posixToMillis now - Time.posixToMillis start) // 1000
    }


startTime : Time.Zone -> Record -> Clock.Time
startTime zone record =
    Utils.Time.fromZoneAndPosix zone record.startDateTime


startDate : Time.Zone -> Record -> Calendar.Date
startDate zone record =
    Utils.Date.fromZoneAndPosix zone record.startDateTime


endTime : Time.Zone -> Record -> Clock.Time
endTime zone record =
    let
        zonedStartTime =
            Utils.Date.toZonedPosix zone record.startDateTime
    in
    Clock.fromPosix
        (Time.millisToPosix
            (Time.posixToMillis zonedStartTime
                + record.durationInSeconds
                * 1000
            )
        )


encode : Record -> Json.Encode.Value
encode record =
    Json.Encode.object
        [ ( "id", encodeId record.id )
        , ( "startDateTime", decodePosix record.startDateTime )
        , ( "durationInSecods", Json.Encode.int record.durationInSeconds )
        ]



--- VIEW


view :
    { a
        | clickedDeleteButton : Id -> msg
        , currentTime : Time.Posix
        , dateNotation : Utils.Date.Notation
        , timeZone : Time.Zone
        , language : Text.Language
        , viewport : Ui.Viewport
    }
    -> Record
    -> Element msg
view config record =
    let
        { clickedDeleteButton, language, viewport } =
            config

        { timeZone, currentTime, dateNotation } =
            config

        date =
            Utils.Date.relativeDateLabel
                { today = Utils.Date.fromZoneAndPosix timeZone currentTime
                , date = Utils.Date.fromZoneAndPosix timeZone record.startDateTime
                , dateNotation = dateNotation
                }

        duration =
            Utils.Duration.fromSeconds record.durationInSeconds
                |> Utils.Duration.label

        startTimeText =
            Utils.Time.toStringWithAmPm (startTime timeZone record)
                |> Text.String

        endTimeText =
            Utils.Time.toStringWithAmPm (endTime timeZone record)
                |> Text.String

        recordKey =
            let
                (Id intId) =
                    record.id
            in
            String.fromInt intId

        dateElement =
            Text.text13 language date
                |> Element.el [ Element.Font.color Colors.grayText ]

        durationHtml =
            Text.text12 language duration
                |> Element.el [ Element.Font.color Colors.grayText ]

        startEndTime =
            Text.text12
                language
                (Text.Words
                    [ startTimeText
                    , Text.String "•"
                    , endTimeText
                    ]
                )
                |> Element.el
                    [ Element.Font.color Colors.grayText ]

        deleteButton =
            Ui.accentButton
                { color = Colors.accent
                , onPress = Just (clickedDeleteButton record.id)
                , label = Icons.trash
                }

        children =
            [ Element.row
                [ Element.spacing 10
                , Element.width Element.fill
                ]
                [ deleteButton
                    |> Element.el [ Element.alignRight ]
                , dateElement
                    |> Element.el [ Element.alignRight ]
                ]
            , Element.row
                [ Element.spacing 10
                , Element.width Element.fill
                ]
                [ durationHtml
                , startEndTime
                    |> Element.el [ Element.alignRight ]
                ]
            ]

        recordElement =
            case viewport of
                Ui.Mobile ->
                    Element.column
                        [ Element.padding 16
                        , Element.spacing 13
                        , Element.width Element.fill
                        ]
                        children

                Ui.Desktop ->
                    Element.column
                        [ Element.paddingXY 0 16
                        , Element.spacing 13
                        , Element.width Element.fill
                        ]
                        children
    in
    -- Wrapping the record in a keyed element to lose focus when we delete a record
    Element.Keyed.column
        [ Element.width Element.fill
        ]
        [ ( recordKey, recordElement )
        ]
