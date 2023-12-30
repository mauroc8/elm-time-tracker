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
import Html exposing (Html)
import Html.Attributes
import Html.Events
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


view :
    { a
        | language : Text.Language
        , timezone : Time.Zone
        , onDelete : Id -> msg
    }
    -> Record
    -> Html msg
view config record =
    let
        { language, timezone, onDelete } =
            config

        text =
            Text.toHtml language

        startTimeString =
            Utils.Time.fromZoneAndPosix timezone record.startDateTime
    in
    Ui.row
        [ Ui.fillWidth, Ui.spacing 16, Ui.centerY ]
        [ Ui.row []
            [ Utils.Time.toStringWithAmPm startTimeString
                |> Html.text
            ]
        , Ui.filler []
        , Ui.row []
            [ Utils.Duration.fromSeconds record.durationInSeconds
                |> Utils.Duration.label
                |> text
            ]
        , Ui.row
            [ Ui.htmlTag "button"
            , Ui.attribute (Html.Events.onClick (onDelete record.id))
            , Ui.attribute (Html.Attributes.attribute "aria-label" (Text.toString language Text.Delete))
            , Ui.style "color" Colors.accentBlue
            , Ui.style "cursor" "pointer"
            ]
            [ Icons.trash ]
        ]
