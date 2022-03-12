module Main exposing (main)

import Browser
import Browser.Dom
import Browser.Events
import Colors
import CreateForm exposing (CreateForm)
import DateTime
import DefaultView
import Dict exposing (Dict)
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font exposing (Font)
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes
import Icons
import Json.Decode
import LocalStorage
import Platform exposing (Task)
import PreventClose
import Record exposing (Record)
import RecordList exposing (RecordList)
import Settings exposing (Settings)
import Sidebar exposing (Config(..))
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
    { -- Entities
      records : RecordList

    -- UI
    , action : Action
    , selectedRecord : Maybe Record.Id
    , searchQuery : String

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
    , selectedRecord = Nothing
    , searchQuery = ""
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


setSearchQuery : String -> Model -> Model
setSearchQuery searchQuery model =
    { model | searchQuery = searchQuery }


setAction : Action -> Model -> Model
setAction action model =
    { model | action = action }


setSettings : Settings -> Model -> Model
setSettings settings model =
    { model
        | dateNotation = settings.dateNotation
        , language = settings.language
    }


selectRecord : Record.Id -> Model -> Model
selectRecord id model =
    { model | selectedRecord = Just id }


unselectRecord : Model -> Model
unselectRecord model =
    { model | selectedRecord = Nothing }


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
        |> setAction (CreatingRecord (CreateForm.new description model.currentTime))
        |> unselectRecord
        |> Out.withCmd
            (\_ ->
                Browser.Dom.focus CreateForm.descriptionInputId
                    |> Task.attempt FocusedCreateFormDescriptionInput
            )
        |> Out.addCmd (\_ -> PreventClose.on)


stopCreatingRecord : Model -> ( Model, Cmd Msg )
stopCreatingRecord model =
    case model.action of
        CreatingRecord createForm ->
            let
                record =
                    Record.fromCreateForm model.currentTime createForm
            in
            model
                |> pushRecord record
                |> setAction Idle
                |> selectRecord record.id
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
        CreatingRecord createForm ->
            setAction
                (CreatingRecord
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
        |> Result.map (\createForm -> { model | action = CreatingRecord createForm })
        |> Result.withDefault model


loadRecordList : Json.Decode.Value -> Model -> Model
loadRecordList flags model =
    LocalStorage.load
        { store = LocalStorage.recordList
        , flags = flags
        }
        |> Result.map (\recordList -> { model | records = recordList })
        |> Result.mapError (Utils.debugLog "loadRecordList")
        |> Result.withDefault model


loadSettings : Json.Decode.Value -> Model -> Model
loadSettings flags model =
    LocalStorage.load
        { store = LocalStorage.settings
        , flags = flags
        }
        |> Result.map (\settings -> setSettings settings model)
        |> Result.mapError (Utils.debugLog "loadSettings")
        |> Result.withDefault model



---


saveCreateForm : Model -> Cmd Msg
saveCreateForm model =
    case model.action of
        CreatingRecord createForm ->
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
    | CreatingRecord CreateForm
    | EditingRecord EditForm
    | ChangingSettings Settings


getActionSettings : Action -> Maybe Settings
getActionSettings action =
    case action of
        ChangingSettings settings ->
            Just settings

        _ ->
            Nothing



--- Edit Form


type alias EditForm =
    { id : Record.Id
    , description : String
    , start : String
    , end : String
    , duration : String
    , date : String
    }



--- UPDATE


type Msg
    = -- Context
      GotTimeZone Time.Zone
    | GotCurrentTime Time.Posix
    | GotViewport Browser.Dom.Viewport
    | VisibilityChanged Browser.Events.Visibility
    | ViewportWidthChanged Int
      -- Search bar
    | SearchQueryChanged String
    | PressedSettingsButton
      -- Settings
    | PressedSettingsCancelButton
    | PressedSettingsDoneButton
    | ChangedDateNotation Utils.Date.Notation
    | ChangedLanguage Language
      -- Create record
    | PressedStartButton
    | GotStartButtonPressTime Time.Posix
    | PressedStopButton
    | GotStopTime Time.Posix
    | ChangedCreateFormDescription String
    | PressedEnterInCreateRecord
    | PressedEscapeInCreateRecord
    | FocusedCreateFormDescriptionInput (Result Browser.Dom.Error ())
      -- Record List
    | SelectRecord Record.Id
    | ClickedDeleteButton Record.Id
    | ClickedEditButton Record.Id
    | ClickedResumeButton String
    | GotResumeButtonTime String Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
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
                |> Out.withNoCmd

        ViewportWidthChanged width ->
            setViewport { screenWidth = width } model
                |> Out.withNoCmd

        -- Search bar
        SearchQueryChanged searchQuery ->
            setSearchQuery searchQuery model
                |> Out.withNoCmd

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

        GotStopTime time ->
            model
                |> setCurrentTime time
                |> stopCreatingRecord
                |> Out.addCmd saveCreateForm
                |> Out.addCmd saveRecords

        ChangedCreateFormDescription description ->
            changeCreateFormDescription description model
                |> Out.withCmd saveCreateForm

        PressedEnterInCreateRecord ->
            stop
                |> Out.withModel model

        PressedEscapeInCreateRecord ->
            model
                |> setAction Idle
                |> Out.withCmd saveCreateForm

        FocusedCreateFormDescriptionInput _ ->
            model
                |> Out.withNoCmd

        -- Record List
        SelectRecord id ->
            case model.action of
                Idle ->
                    { model | selectedRecord = Just id }
                        |> Out.withNoCmd

                _ ->
                    model
                        |> Out.withNoCmd

        ClickedDeleteButton id ->
            { model | records = RecordList.delete id model.records }
                |> Out.withCmd saveRecords

        ClickedEditButton id ->
            { model
                | action =
                    EditingRecord
                        { id = id
                        , description = ""
                        , start = ""
                        , end = ""
                        , duration = ""
                        , date = ""
                        }
            }
                |> Out.withNoCmd

        ClickedResumeButton description ->
            Task.perform (GotResumeButtonTime description) Time.now
                |> Out.withModel model

        GotResumeButtonTime description time ->
            model
                |> setCurrentTime time
                |> startCreatingRecord description
                |> Out.addCmd saveCreateForm


stop : Cmd Msg
stop =
    Task.perform GotStopTime Time.now



--- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ if model.visibility == Browser.Events.Visible then
            case model.action of
                CreatingRecord createForm ->
                    CreateForm.subscriptions
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


{-| There are two main views.

This type describes them.

-}
type Config msg
    = ChangeSettings (Settings.Config msg)
    | Default (DefaultView.Config msg)


view : Model -> Html Msg
view model =
    let
        config =
            viewConfig model
    in
    Element.layoutWith
        { options =
            [ Element.focusStyle focusStyle
            ]
        }
        (rootAttributes config)
        (rootElement config)


focusStyle : Element.FocusStyle
focusStyle =
    { borderColor = Just Colors.accent
    , backgroundColor = Nothing
    , shadow = Nothing
    }


rootAttributes : Config msg -> List (Attribute msg)
rootAttributes config =
    let
        shared =
            [ Element.width Element.fill
            , Element.height Element.fill
            , Font.family [ Font.typeface "Manrope", Font.sansSerif ]
            ]
    in
    case config of
        ChangeSettings _ ->
            shared
                ++ View.settingsBackgroundColor

        Default { emphasis } ->
            shared
                ++ View.recordListBackgroundColor emphasis


rootElement : Config Msg -> Element Msg
rootElement config =
    case config of
        ChangeSettings settings ->
            Settings.view settings

        Default defaultViewConfig ->
            DefaultView.view defaultViewConfig



-- Config


viewConfig : Model -> Config Msg
viewConfig model =
    case model.action of
        ChangingSettings settings ->
            ChangeSettings
                { dateNotation = settings.dateNotation
                , language = settings.language
                , changedDateNotation = ChangedDateNotation
                , changedLanguage = ChangedLanguage
                , pressedSettingsCancelButton = PressedSettingsCancelButton
                , pressedSettingsDoneButton = PressedSettingsDoneButton
                , viewport = model.viewport
                }

        CreatingRecord createForm ->
            Default
                { emphasis = View.Sidebar
                , searchQuery = model.searchQuery
                , records = recordsConfig model
                , sidebar =
                    Sidebar.CreatingRecord
                        { description = createForm.description
                        , elapsedTime =
                            Utils.Duration.fromTimeDifference model.currentTime createForm.start
                                |> Utils.Duration.toText
                        , changedDescription = ChangedCreateFormDescription
                        , pressedStop = PressedStopButton
                        , pressedEnter = PressedEnterInCreateRecord
                        , pressedEscape = PressedEscapeInCreateRecord
                        , language = model.language
                        }
                , clickedSettings = PressedSettingsButton
                , changedSearchQuery = SearchQueryChanged
                , language = model.language
                , viewport = model.viewport
                }

        EditingRecord editForm ->
            Default
                { emphasis = View.Sidebar
                , searchQuery = model.searchQuery
                , records = recordsConfig model
                , sidebar = Sidebar.Idle { pressedStart = PressedStartButton }
                , clickedSettings = PressedSettingsButton
                , changedSearchQuery = SearchQueryChanged
                , language = model.language
                , viewport = model.viewport
                }

        Idle ->
            Default
                { emphasis = View.RecordList
                , searchQuery = model.searchQuery
                , records = recordsConfig model
                , sidebar = Sidebar.Idle { pressedStart = PressedStartButton }
                , clickedSettings = PressedSettingsButton
                , changedSearchQuery = SearchQueryChanged
                , language = model.language
                , viewport = model.viewport
                }


recordsConfig : Model -> RecordList.Config Msg
recordsConfig { records, searchQuery, selectedRecord, currentTime, dateNotation, timeZone, language } =
    let
        searchResults =
            RecordList.search searchQuery records
    in
    if records == RecordList.empty then
        RecordList.EmptyRecords

    else if searchResults == RecordList.empty then
        RecordList.NoSearchResults

    else
        searchResults
            |> RecordList.toList
            |> List.map
                (Record.config
                    { selectedRecordId = selectedRecord
                    , selectRecord = SelectRecord
                    , clickedDeleteButton = ClickedDeleteButton
                    , clickedEditButton = ClickedEditButton
                    , clickedResumeButton = ClickedResumeButton
                    , currentTime = currentTime
                    , dateNotation = dateNotation
                    , timeZone = timeZone
                    , language = language
                    }
                )
            |> RecordList.ManyRecords
