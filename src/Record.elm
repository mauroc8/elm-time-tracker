module Record exposing
    ( Config
    , ConfigStatus(..)
    , Id
    , Record
    , config
    , decoder
    , encode
    , fromCreateForm
    , view
    )

import Calendar
import Clock
import Colors
import CreateForm
import DateTime exposing (DateTime)
import Element exposing (Element)
import Element.Font
import Html.Attributes exposing (start)
import Html.Events
import Html.Events.Extra.Pointer
import Icons exposing (playButton)
import Json.Decode
import Json.Encode
import Text
import Time
import Utils.Date
import Utils.Duration
import Utils.Events
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


fromCreateForm : Time.Posix -> CreateForm.CreateForm -> Record
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
    { description : String
    , date : Text.Text
    , duration : Text.Text
    , status : ConfigStatus msg
    , language : Text.Language
    }


type ConfigStatus msg
    = Selected (ExtrasConfig msg)
    | NotSelected
        { select : msg
        }
    | Desktop (ExtrasConfig msg)


type alias ExtrasConfig msg =
    { startTime : Text.Text
    , endTime : Text.Text
    , clickedDeleteButton : msg
    , clickedResumeButton : msg
    }


config :
    { selectedRecordId : Maybe Id
    , selectRecord : Id -> msg
    , clickedDeleteButton : Id -> msg
    , clickedResumeButton : String -> msg
    , currentTime : Time.Posix
    , dateNotation : Utils.Date.Notation
    , timeZone : Time.Zone
    , language : Text.Language
    , viewport : View.Viewport
    }
    -> Record
    -> Config msg
config viewConfig record =
    let
        { selectedRecordId, selectRecord, clickedDeleteButton, language, viewport } =
            viewConfig

        { timeZone, clickedResumeButton, currentTime, dateNotation } =
            viewConfig
    in
    { description = record.description
    , date =
        Utils.Date.relativeDateLabel
            { today = Calendar.fromPosix (Utils.Date.toZonedPosix timeZone currentTime)
            , date = Calendar.fromPosix (Utils.Date.toZonedPosix timeZone record.startDateTime)
            , dateNotation = dateNotation
            }
    , duration =
        Utils.Duration.fromSeconds record.durationInSeconds
            |> Utils.Duration.toText
    , status =
        let
            extrasConfig =
                { startTime =
                    Utils.Time.toStringWithAmPm (startTime timeZone record)
                        |> Text.Text
                , endTime =
                    Utils.Time.toStringWithAmPm (endTime timeZone record)
                        |> Text.Text
                , clickedDeleteButton = clickedDeleteButton record.id
                , clickedResumeButton = clickedResumeButton record.description
                }
        in
        if viewport == View.Desktop then
            Desktop extrasConfig

        else if selectedRecordId == Just record.id then
            Selected extrasConfig

        else
            NotSelected
                { select = selectRecord record.id
                }
    , language = language
    }


view :
    { context | emphasis : View.Emphasis }
    -> Config msg
    -> Element msg
view { emphasis } { description, date, duration, status, language } =
    let
        descriptionHtml =
            let
                ( nonemptyDescription, descriptionColor ) =
                    if String.trim description == "" then
                        ( Text.NoDescription, Colors.lighterGrayText )

                    else
                        ( Text.Text description, Colors.blackText )
            in
            Text.text16 language nonemptyDescription
                |> Element.el
                    [ Element.Font.semiBold
                    , Element.Font.color descriptionColor
                    , Element.width Element.fill
                    ]

        dateHtml =
            Text.text13 language date
                |> Element.el
                    [ Element.Font.color Colors.grayText
                    ]

        durationHtml =
            Text.text12 language duration
                |> Element.el
                    [ Element.Font.color Colors.grayText
                    ]
    in
    let
        mobileLayout attrs extras =
            Element.column
                ([ Element.padding 16
                 , Element.spacing 10
                 , Element.width Element.fill
                 ]
                    ++ attrs
                )
                ([ Element.row
                    [ Element.spacing 10
                    , Element.width Element.fill
                    ]
                    [ descriptionHtml
                    , dateHtml
                    ]
                 , durationHtml
                 ]
                    ++ extras
                )
    in
    case status of
        NotSelected { select } ->
            mobileLayout
                [ Element.htmlAttribute <|
                    Utils.Events.onPointerDown select
                ]
                []

        Selected extrasConfig ->
            let
                { startEndTime, playButton, deleteButton } =
                    viewExtras
                        { language = language
                        , emphasis = emphasis
                        }
                        extrasConfig
            in
            mobileLayout
                []
                [ Element.row
                    [ Element.spacing 16
                    , Element.width Element.fill
                    ]
                    [ startEndTime
                        |> Element.el
                            [ Element.alignBottom ]
                    , Element.row
                        [ Element.alignRight
                        , Element.spacing 16
                        , Element.alignBottom
                        ]
                        [ deleteButton
                        , playButton
                        ]
                    ]
                ]

        Desktop extrasConfig ->
            let
                { startEndTime, playButton, deleteButton } =
                    viewExtras
                        { language = language
                        , emphasis = emphasis
                        }
                        extrasConfig
            in
            Element.column
                [ Element.paddingXY 0 16
                , Element.spacing 12
                , Element.width Element.fill
                ]
                [ Element.row
                    [ Element.spacing 10
                    , Element.width Element.fill
                    ]
                    [ descriptionHtml
                    , startEndTime
                        |> Element.el [ Element.alignRight ]
                    , dateHtml
                        |> Element.el [ Element.alignRight ]
                    ]
                , Element.row
                    [ Element.spacing 10
                    , Element.width Element.fill
                    ]
                    [ durationHtml
                    , deleteButton
                        |> Element.el [ Element.alignRight ]
                    , playButton
                        |> Element.el [ Element.alignRight ]
                    ]
                ]


viewExtras :
    { a
        | language : Text.Language
        , emphasis : View.Emphasis
    }
    -> ExtrasConfig msg
    ->
        { startEndTime : Element msg
        , playButton : Element msg
        , deleteButton : Element msg
        }
viewExtras { language, emphasis } extrasConfig =
    { startEndTime =
        Text.text12
            language
            (Text.Words
                [ extrasConfig.startTime
                , Text.Text "•"
                , extrasConfig.endTime
                ]
            )
            |> Element.el
                [ Element.Font.color Colors.grayText ]
    , playButton =
        View.recordListButton
            { emphasis = emphasis
            , onClick = extrasConfig.clickedResumeButton
            , label = Icons.play
            }
            |> Element.el []
    , deleteButton =
        View.recordListButton
            { emphasis = emphasis
            , onClick = extrasConfig.clickedDeleteButton
            , label = Icons.trash
            }
            |> Element.el []
    }
