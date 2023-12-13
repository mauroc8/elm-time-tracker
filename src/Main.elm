module Main exposing (Model, Msg, main)

import Browser
import Browser.Dom
import Browser.Events
import Clock
import Colors
import CreateRecord
import DateTime
import Html exposing (Html)
import Icons
import Json.Decode
import LocalStorage
import PreventClose
import Record exposing (Record)
import RecordList exposing (RecordList)
import Settings exposing (Settings)
import Task
import Text exposing (Language, Text)
import Time
import Ui
import Ui.Component
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
    | RunningScreen { startTime : Time.Posix, changeStartTimeInput : Maybe String }
    | HistoryScreen { justDeleted : Maybe Record }
    | SettingsScreen


homeScreen : Screen
homeScreen =
    HomeScreen


runningScreen : Time.Posix -> Screen
runningScreen currentTime =
    RunningScreen { startTime = currentTime, changeStartTimeInput = Nothing }


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


changeCreateFormStartTime : Clock.Time -> Model -> Model
changeCreateFormStartTime newStartTime ({ screen, timezone, currentTime } as model) =
    case screen of
        RunningScreen { startTime, changeStartTimeInput } ->
            let
                newStart =
                    DateTime.fromDateAndTime
                        (Utils.Date.fromZoneAndPosix timezone currentTime)
                        newStartTime
                        |> DateTime.toPosix
                        |> Utils.Date.fromZonedPosix timezone
            in
            if Time.posixToMillis newStart < Time.posixToMillis currentTime then
                model
                    |> setScreen (runningScreen newStart)

            else
                model |> setScreen (runningScreen startTime)

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



---


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
    | PressedEnterInCreateRecord
    | PressedEscapeInCreateRecord
    | PressedChangeStartTimeInCreateRecord
      -- Change start time
    | ConfirmStartTime Clock.Time
    | ChangeStartTime String
      -- Record List
    | ClickedDeleteButton Record.Id


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
            setScreen homeScreen model
                |> Out.withCmd saveSettings

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

        PressedEnterInCreateRecord ->
            stop
                |> Out.withModel model

        GotStopTime time ->
            model
                |> setCurrentTime time
                |> stopCreatingRecord
                |> Out.addCmd saveCreateForm
                |> Out.addCmd saveRecords

        PressedEscapeInCreateRecord ->
            case model.screen of
                RunningScreen { startTime, changeStartTimeInput } ->
                    case changeStartTimeInput of
                        Just _ ->
                            model
                                |> setScreen (runningScreen startTime)
                                |> Out.withCmd saveCreateForm

                        Nothing ->
                            model |> Out.withNoCmd

                _ ->
                    model |> Out.withNoCmd

        PressedChangeStartTimeInCreateRecord ->
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
                        |> setScreen (RunningScreen { startTime = startTime, changeStartTimeInput = Just changeStartTimeInput })
                        |> Out.withNoCmd

                _ ->
                    model |> Out.withNoCmd

        -- Change start time
        ConfirmStartTime newStartTime ->
            model
                |> changeCreateFormStartTime newStartTime
                |> Out.withNoCmd

        ChangeStartTime startTimeInput ->
            case model.screen of
                RunningScreen { startTime } ->
                    model
                        |> setScreen (RunningScreen { startTime = startTime, changeStartTimeInput = Just startTimeInput })
                        |> Out.withNoCmd

                _ ->
                    model |> Out.withNoCmd

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
                |> Out.withNoCmd



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

        sharedLayout =
            Ui.batch
                [ Ui.fillWidth
                , Ui.fillHeight
                , Ui.paddingXY ( breakpoints 40 32 24, breakpoints 32 24 16 )
                , Ui.spacing (breakpoints 32 24 16)
                , Ui.spaceBetween
                , Ui.style "transition" "background 0.25s ease-out"
                ]

        { timezone, currentTime, records } =
            model

        todayRecords =
            RecordList.fromDate timezone currentTime records

        todaysTotal =
            RecordList.duration todayRecords
    in
    case screen of
        HomeScreen ->
            let
                settingsButton =
                    Ui.Component.button PressedSettingsButton
                        [ Ui.spacing 4 ]
                        [ Icons.settings 16, text Text.Settings ]

                historyButton =
                    if records == RecordList.empty then
                        Html.text ""

                    else
                        Ui.Component.button PressedHistoryButton
                            []
                            [ text Text.History ]

                startButton =
                    Ui.button PressedStartButton
                        [ Ui.style "width" (Ui.px 102)
                        , Ui.style "height" (Ui.px 102)
                        , Ui.style "background-color" Colors.lightGreen
                        , Ui.style "border" (String.join " " [ Ui.px 4, "solid", Colors.black ])
                        , Ui.style "border-radius" "50%"
                        , Ui.centerX
                        , Ui.centerY
                        , Ui.style "text-transform" "uppercase"
                        , Ui.style "font-size" "24px"
                        , Ui.style "font-weight" "bold"
                        ]
                        [ text Text.Start ]
            in
            Ui.column
                [ sharedLayout, Ui.centerX ]
                [ Ui.row [ Ui.fillWidth, Ui.alignRight, Ui.spacing 12 ]
                    [ settingsButton
                    , historyButton
                    ]
                , Ui.filler []
                , startButton
                , if todaysTotal /= Utils.Duration.fromSeconds 0 then
                    Ui.row [ Ui.style "font-weight" "bold" ]
                        [ text (Utils.Duration.label todaysTotal) ]

                  else
                    Html.text ""
                , Ui.filler []
                , Ui.square 21 []
                ]

        RunningScreen { startTime } ->
            let
                duration =
                    Utils.Duration.fromTimeDifference startTime currentTime

                stopButton =
                    Ui.button PressedStopButton
                        [ Ui.style "width" (Ui.px 102)
                        , Ui.style "height" (Ui.px 102)
                        , Ui.style "background-color" Colors.red
                        , Ui.style "border" (String.join " " [ Ui.px 4, "solid", Colors.white ])
                        , Ui.style "border-radius" "50%"
                        , Ui.centerX
                        , Ui.centerY
                        , Ui.style "font-size" "24px"
                        , Ui.style "font-weight" "bold"
                        ]
                        [ text (Utils.Duration.label duration) ]
            in
            Ui.column
                [ sharedLayout
                , Ui.centerX
                , Ui.style "background-color" Colors.black
                , Ui.style "color" Colors.white
                , Ui.style "position" "relative"
                ]
                [ Ui.filler []
                , stopButton
                , if todaysTotal /= Utils.Duration.fromSeconds 0 then
                    Ui.row [ Ui.style "font-weight" "bold" ]
                        [ text (Utils.Duration.label (Utils.Duration.add todaysTotal duration)) ]

                  else
                    Html.text ""
                , Ui.filler []
                ]

        SettingsScreen ->
            Ui.column
                [ sharedLayout ]
                [ Ui.Component.biggerButton PressedBackButton [] [ Icons.chevronLeft 20, text Text.Back ] ]

        HistoryScreen _ ->
            let
                { dateNotation } =
                    model
            in
            Ui.column
                [ sharedLayout, Ui.centerX ]
                [ Ui.row [ Ui.fillWidth ]
                    [ Ui.Component.biggerButton PressedBackButton [] [ Icons.chevronLeft 20, text Text.Back ]
                    ]
                , RecordList.view
                    { currentTime = currentTime
                    , language = language
                    , dateNotation = dateNotation
                    , timezone = timezone
                    }
                    records
                ]
