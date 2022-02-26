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
import Time
import Utils.Date
import Utils.Duration
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


view : Config msg -> Element msg
view { description, date, duration, status } =
    let
        ( nonemptyDescription, descriptionColor ) =
            if String.trim description == "" then
                ( "no description", Colors.lighterGrayText )

            else
                ( description, Colors.blackText )

        wrapper children =
            case status of
                NotSelected { select } ->
                    Element.column
                        [ Element.padding 16
                        , Element.spacing 10
                        , Element.width Element.fill
                        , Element.htmlAttribute <|
                            Html.Events.Extra.Pointer.onDown (\_ -> select)
                        ]
                        children

                Selected selectedConfig ->
                    Element.column
                        [ Element.padding 16
                        , Element.spacing 16
                        , Element.width Element.fill
                        ]
                        (children
                            ++ [ extraView selectedConfig ]
                        )
    in
    wrapper
        [ Element.row
            [ Element.spacing 10
            , Element.width Element.fill
            ]
            [ Element.text nonemptyDescription
                |> Element.el
                    ([ Element.Font.semiBold
                     , Element.Font.color descriptionColor
                     , Element.clip
                     , Element.width Element.fill
                     ]
                        ++ View.fontSize16
                    )
            , Element.text date
                |> Element.el
                    ([ Element.Font.color Colors.grayText
                     ]
                        ++ View.fontSize13
                    )
            ]
        , Element.text duration
            |> Element.el
                ([ Element.Font.color Colors.grayText
                 ]
                    ++ View.fontSize12
                )
        ]


extraView : SelectedConfig msg -> Element msg
extraView selectedConfig =
    Element.row
        [ Element.spacing 16
        , Element.width Element.fill
        ]
        [ Element.text
            (selectedConfig.startTime
                ++ " • "
                ++ selectedConfig.endTime
            )
            |> Element.el
                ([ Element.Font.color Colors.grayText
                 , Element.alignBottom
                 ]
                    ++ View.fontSize12
                )
        , Element.row
            [ Element.alignRight
            , Element.spacing 16
            , Element.alignBottom
            ]
            [ Icons.play
                |> Element.el []
            , Icons.edit
                |> Element.el []
            , Icons.trash
                |> Element.el []
            ]
        ]


type alias Config msg =
    { description : String
    , date : String
    , duration : String
    , status : ConfigStatus msg
    }


config :
    { a
        | selectedRecordId : Maybe Id
        , selectRecord : Id -> msg
        , clickedDeleteButton : Id -> msg
        , clickedEditButton : Id -> msg
        , clickedResumeButton : Id -> msg
        , currentTime : Time.Posix
        , unitedStatesDateNotation : Bool
        , timeZone : Time.Zone
    }
    -> Record
    -> Config msg
config viewConfig record =
    let
        { selectedRecordId, selectRecord, clickedDeleteButton } =
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
