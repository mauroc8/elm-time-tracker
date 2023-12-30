module Main exposing (Model, Msg, Screen, main)

import Browser
import Browser.Dom
import Browser.Events
import Calendar
import Colors
import CreateRecord
import DateTime
import Html exposing (Html)
import Html.Attributes
import Icons
import Json.Decode
import LocalStorage
import PreventClose
import Process
import Record exposing (Record)
import RecordList exposing (RecordList)
import Settings exposing (Settings)
import Task
import Text exposing (Language, Text)
import Time
import Ui
import Ui.Button
import Ui.RadioButtonFieldSet
import Ui.TextField
import Ui.Toast
import Utils
import Utils.Date
import Utils.Duration
import Utils.Out as Out
import Utils.Time
import Viewport



--- MAIN


main : Program Json.Decode.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Json.Decode.Value -> ( Model, Cmd Msg )
init flags =
    ( initialModel
        |> loadCreateForm flags
        |> loadRecordList flags
        |> loadSettings flags
    , Cmd.batch
        [ Time.here
            |> Task.perform GotTimeZone
        , Time.now
            |> Task.perform GotCurrentTime
        , Browser.Dom.getViewport
            |> Task.perform GotViewport
        ]
    )



--- Screen


type Screen
    = HomeScreen
    | RunningScreen RunningData
    | HistoryScreen { justDeleted : Maybe Record }
    | SettingsScreen


homeScreen : Screen
homeScreen =
    HomeScreen


runningScreen : Time.Posix -> Screen
runningScreen currentTime =
    RunningScreen { startTime = currentTime, startTimeInput = Nothing, startTimeError = Nothing }


historyScreen : Screen
historyScreen =
    HistoryScreen { justDeleted = Nothing }



--- Model


type alias Model =
    { -- Records
      records : RecordList

    -- UI
    , screen : Screen

    -- Settings
    , dateNotation : Utils.Date.Notation
    , language : Language

    -- Time
    , currentTime : Time.Posix
    , timezone : Time.Zone
    , visibility : Browser.Events.Visibility

    -- Responsiveness
    , viewport : Viewport.Viewport

    -- Autosave
    , lastSaved : Time.Posix
    }


initialModel : Model
initialModel =
    { records = RecordList.empty
    , screen = homeScreen
    , dateNotation = Utils.Date.defaultNotation
    , language = Text.defaultLanguage
    , currentTime = Time.millisToPosix 0
    , timezone = Time.utc
    , visibility = Browser.Events.Visible
    , viewport = Viewport.Mobile
    , lastSaved = Time.millisToPosix 0
    }


setTimeZone : Time.Zone -> Model -> Model
setTimeZone timezone model =
    { model | timezone = timezone }


setCurrentTime : Time.Posix -> Model -> Model
setCurrentTime posixTime model =
    { model | currentTime = posixTime }


setViewport : { screenWidth : Int } -> Model -> Model
setViewport { screenWidth } model =
    { model | viewport = Viewport.fromScreenWidth screenWidth }


setScreen : Screen -> Model -> Model
setScreen screen model =
    { model | screen = screen }


setSettings : Settings -> Model -> Model
setSettings settings model =
    { model
        | dateNotation = settings.dateNotation
        , language = settings.language
    }


setDateNotation : Utils.Date.Notation -> Model -> Model
setDateNotation dateNotation model =
    { model | dateNotation = dateNotation }


setLanguage : Language -> Model -> Model
setLanguage language model =
    { model | language = language }


startCreatingRecord : Model -> ( Model, Cmd Msg )
startCreatingRecord model =
    model
        |> setScreen (runningScreen model.currentTime)
        |> Out.withCmd (\_ -> PreventClose.on)


stopCreatingRecord : Model -> ( Model, Cmd Msg )
stopCreatingRecord model =
    case model.screen of
        RunningScreen { startTime } ->
            let
                record =
                    Record.fromStartAndCurrentTime model.currentTime startTime
            in
            model
                |> pushRecord record
                |> setScreen homeScreen
                |> Out.withCmd (\_ -> PreventClose.off)

        _ ->
            model
                |> Out.withNoCmd


pushRecord : Record -> Model -> Model
pushRecord record model =
    { model
        | records = RecordList.push record model.records
    }


changeStartTime : String -> Model -> Model
changeStartTime newStartTimeInput ({ screen, timezone, currentTime } as model) =
    case screen of
        RunningScreen { startTime } ->
            let
                parsedStartTime =
                    Utils.Time.fromHhMm newStartTimeInput

                newStartTimestamp =
                    parsedStartTime
                        |> Result.toMaybe
                        |> Maybe.map
                            (\time ->
                                DateTime.fromDateAndTime
                                    (Utils.Date.fromZoneAndPosix timezone startTime)
                                    time
                                    |> DateTime.toPosix
                                    |> Utils.Date.fromZonedPosix timezone
                            )

                newStartTime =
                    case newStartTimestamp of
                        Just newStart ->
                            if Time.posixToMillis newStart < Time.posixToMillis currentTime then
                                newStart

                            else
                                startTime

                        Nothing ->
                            startTime
            in
            model
                |> setScreen
                    (RunningScreen
                        { startTime = newStartTime
                        , startTimeInput = Just newStartTimeInput
                        , startTimeError =
                            case parsedStartTime of
                                Err error ->
                                    Just error

                                Ok _ ->
                                    Nothing
                        }
                    )

        _ ->
            model


loadCreateForm : Json.Decode.Value -> Model -> Model
loadCreateForm flags model =
    LocalStorage.readFromFlags flags CreateRecord.store
        |> Result.map (\startTime -> { model | screen = runningScreen startTime })
        |> Result.withDefault model


loadRecordList : Json.Decode.Value -> Model -> Model
loadRecordList flags model =
    LocalStorage.readFromFlags flags RecordList.store
        |> Result.map (\recordList -> { model | records = recordList })
        |> Result.mapError (Utils.debugError "loadRecordList")
        |> Result.withDefault model


loadSettings : Json.Decode.Value -> Model -> Model
loadSettings flags model =
    LocalStorage.readFromFlags flags Settings.store
        |> Result.map (\settings -> setSettings settings model)
        |> Result.mapError (Utils.debugError "loadSettings")
        |> Result.withDefault model


getJustDeletedRecord : Model -> Maybe Record.Record
getJustDeletedRecord model =
    case model.screen of
        HistoryScreen { justDeleted } ->
            justDeleted

        _ ->
            Nothing



--- CMDS


saveCreateForm : Model -> Cmd Msg
saveCreateForm model =
    case model.screen of
        RunningScreen { startTime } ->
            LocalStorage.save CreateRecord.store startTime

        _ ->
            LocalStorage.clear CreateRecord.store


saveRecords : Model -> Cmd msg
saveRecords model =
    LocalStorage.save RecordList.store model.records


closeToastAfterFiveSeconds : Model -> Cmd Msg
closeToastAfterFiveSeconds model =
    case getJustDeletedRecord model of
        Just deletedRecord ->
            Process.sleep 5000
                |> Task.perform (\_ -> FiveSecondsAfterDeletingARecord deletedRecord.id)

        Nothing ->
            Cmd.none


saveSettings : Model -> Cmd msg
saveSettings model =
    LocalStorage.save Settings.store (savedSettings model)


{-| Returns the settings saved in the model
-}
savedSettings : Model -> Settings
savedSettings model =
    { dateNotation = model.dateNotation
    , language = model.language
    }


undoDeleteRecord : Record.Record -> Model -> Model
undoDeleteRecord deletedRecord model =
    let
        { records } =
            model
    in
    { model
        | records = RecordList.push deletedRecord records
        , screen = HistoryScreen { justDeleted = Nothing }
    }



--- UPDATE


type Msg
    = -- Context
      GotTimeZone Time.Zone
    | GotCurrentTime Time.Posix
    | GotViewport Browser.Dom.Viewport
    | VisibilityChanged Browser.Events.Visibility
    | ViewportWidthChanged Int
      -- Heading
    | PressedSettingsButton
    | PressedHistoryButton
      -- Settings
    | PressedBackButton
    | ChangedDateNotation Utils.Date.Notation
    | ChangedLanguage Language
      -- Create Record
    | PressedStartButton
    | GotStartButtonPressTime Time.Posix
    | PressedStopButton
    | GotStopTime Time.Posix
    | PressedChangeStartTime
      -- Change start time
    | ChangeStartTime String
      -- Record List
    | ClickedDeleteButton Record.Id
    | PressedUndoDeleteRecord
    | FiveSecondsAfterDeletingARecord Record.Id


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        stop : Cmd Msg
        stop =
            Task.perform GotStopTime Time.now
    in
    case msg of
        -- Context
        GotTimeZone zone ->
            setTimeZone zone model
                |> Out.withNoCmd

        GotCurrentTime posixTime ->
            setCurrentTime posixTime model
                |> Out.withNoCmd

        GotViewport viewport ->
            setViewport { screenWidth = round viewport.scene.width } model
                |> Out.withNoCmd

        VisibilityChanged visibility ->
            { model | visibility = visibility }
                |> Out.withCmd (\_ -> Time.now |> Task.perform GotCurrentTime)

        ViewportWidthChanged width ->
            setViewport { screenWidth = width } model
                |> Out.withNoCmd

        -- Heading
        PressedSettingsButton ->
            setScreen SettingsScreen model |> Out.withNoCmd

        PressedHistoryButton ->
            setScreen historyScreen model |> Out.withNoCmd

        -- Settings
        PressedBackButton ->
            case model.screen of
                SettingsScreen ->
                    setScreen homeScreen model
                        |> Out.withCmd saveSettings

                HistoryScreen _ ->
                    setScreen homeScreen model
                        |> Out.withCmd saveSettings

                RunningScreen { startTime } ->
                    setScreen (runningScreen startTime) model
                        |> Out.withCmd saveSettings

                HomeScreen ->
                    model |> Out.withNoCmd

        ChangedDateNotation dateNotation ->
            model
                |> setDateNotation dateNotation
                |> Out.withNoCmd

        ChangedLanguage language ->
            setLanguage language model
                |> Out.withNoCmd

        -- Create record
        PressedStartButton ->
            Task.perform GotStartButtonPressTime Time.now
                |> Out.withModel model

        GotStartButtonPressTime time ->
            model
                |> setCurrentTime time
                |> startCreatingRecord
                |> Out.addCmd saveCreateForm

        PressedStopButton ->
            stop
                |> Out.withModel model

        GotStopTime time ->
            model
                |> setCurrentTime time
                |> stopCreatingRecord
                |> Out.addCmd saveCreateForm
                |> Out.addCmd saveRecords

        PressedChangeStartTime ->
            case model.screen of
                RunningScreen { startTime } ->
                    let
                        { timezone } =
                            model

                        changeStartTimeInput =
                            Utils.Time.fromZoneAndPosix timezone startTime
                                |> Utils.Time.toHhMm
                    in
                    model
                        |> setScreen
                            (RunningScreen
                                { startTime = startTime
                                , startTimeInput = Just changeStartTimeInput
                                , startTimeError = Nothing
                                }
                            )
                        |> Out.withNoCmd

                _ ->
                    model |> Out.withNoCmd

        -- Change start time
        ChangeStartTime startTimeInput ->
            changeStartTime startTimeInput model
                |> Out.withCmd saveCreateForm

        -- Record List
        ClickedDeleteButton id ->
            let
                record =
                    RecordList.find id model.records
            in
            { model
                | screen = HistoryScreen { justDeleted = record }
                , records = RecordList.delete id model.records
            }
                |> Out.withCmd saveRecords
                |> Out.addCmd closeToastAfterFiveSeconds

        PressedUndoDeleteRecord ->
            case getJustDeletedRecord model of
                Just deletedRecord ->
                    undoDeleteRecord deletedRecord model
                        |> Out.withCmd saveRecords

                Nothing ->
                    model |> Out.withNoCmd

        FiveSecondsAfterDeletingARecord deletedRecordId ->
            case getJustDeletedRecord model of
                Just deletedRecord ->
                    if deletedRecord.id == deletedRecordId then
                        model
                            |> setScreen (HistoryScreen { justDeleted = Nothing })
                            |> Out.withCmd saveRecords

                    else
                        model |> Out.withNoCmd

                Nothing ->
                    model |> Out.withNoCmd



--- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ if model.visibility == Browser.Events.Visible then
            case model.screen of
                RunningScreen { startTime } ->
                    CreateRecord.subscriptions
                        { currentTime = model.currentTime
                        , gotCurrentTime = GotCurrentTime
                        , startTime = startTime
                        }

                _ ->
                    Sub.none

          else
            Sub.none
        , Browser.Events.onVisibilityChange VisibilityChanged
        , Browser.Events.onResize (\width _ -> ViewportWidthChanged width)
        ]



--- VIEW


view : Model -> Html Msg
view model =
    let
        { screen, language, viewport } =
            model

        text =
            Text.toHtml language

        breakpoints =
            Viewport.breakpoints viewport

        sharedStyles =
            Ui.batch
                [ Ui.fillWidth
                , Ui.fillHeight
                , Ui.paddingXY 40 32
                , Ui.spacing 32
                , Ui.spaceBetween
                , Ui.style "transition" "background 0.25s ease-out"
                , Ui.centerX
                ]

        { timezone, currentTime, records } =
            model

        todayRecords =
            RecordList.fromDate timezone currentTime records

        todaysTotal =
            RecordList.duration todayRecords

        { dateNotation } =
            model
    in
    case screen of
        HomeScreen ->
            Ui.column
                [ sharedStyles ]
                (viewHomeScreen
                    { language = language
                    , todaysTotal = todaysTotal
                    , records = records
                    , viewport = viewport
                    }
                )

        RunningScreen data ->
            Ui.column
                [ sharedStyles
                , Ui.style "background-color" Colors.black
                , Ui.style "color" Colors.white
                ]
                (viewRunningScreen
                    { currentTime = currentTime
                    , language = language
                    , todaysTotal = todaysTotal
                    , viewport = viewport
                    }
                    data
                )

        SettingsScreen ->
            Ui.column
                [ sharedStyles ]
                (viewSettingsScreen
                    { currentTime = currentTime
                    , timezone = timezone
                    , language = language
                    , viewport = viewport
                    , dateNotation = dateNotation
                    }
                )

        HistoryScreen { justDeleted } ->
            Ui.column
                [ sharedStyles ]
                [ Ui.row [ breakpoints (Ui.style "width" "400px") Ui.fillWidth Ui.fillWidth ]
                    [ Ui.Button.render PressedBackButton
                        [ Ui.Button.bigger ]
                        [ Icons.chevronLeft 20, text Text.Back ]
                    ]
                , RecordList.view
                    { currentTime = currentTime
                    , language = language
                    , dateNotation = dateNotation
                    , timezone = timezone
                    , onDelete = ClickedDeleteButton
                    }
                    records
                , Ui.filler []
                , Ui.row [ Ui.style "max-width" "400px", Ui.style "color" Colors.grayText ] [ text Text.CommentAboutStorage ]
                , Ui.Toast.render { visible = justDeleted /= Nothing }
                    []
                    [ Ui.row []
                        [ text Text.YouDeletedARecord
                        ]
                    , Ui.Button.render PressedUndoDeleteRecord [] [ Icons.undo, text Text.Undo ]
                    ]
                ]



--- Home screen


viewHomeScreen :
    { a
        | language : Language
        , records : RecordList
        , todaysTotal : Utils.Duration.Duration
        , viewport : Viewport.Viewport
    }
    -> List (Html Msg)
viewHomeScreen { language, records, todaysTotal, viewport } =
    let
        text =
            Text.toHtml language

        settingsButton =
            Ui.Button.render PressedSettingsButton [] [ Icons.settings 16, text Text.Settings ]

        historyButton =
            if records == RecordList.empty then
                Html.text ""

            else
                Ui.Button.render PressedHistoryButton [] [ text Text.History ]

        startButton =
            circularButton [ Ui.style "text-transform" "uppercase" ]
                { viewport = viewport
                , language = language
                , label = Text.Start
                , backgroundColor = Colors.lightGreen
                , borderColor = Colors.black
                , onClick = PressedStartButton
                }
    in
    [ Ui.row [ Ui.fillWidth, Ui.alignRight, Ui.spacing 12 ]
        [ settingsButton
        , historyButton
        ]
    , Ui.filler []
    , startButton
    , if Utils.Duration.toSeconds todaysTotal > 59 then
        Ui.row [ Ui.style "font-weight" "bold" ]
            [ text (Utils.Duration.label todaysTotal) ]

      else
        Html.text ""
    , Ui.filler []
    , Ui.box 21 []
    ]


{-| start and stop button base
-}
circularButton :
    List (Ui.Attribute msg)
    ->
        { a
            | viewport : Viewport.Viewport
            , language : Language
            , label : Text
            , backgroundColor : String
            , borderColor : String
            , onClick : msg
        }
    -> Html msg
circularButton attributes { onClick, viewport, language, label, backgroundColor, borderColor } =
    let
        text =
            Text.toHtml language

        breakpoints =
            Viewport.breakpoints viewport
    in
    Ui.button onClick
        [ Ui.style "width" (Ui.px <| breakpoints 124 102 102)
        , Ui.style "height" (Ui.px <| breakpoints 124 102 102)
        , Ui.style "transition" "all 0.2s ease-out"
        , Ui.style "background-color" backgroundColor
        , Ui.style "border" (String.join " " [ Ui.px <| breakpoints 6 4 4, "solid", borderColor ])
        , Ui.style "border-radius" "50%"
        , Ui.centerX
        , Ui.centerY
        , Ui.style "font-size" "24px"
        , Ui.style "font-weight" "bold"
        , Ui.batch attributes
        ]
        [ text label ]



--- Running Screen


type alias RunningData =
    { startTime : Time.Posix
    , startTimeInput : Maybe String
    , startTimeError : Maybe Text.Text
    }


viewRunningScreen :
    { currentTime : Time.Posix
    , language : Language
    , todaysTotal : Utils.Duration.Duration
    , viewport : Viewport.Viewport
    }
    -> RunningData
    -> List (Html Msg)
viewRunningScreen { currentTime, language, todaysTotal, viewport } { startTime, startTimeInput, startTimeError } =
    let
        text =
            Text.toHtml language

        duration =
            Utils.Duration.fromTimeDifference startTime currentTime

        stopButton =
            circularButton []
                { viewport = viewport
                , language = language
                , label = Utils.Duration.label duration
                , backgroundColor = Colors.red
                , borderColor = Colors.white
                , onClick = PressedStopButton
                }

        breakpoints =
            Viewport.breakpoints viewport
    in
    case startTimeInput of
        Nothing ->
            [ Ui.filler []
            , stopButton
            , if Utils.Duration.toSeconds todaysTotal > 59 then
                Ui.row [ Ui.style "font-weight" "bold" ]
                    [ text (Utils.Duration.label (Utils.Duration.add todaysTotal duration)) ]

              else
                Html.text ""
            , Ui.filler []
            , Ui.row [ Ui.fillWidth, Ui.alignRight ]
                [ Ui.Button.render PressedChangeStartTime
                    [ Ui.Button.lighter ]
                    [ Icons.edit 16
                    , text Text.ChangeStartTimeButton
                    ]
                ]
            ]

        Just inputValue ->
            [ Ui.row [ breakpoints (Ui.style "width" "500px") Ui.fillWidth Ui.fillWidth, Ui.spacing 12, Ui.spaceBetween ]
                [ Ui.Button.render PressedBackButton
                    [ Ui.Button.bigger, Ui.Button.lighter ]
                    [ Icons.chevronLeft 20, text Text.Back ]
                , Ui.row
                    [ Ui.style "background-color" Colors.red
                    , Ui.style "color" Colors.white
                    , Ui.paddingXY 8 6
                    , Ui.style "border-radius" "16px"
                    , Ui.style "font-size" "0.8125rem"
                    ]
                    [ text (Utils.Duration.label duration) ]
                ]
            , breakpoints (Html.text "") (Ui.filler []) (Ui.filler [])
            , Ui.column [ Ui.spacing 24, breakpoints (Ui.style "width" "500px") (Ui.class "") (Ui.class "") ]
                [ Ui.row
                    [ Ui.htmlTag "h1"
                    , Ui.style "text-transform" "uppercase"
                    , Ui.style "font-size" "1.25rem"
                    , Ui.style "font-weight" "bold"
                    ]
                    [ text Text.ChangeStartTimeHeading ]
                , Ui.TextField.field [ Ui.spacing 8, Ui.fillWidth ]
                    { id = "change-start-time"
                    , value = inputValue
                    , onChange = ChangeStartTime
                    , label = text Text.ChangeStartTimeLabel
                    , error = Maybe.map text startTimeError
                    }
                ]
            , Ui.filler []
            , Ui.box 26 []
            ]



--- Settings screen


viewSettingsScreen :
    { timezone : Time.Zone
    , currentTime : Time.Posix
    , language : Text.Language
    , viewport : Viewport.Viewport
    , dateNotation : Utils.Date.Notation
    }
    -> List (Html Msg)
viewSettingsScreen { currentTime, timezone, language, viewport, dateNotation } =
    let
        text =
            Text.toHtml language

        breakpoints =
            Viewport.breakpoints viewport
    in
    [ Ui.row [ breakpoints (Ui.style "width" "500px") Ui.fillWidth Ui.fillWidth, Ui.spacing 12, Ui.spaceBetween ]
        [ Ui.Button.render PressedBackButton
            [ Ui.Button.bigger, Ui.Button.lighter ]
            [ Icons.chevronLeft 20, text Text.Back ]
        ]
    , breakpoints (Html.text "") (Ui.filler []) (Ui.filler [])
    , Ui.column
        [ breakpoints (Ui.style "width" "500px") Ui.fillWidth Ui.fillWidth
        , Ui.spacing 24
        ]
        [ Ui.row [ Ui.htmlTag "b", Ui.style "font-size" "1.25rem", Ui.style "text-transform" "uppercase" ]
            [ text Text.Settings ]
        , Ui.RadioButtonFieldSet.render
            { id = "language"
            , legend = text Text.LanguageLabel
            , value = language
            , onChange = ChangedLanguage
            , caption = Nothing
            }
            [ ( text Text.EnglishLanguage, Text.English )
            , ( text Text.SpanishLanguage, Text.Spanish )
            ]
        , let
            today =
                Utils.Date.fromZoneAndPosix timezone currentTime

            todayInUsaDate =
                Utils.Date.toLabel Utils.Date.usaNotation today

            todayInInternationalDate =
                Utils.Date.toLabel Utils.Date.defaultNotation today

            captionText =
                if Text.toString language todayInUsaDate == Text.toString language todayInInternationalDate then
                    Text.Words
                        [ Text.YesterdayWas
                        , Utils.Date.toLabel dateNotation (Calendar.decrementDay today)
                        ]

                else
                    Text.Words
                        [ Text.TodayIs
                        , Utils.Date.toLabel dateNotation today
                        ]
          in
          Ui.RadioButtonFieldSet.render
            { id = "dateNotation"
            , legend = text Text.DateNotationLabel
            , value = dateNotation
            , onChange = ChangedDateNotation
            , caption = Just (text captionText)
            }
            [ ( text Text.InternationalDateNotation, Utils.Date.defaultNotation )
            , ( text Text.UsaDateNotation, Utils.Date.usaNotation )
            ]
        , Ui.row [ Ui.htmlTag "a", Ui.attribute (Html.Attributes.attribute "href" "https://github.com/mauroc8/elm-time-tracker#readme") ]
            [ text Text.AboutThisWebsite ]
        ]
    , Ui.filler []
    , Ui.box 26 []
    ]
