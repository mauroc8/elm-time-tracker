module Record exposing
    ( Config
    , ConfigStatus(..)
    , Id
    , Record
    , config
    , decoder
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



--- ID


type Id
    = Id Int


idDecoder : Json.Decode.Decoder Id
idDecoder =
    Json.Decode.int |> Json.Decode.map Id



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



--- VIEW


view : View.Emphasis -> Config msg -> Element msg
view emphasis { description, date, duration, status, language } =
    let
        wrapper children =
            case status of
                NotSelected { select } ->
                    Element.column
                        [ Element.padding 16
                        , Element.spacing 10
                        , Element.width Element.fill
                        , Element.htmlAttribute <|
                            Utils.Events.onPointerDown select
                        ]
                        children

                Selected selectedConfig ->
                    Element.column
                        [ Element.padding 16
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
                        ( Text.Unlocalized description, Colors.blackText )
              in
              Text.text16 language nonemptyDescription
                |> Element.el
                    [ Element.Font.semiBold
                    , Element.Font.color descriptionColor
                    , Element.width Element.fill
                    ]
            , Text.text13 language (Text.Unlocalized date)
                |> Element.el
                    [ Element.Font.color Colors.grayText
                    ]
            ]
        , Text.text12 language (Text.Unlocalized duration)
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
            (Text.Unlocalized <|
                selectedConfig.startTime
                    ++ " • "
                    ++ selectedConfig.endTime
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
    , date : String
    , duration : String
    , status : ConfigStatus msg
    , language : Text.Language
    }


config :
    { selectedRecordId : Maybe Id
    , selectRecord : Id -> msg
    , clickedDeleteButton : Id -> msg
    , clickedEditButton : Id -> msg
    , clickedResumeButton : Id -> msg
    , currentTime : Time.Posix
    , unitedStatesDateNotation : Bool
    , timeZone : Time.Zone
    , language : Text.Language
    }
    -> Record
    -> Config msg
config viewConfig record =
    let
        { selectedRecordId, selectRecord, clickedDeleteButton, language } =
            viewConfig

        { clickedEditButton, timeZone, clickedResumeButton, currentTime, unitedStatesDateNotation } =
            viewConfig
    in
    { description = record.description
    , date =
        Utils.Date.relativeDateLabel
            { today = Calendar.fromPosix (Utils.Date.toZonedPosix timeZone currentTime)
            , date = Calendar.fromPosix (Utils.Date.toZonedPosix timeZone record.startDateTime)
            , unitedStatesDateNotation = unitedStatesDateNotation
            }
    , duration =
        Utils.Duration.fromSeconds record.durationInSeconds
            |> Utils.Duration.toString
    , status =
        if selectedRecordId == Just record.id then
            Selected
                { startTime = Utils.Time.toStringWithAmPm (startTime timeZone record)
                , endTime = Utils.Time.toStringWithAmPm (endTime timeZone record)
                , clickedDeleteButton = clickedDeleteButton record.id
                , clickedEditButton = clickedEditButton record.id
                , clickedResumeButton = clickedResumeButton record.id
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
    { startTime : String
    , endTime : String
    , clickedDeleteButton : msg
    , clickedEditButton : msg
    , clickedResumeButton : msg
    }
