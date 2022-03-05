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
import Record exposing (Record)
import RecordList exposing (RecordList)
import Settings exposing (Settings)
import Sidebar exposing (Config(..))
import Task
import Text exposing (Language)
import Time
import Utils.Date
import Utils.Duration
import Utils.Out as Out
import View



--- MAIN


main : Program Json.Decode.Value Model Msg
main =
    Browser.element
        { init =
            \flags ->
                init
                    |> Out.mapModel (loadCreateForm flags)
                    |> Out.mapModel (loadRecordList flags)
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( initialModel
    , Cmd.batch
        [ Time.here
            |> Task.perform GotTimeZone
        , Time.now
            |> Task.perform GotCurrentTime
        ]
    )


loadCreateForm : Json.Decode.Value -> Model -> Model
loadCreateForm flags model =
    let
        savedCreateForm =
            LocalStorage.load
                { store = LocalStorage.createForm
                , flags = flags
                }
    in
    savedCreateForm
        |> Result.map (\createForm -> { model | action = CreatingRecord createForm })
        |> Result.withDefault model


loadRecordList : Json.Decode.Value -> Model -> Model
loadRecordList flags model =
    let
        savedRecordList =
            LocalStorage.load
                { store = LocalStorage.recordList
                , flags = flags
                }
    in
    savedRecordList
        |> Result.map (\recordList -> { model | records = recordList })
        |> Result.withDefault model



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
    , windowWidth : Int
    , windowHeight : Int

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
    , windowWidth = 0
    , windowHeight = 0
    , lastSaved = Time.millisToPosix 0
    }


setTimeZone : Time.Zone -> Model -> Model
setTimeZone timeZone model =
    { model | timeZone = timeZone }


setCurrentTime : Time.Posix -> Model -> Model
setCurrentTime posixTime model =
    { model | currentTime = posixTime }


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


{-| Returns the unsaved settings of the "Settings" form, or
the saved settings.
-}
appliedSettings : Model -> Settings
appliedSettings model =
    getActionSettings model.action
        |> Maybe.withDefault
            { dateNotation = model.dateNotation
            , language = model.language
            }



---


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


startCreatingRecord : String -> Time.Posix -> Model -> ( Model, Cmd Msg )
startCreatingRecord description time model =
    model
        |> setAction (CreatingRecord (CreateForm.new description time))
        |> Out.withCmd
            (Browser.Dom.focus CreateForm.descriptionInputId
                |> Task.attempt (\_ -> ToDo)
            )


stopCreatingRecord : Time.Posix -> Model -> Model
stopCreatingRecord time model =
    case model.action of
        CreatingRecord createForm ->
            let
                record =
                    Record.fromCreateForm time createForm
            in
            model
                |> pushRecord record
                |> setAction Idle
                |> selectRecord record.id

        _ ->
            model


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
    = ToDo
      -- Context
    | GotTimeZone Time.Zone
    | GotCurrentTime Time.Posix
    | VisibilityChanged Browser.Events.Visibility
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
    | GotStopButtonPressTime Time.Posix
    | ChangedCreateFormDescription String
    | PressedEscapeInCreateRecord
      -- Record List
    | SelectRecord Record.Id
    | ClickedDeleteButton Record.Id
    | ClickedEditButton Record.Id
    | ClickedResumeButton String
    | GotResumeButtonTime String Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToDo ->
            model
                |> Out.withNoCmd

        -- Context
        GotTimeZone zone ->
            setTimeZone zone model
                |> Out.withNoCmd

        GotCurrentTime posixTime ->
            setCurrentTime posixTime model
                |> Out.withNoCmd

        VisibilityChanged visibility ->
            { model | visibility = visibility }
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
            setAction
                Idle
                model
                |> setSettings (appliedSettings model)
                |> Out.withNoCmd

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
                |> startCreatingRecord "" time
                |> Out.addCmd saveCreateForm

        PressedStopButton ->
            Task.perform GotStopButtonPressTime Time.now
                |> Out.withModel model

        GotStopButtonPressTime time ->
            model
                |> stopCreatingRecord time
                |> setCurrentTime time
                |> Out.withNoCmd
                |> Out.addCmd saveCreateForm
                |> Out.addCmd saveRecords

        ChangedCreateFormDescription description ->
            changeCreateFormDescription description model
                |> Out.withNoCmd
                |> Out.addCmd saveCreateForm

        PressedEscapeInCreateRecord ->
            model
                |> setAction Idle
                |> Out.withNoCmd
                |> Out.addCmd saveCreateForm

        -- Record List
        SelectRecord id ->
            { model | selectedRecord = Just id }
                |> Out.withNoCmd

        ClickedDeleteButton id ->
            { model | records = RecordList.delete id model.records }
                |> Out.withNoCmd
                |> Out.addCmd saveRecords

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
                |> startCreatingRecord description time
                |> Out.addCmd saveCreateForm


saveCreateForm : Model -> Cmd msg
saveCreateForm model =
    case model.action of
        CreatingRecord createForm ->
            LocalStorage.save LocalStorage.createForm createForm

        _ ->
            LocalStorage.clear LocalStorage.createForm


saveRecords : Model -> Cmd msg
saveRecords model =
    LocalStorage.save LocalStorage.recordList model.records



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
                        , pressedEscape = PressedEscapeInCreateRecord
                        , language = model.language
                        }
                , clickedSettings = PressedSettingsButton
                , changedSearchQuery = SearchQueryChanged
                , language = model.language
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
