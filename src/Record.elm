module Record exposing
    ( Config
    , Id
    , Record
    , decoder
    , encode
    , fromCreateForm
    , view
    )

import Clock
import Colors
import CreateRecord
import Element exposing (Element)
import Element.Font
import Element.Keyed
import Icons exposing (playButton)
import Json.Decode
import Json.Encode
import Text
import Time
import Utils.Date
import Utils.Duration
import Utils.Time
import View


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
    , description : String
    , startDateTime : Time.Posix
    , durationInSeconds : Int
    }


decoder : Json.Decode.Decoder Record
decoder =
    Json.Decode.map4 Record
        (Json.Decode.field "id" idDecoder)
        (Json.Decode.field "description" Json.Decode.string)
        (Json.Decode.field "startDateTime" posixDecoder)
        (Json.Decode.field "durationInSecods" Json.Decode.int)


fromCreateForm : Time.Posix -> CreateRecord.CreateRecord -> Record
fromCreateForm now { description, start } =
    { id = Id (Time.posixToMillis now)
    , description = description
    , startDateTime = start
    , durationInSeconds = (Time.posixToMillis now - Time.posixToMillis start) // 1000
    }


zonedStartTime : Time.Zone -> Record -> Time.Posix
zonedStartTime zone record =
    Utils.Date.toZonedPosix zone record.startDateTime


startTime : Time.Zone -> Record -> Clock.Time
startTime zone record =
    Clock.fromPosix (zonedStartTime zone record)


endTime : Time.Zone -> Record -> Clock.Time
endTime zone record =
    Clock.fromPosix
        (Time.millisToPosix
            (Time.posixToMillis (zonedStartTime zone record)
                + record.durationInSeconds
                * 1000
            )
        )


encode : Record -> Json.Encode.Value
encode record =
    Json.Encode.object
        [ ( "id", encodeId record.id )
        , ( "description", Json.Encode.string record.description )
        , ( "startDateTime", decodePosix record.startDateTime )
        , ( "durationInSecods", Json.Encode.int record.durationInSeconds )
        ]



--- VIEW


type alias Config msg =
    { clickedDeleteButton : Id -> msg
    , currentTime : Time.Posix
    , dateNotation : Utils.Date.Notation
    , timeZone : Time.Zone
    , language : Text.Language
    , viewport : View.Viewport
    , emphasis : View.Emphasis
    }


view :
    { a
        | clickedDeleteButton : Id -> msg
        , currentTime : Time.Posix
        , dateNotation : Utils.Date.Notation
        , timeZone : Time.Zone
        , language : Text.Language
        , viewport : View.Viewport
        , emphasis : View.Emphasis
    }
    -> Record
    -> Element msg
view config record =
    let
        { clickedDeleteButton, language, viewport } =
            config

        { timeZone, currentTime, dateNotation, emphasis } =
            config

        description =
            record.description

        date =
            Utils.Date.relativeDateLabel
                { today = Utils.Date.fromZoneAndPosix timeZone currentTime
                , date = Utils.Date.fromZoneAndPosix timeZone record.startDateTime
                , dateNotation = dateNotation
                }

        duration =
            Utils.Duration.fromSeconds record.durationInSeconds
                |> Utils.Duration.toText

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

        descriptionHtml =
            let
                ( nonemptyDescription, descriptionColor ) =
                    if String.trim description == "" then
                        ( Text.NoDescription, Colors.lighterGrayText )

                    else
                        ( Text.String description, Colors.blackText )
            in
            Text.text16 language nonemptyDescription
                |> Element.el
                    [ Element.Font.semiBold
                    , Element.Font.color descriptionColor
                    , Element.width Element.fill
                    ]

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
            View.accentButton
                { onPress =
                    case emphasis of
                        View.RecordList ->
                            View.enabled (clickedDeleteButton record.id)

                        View.TopBar ->
                            View.disabled
                , label = Icons.trash
                }

        children =
            [ Element.row
                [ Element.spacing 10
                , Element.width Element.fill
                ]
                [ descriptionHtml
                , deleteButton
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
                View.Mobile ->
                    Element.column
                        [ Element.padding 16
                        , Element.spacing 13
                        , Element.width Element.fill
                        ]
                        children

                View.Desktop ->
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
