module Main exposing (Action, Model, Msg, main)

import Browser
import Browser.Dom
import Browser.Events
import Colors
import CreateRecord exposing (CreateRecord)
import DefaultView
import Element exposing (Attribute, Element)
import Element.Font as Font
import Html exposing (Html)
import Json.Decode
import LocalStorage
import PreventClose
import Record exposing (Record)
import RecordList exposing (RecordList)
import Settings exposing (Settings)
import StartButton
import Task
import Text exposing (Language)
import Time
import Utils
import Utils.Date
import Utils.Duration
import Utils.Out as Out
import View



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



--- Model


type alias Model =
    { -- Records
      records : RecordList

    -- UI
    , action : Action

    -- Settings
    , dateNotation : Utils.Date.Notation
    , language : Language

    -- Time
    , currentTime : Time.Posix
    , timeZone : Time.Zone
    , visibility : Browser.Events.Visibility

    -- Responsiveness
    , viewport : View.Viewport

    -- Autosave
    , lastSaved : Time.Posix
    }


initialModel : Model
initialModel =
    { action = Idle
    , records = RecordList.empty
    , dateNotation = Utils.Date.westernNotation
    , language = Text.defaultLanguage
    , currentTime = Time.millisToPosix 0
    , timeZone = Time.utc
    , visibility = Browser.Events.Visible
    , viewport = View.Mobile
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
    { model | viewport = View.fromScreenWidth screenWidth }


setAction : Action -> Model -> Model
setAction action model =
    { model | action = action }


setSettings : Settings -> Model -> Model
setSettings settings model =
    { model
        | dateNotation = settings.dateNotation
        , language = settings.language
    }


editDateNotation : Utils.Date.Notation -> Model -> Model
editDateNotation dateNotation model =
    case model.action of
        ChangingSettings settings ->
            setAction
                (ChangingSettings
                    { settings
                        | dateNotation = dateNotation
                    }
                )
                model

        _ ->
            { model | dateNotation = dateNotation }


editLanguage : Language -> Model -> Model
editLanguage language model =
    case model.action of
        ChangingSettings settings ->
            setAction
                (ChangingSettings
                    { settings
                        | language = language
                    }
                )
                model

        _ ->
            { model
                | language = language
            }


startCreatingRecord : String -> Model -> ( Model, Cmd Msg )
startCreatingRecord description model =
    model
        |> setAction (CreateRecord (CreateRecord.new description model.currentTime))
        |> Out.withCmd
            (\_ ->
                Browser.Dom.focus CreateRecord.descriptionInputId
                    |> Task.attempt (\_ -> FocusedCreateFormDescriptionInput)
            )
        |> Out.addCmd (\_ -> PreventClose.on)


stopCreatingRecord : Model -> ( Model, Cmd Msg )
stopCreatingRecord model =
    case model.action of
        CreateRecord createForm ->
            let
                record =
                    Record.fromCreateForm model.currentTime createForm
            in
            model
                |> pushRecord record
                |> setAction Idle
                |> Out.withCmd (\_ -> PreventClose.off)

        _ ->
            model
                |> Out.withNoCmd


pushRecord : Record -> Model -> Model
pushRecord record model =
    { model
        | records = RecordList.push record model.records
    }


changeCreateFormDescription : String -> Model -> Model
changeCreateFormDescription description model =
    case model.action of
        CreateRecord createForm ->
            setAction
                (CreateRecord
                    { createForm
                        | description = description
                    }
                )
                model

        _ ->
            model


loadCreateForm : Json.Decode.Value -> Model -> Model
loadCreateForm flags model =
    LocalStorage.load
        { store = LocalStorage.createForm
        , flags = flags
        }
        |> Result.map (\createForm -> { model | action = CreateRecord createForm })
        |> Result.withDefault model


loadRecordList : Json.Decode.Value -> Model -> Model
loadRecordList flags model =
    LocalStorage.load
        { store = LocalStorage.recordList
        , flags = flags
        }
        |> Result.map (\recordList -> { model | records = recordList })
        |> Result.mapError (Utils.debugError "loadRecordList")
        |> Result.withDefault model


loadSettings : Json.Decode.Value -> Model -> Model
loadSettings flags model =
    LocalStorage.load
        { store = LocalStorage.settings
        , flags = flags
        }
        |> Result.map (\settings -> setSettings settings model)
        |> Result.mapError (Utils.debugError "loadSettings")
        |> Result.withDefault model



---


saveCreateForm : Model -> Cmd Msg
saveCreateForm model =
    case model.action of
        CreateRecord createForm ->
            LocalStorage.save
                { store = LocalStorage.createForm
                , value = createForm
                }

        _ ->
            LocalStorage.clear
                LocalStorage.createForm


saveRecords : Model -> Cmd msg
saveRecords model =
    LocalStorage.save
        { store = LocalStorage.recordList
        , value = model.records
        }


saveSettings : Model -> Cmd msg
saveSettings model =
    LocalStorage.save
        { store = LocalStorage.settings
        , value = savedSettings model
        }


{-| Returns the saved settings
-}
savedSettings : Model -> Settings
savedSettings model =
    { dateNotation = model.dateNotation
    , language = model.language
    }


{-| Returns the unsaved settings of the "Settings" form, or
the saved settings.
-}
appliedSettings : Model -> Settings
appliedSettings model =
    getActionSettings model.action
        |> Maybe.withDefault (savedSettings model)



--- Action


type Action
    = Idle
    | CreateRecord CreateRecord
    | ChangingSettings Settings


getActionSettings : Action -> Maybe Settings
getActionSettings action =
    case action of
        ChangingSettings settings ->
            Just settings

        _ ->
            Nothing



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
    | PressedSettingsCancelButton
    | PressedSettingsDoneButton
    | ChangedDateNotation Utils.Date.Notation
    | ChangedLanguage Language
      -- Create Record
    | PressedStartButton
    | GotStartButtonPressTime Time.Posix
    | PressedStopButton
    | GotStopTime Time.Posix
    | ChangedCreateFormDescription String
    | PressedEnterInCreateRecord
    | PressedEscapeInCreateRecord
    | PressedChangeStartTimeInCreateRecord
    | FocusedCreateFormDescriptionInput
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
            setAction
                (ChangingSettings
                    { dateNotation = model.dateNotation
                    , language = model.language
                    }
                )
                model
                |> Out.withNoCmd

        -- Settings
        PressedSettingsCancelButton ->
            setAction Idle model
                |> Out.withNoCmd

        PressedSettingsDoneButton ->
            setAction Idle model
                |> setSettings (appliedSettings model)
                |> Out.withCmd saveSettings

        ChangedDateNotation dateNotation ->
            model
                |> editDateNotation dateNotation
                |> Out.withNoCmd

        ChangedLanguage language ->
            editLanguage language model
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

        ChangedCreateFormDescription description ->
            changeCreateFormDescription description model
                |> Out.withCmd saveCreateForm

        PressedEscapeInCreateRecord ->
            model
                |> setAction Idle
                |> Out.withCmd saveCreateForm

        PressedChangeStartTimeInCreateRecord ->
            model
                |> Out.withNoCmd

        FocusedCreateFormDescriptionInput ->
            model
                |> Out.withNoCmd

        ClickedDeleteButton id ->
            { model | records = RecordList.delete id model.records }
                |> Out.withCmd saveRecords



--- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ if model.visibility == Browser.Events.Visible then
            case model.action of
                CreateRecord createForm ->
                    CreateRecord.subscriptions
                        { currentTime = model.currentTime
                        , gotCurrentTime = GotCurrentTime
                        }
                        createForm

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
    Element.layoutWith
        { options =
            [ Element.focusStyle focusStyle
            ]
        }
        (rootAttributes model)
        (rootElement model)


focusStyle : Element.FocusStyle
focusStyle =
    { borderColor = Just Colors.accent
    , backgroundColor = Nothing
    , shadow = Nothing
    }


rootAttributes : Model -> List (Attribute msg)
rootAttributes model =
    let
        shared =
            [ Element.width Element.fill
            , Element.height Element.fill
            , Font.family [ Font.typeface "Manrope", Font.sansSerif ]
            ]
    in
    case model.action of
        ChangingSettings _ ->
            shared
                ++ View.settingsBackgroundColor

        CreateRecord _ ->
            shared
                ++ View.recordListBackgroundColor View.TopBar

        Idle ->
            shared
                ++ View.recordListBackgroundColor View.RecordList


rootElement : Model -> Element Msg
rootElement model =
    case model.action of
        ChangingSettings settings ->
            Settings.view
                { dateNotation = settings.dateNotation
                , language = settings.language
                , changedDateNotation = ChangedDateNotation
                , changedLanguage = ChangedLanguage
                , pressedSettingsCancelButton = PressedSettingsCancelButton
                , pressedSettingsDoneButton = PressedSettingsDoneButton
                , viewport = model.viewport
                , today = Utils.Date.fromZoneAndPosix model.timeZone model.currentTime
                }

        CreateRecord createRecord ->
            DefaultView.view
                { emphasis = View.TopBar
                , records = model.records
                , topBar =
                    CreateRecord.view
                        { description = createRecord.description
                        , elapsedTime =
                            Utils.Duration.fromTimeDifference model.currentTime createRecord.start
                                |> Utils.Duration.toText
                        , changedDescription = ChangedCreateFormDescription
                        , pressedStop = PressedStopButton
                        , pressedEnter = PressedEnterInCreateRecord
                        , pressedEscape = PressedEscapeInCreateRecord
                        , pressedChangeStartTime = PressedChangeStartTimeInCreateRecord
                        , language = model.language
                        }
                , clickedSettings = PressedSettingsButton
                , language = model.language
                , viewport = model.viewport
                , clickedDeleteButton = ClickedDeleteButton
                , currentTime = model.currentTime
                , dateNotation = model.dateNotation
                , timeZone = model.timeZone
                }

        Idle ->
            DefaultView.view
                { emphasis = View.RecordList
                , records = model.records
                , clickedSettings = PressedSettingsButton
                , language = model.language
                , viewport = model.viewport
                , clickedDeleteButton = ClickedDeleteButton
                , currentTime = model.currentTime
                , dateNotation = model.dateNotation
                , timeZone = model.timeZone
                , topBar = StartButton.view { pressedStart = PressedStartButton }
                }
