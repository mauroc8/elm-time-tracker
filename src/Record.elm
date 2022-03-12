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
import Icons
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


view :
    { context | emphasis : View.Emphasis, viewport : View.Viewport }
    -> Config msg
    -> Element msg
view { emphasis, viewport } { description, date, duration, status, language } =
    let
        wrapperPadding =
            case viewport of
                View.Mobile ->
                    Element.padding 16

                View.Desktop ->
                    Element.paddingXY 0 16

        wrapper children =
            case status of
                NotSelected { select } ->
                    Element.column
                        [ wrapperPadding
                        , Element.spacing 10
                        , Element.width Element.fill
                        , Element.htmlAttribute <|
                            Utils.Events.onPointerDown select
                        ]
                        children

                Selected selectedConfig ->
                    Element.column
                        [ wrapperPadding
                        , Element.spacing 16
                        , Element.width Element.fill
                        ]
                        (children
                            ++ [ viewExtras
                                    { language = language
                                    , emphasis = emphasis
                                    }
                                    selectedConfig
                               ]
                        )
    in
    wrapper
        [ Element.row
            [ Element.spacing 10
            , Element.width Element.fill
            ]
            [ let
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
            , Text.text13 language date
                |> Element.el
                    [ Element.Font.color Colors.grayText
                    ]
            ]
        , Text.text12 language duration
            |> Element.el
                [ Element.Font.color Colors.grayText
                ]
        ]


viewExtras { language, emphasis } selectedConfig =
    Element.row
        [ Element.spacing 16
        , Element.width Element.fill
        ]
        [ Text.text12
            language
            (Text.Words
                [ selectedConfig.startTime
                , Text.Text "•"
                , selectedConfig.endTime
                ]
            )
            |> Element.el
                [ Element.Font.color Colors.grayText
                , Element.alignBottom
                ]
        , Element.row
            [ Element.alignRight
            , Element.spacing 16
            , Element.alignBottom
            ]
            [ View.recordListButton
                { emphasis = emphasis
                , onClick = selectedConfig.clickedResumeButton
                , label = Icons.play
                }
                |> Element.el []
            , View.recordListButton
                { emphasis = emphasis
                , onClick = selectedConfig.clickedEditButton
                , label = Icons.edit
                }
                |> Element.el []
            , View.recordListButton
                { emphasis = emphasis
                , onClick = selectedConfig.clickedDeleteButton
                , label = Icons.trash
                }
                |> Element.el []
            ]
        ]


type alias Config msg =
    { description : String
    , date : Text.Text
    , duration : Text.Text
    , status : ConfigStatus msg
    , language : Text.Language
    }


config :
    { selectedRecordId : Maybe Id
    , selectRecord : Id -> msg
    , clickedDeleteButton : Id -> msg
    , clickedEditButton : Id -> msg
    , clickedResumeButton : String -> msg
    , currentTime : Time.Posix
    , dateNotation : Utils.Date.Notation
    , timeZone : Time.Zone
    , language : Text.Language
    }
    -> Record
    -> Config msg
config viewConfig record =
    let
        { selectedRecordId, selectRecord, clickedDeleteButton, language } =
            viewConfig

        { clickedEditButton, timeZone, clickedResumeButton, currentTime, dateNotation } =
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
        if selectedRecordId == Just record.id then
            Selected
                { startTime =
                    Utils.Time.toStringWithAmPm (startTime timeZone record)
                        |> Text.Text
                , endTime =
                    Utils.Time.toStringWithAmPm (endTime timeZone record)
                        |> Text.Text
                , clickedDeleteButton = clickedDeleteButton record.id
                , clickedEditButton = clickedEditButton record.id
                , clickedResumeButton = clickedResumeButton record.description
                }

        else
            NotSelected
                { select = selectRecord record.id
                }
    , language = language
    }


type ConfigStatus msg
    = Selected (SelectedConfig msg)
    | NotSelected
        { select : msg
        }


type alias SelectedConfig msg =
    { startTime : Text.Text
    , endTime : Text.Text
    , clickedDeleteButton : msg
    , clickedEditButton : msg
    , clickedResumeButton : msg
    }
