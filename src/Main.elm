module Main exposing (Model, Msg, main)

import Browser
import Browser.Dom
import Browser.Events
import Clock
import CreateRecord
import DateTime
import Html exposing (Html)
import Json.Decode
import LocalStorage
import PreventClose
import Record exposing (Record)
import RecordList exposing (RecordList)
import Settings exposing (Settings)
import Task
import Text exposing (Language)
import Time
import Ui
import Utils
import Utils.Date
import Utils.Out as Out
import Utils.Time



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
    , timeZone : Time.Zone
    , visibility : Browser.Events.Visibility

    -- Responsiveness
    , viewport : Ui.Viewport

    -- Autosave
    , lastSaved : Time.Posix
    }


initialModel : Model
initialModel =
    { records = RecordList.empty
    , screen = homeScreen
    , dateNotation = Utils.Date.westernNotation
    , language = Text.defaultLanguage
    , currentTime = Time.millisToPosix 0
    , timeZone = Time.utc
    , visibility = Browser.Events.Visible
    , viewport = Ui.Mobile
    , lastSaved = Time.millisToPosix 0
    }


setTimeZone : Time.Zone -> Model -> Model
setTimeZone timeZone model =
    { model | timeZone = timeZone }


setCurrentTime : Time.Posix -> Model -> Model
setCurrentTime posixTime model =
    { model | currentTime = posixTime }


setViewport : { screenWidth : Int } -> Model -> Model
setViewport { screenWidth } model =
    { model | viewport = Ui.fromScreenWidth screenWidth }


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


startCreatingRecord : String -> Model -> ( Model, Cmd Msg )
startCreatingRecord description model =
    model
        |> setScreen (runningScreen model.currentTime)
        |> Out.withCmd
            (\_ ->
                Browser.Dom.focus CreateRecord.descriptionInputId
                    |> Task.attempt (\_ -> FocusedCreateFormDescriptionInput)
            )
        |> Out.addCmd (\_ -> PreventClose.on)


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
changeCreateFormStartTime newStartTime ({ screen, timeZone, currentTime } as model) =
    case screen of
        RunningScreen { startTime, changeStartTimeInput } ->
            let
                newStart =
                    DateTime.fromDateAndTime
                        (Utils.Date.fromZoneAndPosix timeZone currentTime)
                        newStartTime
                        |> DateTime.toPosix
                        |> Utils.Date.fromZonedPosix timeZone
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
      -- Settings
    | PressedSettingsBackButton
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
    | FocusedCreateFormDescriptionInput
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

        -- Settings
        PressedSettingsBackButton ->
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
                |> startCreatingRecord ""
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
                        { timeZone } =
                            model

                        changeStartTimeInput =
                            Utils.Time.fromZoneAndPosix timeZone startTime
                                |> Utils.Time.toHhMm
                    in
                    model
                        |> setScreen (RunningScreen { startTime = startTime, changeStartTimeInput = Just changeStartTimeInput })
                        |> Out.withNoCmd

                _ ->
                    model |> Out.withNoCmd

        FocusedCreateFormDescriptionInput ->
            model
                |> Out.withNoCmd

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
    Html.text "elm-time-tracker"
