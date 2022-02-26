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
import Json.Decode
import Time
import Utils.Date
import Utils.Duration
import View


posixDecoder =
    Json.Decode.int |> Json.Decode.map Time.millisToPosix



--- ID


type Id
    = Id Int


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



--- VIEW


view : Config msg -> Element msg
view { description, date, duration, status } =
    Element.column
        [ Element.padding 16
        , Element.spacing 10
        , Element.width Element.fill
        ]
        [ Element.row
            [ Element.spacing 10
            , Element.width Element.fill
            ]
            [ Element.text description
                |> Element.el
                    ([ Element.Font.semiBold
                     , Element.Font.color Colors.blackText
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
    }
    -> Record
    -> Config msg
config viewConfig record =
    let
        { selectedRecordId, selectRecord, clickedDeleteButton, clickedEditButton, clickedResumeButton, currentTime, unitedStatesDateNotation } =
            viewConfig
    in
    { description = record.description
    , date =
        Utils.Date.toString
            { today = Calendar.fromPosix currentTime
            , date = Calendar.fromPosix record.startDateTime
            , unitedStatesDateNotation = unitedStatesDateNotation
            }
    , duration =
        Utils.Duration.fromTimeDifference
            currentTime
            record.startDateTime
            |> Utils.Duration.toString
    , status =
        if selectedRecordId == Just record.id then
            Selected
                { startTime = "12:45"
                , endTime = "11:15"
                , clickedDeleteButton = clickedDeleteButton
                , clickedEditButton = clickedEditButton
                , clickedResumeButton = clickedResumeButton
                }

        else
            NotSelected
                { select = selectRecord
                }
    }


type ConfigStatus msg
    = Selected
        { startTime : String
        , endTime : String
        , clickedDeleteButton : Id -> msg
        , clickedEditButton : Id -> msg
        , clickedResumeButton : Id -> msg
        }
    | NotSelected
        { select : Id -> msg
        }
