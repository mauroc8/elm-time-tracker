module Main exposing (main)

import Browser
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
import Platform exposing (Task)
import Record exposing (Record)
import RecordList exposing (RecordList)
import Settings exposing (Language, Settings)
import Sidebar exposing (Config(..))
import Task
import Time
import Utils.Duration
import Utils.Out as Out
import View



--- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> init
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



--- Model


type alias Model =
    { -- Entities
      records : RecordList

    -- UI
    , action : Action
    , selectedRecord : Maybe Record.Id
    , searchQuery : String

    -- Settings
    , unitedStatesDateNotation : Bool
    , language : Language

    -- Time
    , currentTime : Time.Posix
    , timeZone : Time.Zone

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
    , unitedStatesDateNotation = Settings.defaultUnitedStatesDateNotation
    , language = Settings.defaultLanguage
    , currentTime = Time.millisToPosix 0
    , timeZone = Time.utc
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
        | unitedStatesDateNotation = settings.unitedStatesDateNotation
        , language = settings.language
    }


{-| Returns the unsaved settings of the "Settings" form, or
the saved settings.
-}
appliedSettings : Model -> Settings
appliedSettings model =
    actionToSettings model.action
        |> Maybe.withDefault
            { unitedStatesDateNotation = model.unitedStatesDateNotation
            , language = model.language
            }



---


editUnitedStatesDateNotation : Bool -> Model -> Model
editUnitedStatesDateNotation usaDateNotation model =
    case model.action of
        ChangingSettings settings ->
            setAction
                (ChangingSettings
                    { settings
                        | unitedStatesDateNotation = usaDateNotation
                    }
                )
                model

        _ ->
            { model | unitedStatesDateNotation = usaDateNotation }


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


stopCreatingRecord : Time.Posix -> Model -> Model
stopCreatingRecord time model =
    case model.action of
        CreatingRecord createForm ->
            model
                |> pushRecord (Record.fromCreateForm time createForm)
                |> setAction Idle

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


actionToSettings action =
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
    | GotTimeZone Time.Zone
    | GotCurrentTime Time.Posix
    | SearchQueryChanged String
    | PressedSettingsButton
    | PressedSettingsCancelButton
    | PressedSettingsDoneButton
    | PressedStartButton
    | GotStartButtonPressTime Time.Posix
    | PressedStopButton
    | GotStopButtonPressTime Time.Posix
    | ChangedUnitedStatesDateNotation Bool
    | ChangedLanguage Language
    | ChangedCreateFormDescription String
    | SelectRecord Record.Id
    | ClickedDeleteButton Record.Id
    | ClickedEditButton Record.Id
    | ClickedResumeButton Record.Id
    | GotResumeButtonTime Record.Id Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToDo ->
            model
                |> Out.withNoCmd

        GotTimeZone zone ->
            setTimeZone zone model
                |> Out.withNoCmd

        GotCurrentTime posixTime ->
            setCurrentTime posixTime model
                |> Out.withNoCmd

        SearchQueryChanged searchQuery ->
            setSearchQuery searchQuery model
                |> Out.withNoCmd

        PressedSettingsButton ->
            setAction
                (ChangingSettings
                    { unitedStatesDateNotation = model.unitedStatesDateNotation
                    , language = model.language
                    }
                )
                model
                |> Out.withNoCmd

        PressedSettingsCancelButton ->
            setAction
                Idle
                model
                |> Out.withNoCmd

        PressedSettingsDoneButton ->
            setAction
                Idle
                model
                |> setSettings (appliedSettings model)
                |> Out.withNoCmd

        PressedStartButton ->
            Task.perform GotStartButtonPressTime Time.now
                |> Out.withModel model

        GotStartButtonPressTime time ->
            setAction
                (CreatingRecord (CreateForm.empty time))
                model
                |> Out.withNoCmd
                |> Out.mapModel (setCurrentTime time)

        PressedStopButton ->
            Task.perform GotStopButtonPressTime Time.now
                |> Out.withModel model

        GotStopButtonPressTime time ->
            stopCreatingRecord time model
                |> Out.withNoCmd
                |> Out.mapModel (setCurrentTime time)

        ChangedUnitedStatesDateNotation unitedStatesDateNotation ->
            editUnitedStatesDateNotation unitedStatesDateNotation model
                |> Out.withNoCmd

        ChangedLanguage language ->
            editLanguage language model
                |> Out.withNoCmd

        ChangedCreateFormDescription description ->
            changeCreateFormDescription description model
                |> Out.withNoCmd

        SelectRecord id ->
            { model | selectedRecord = Just id }
                |> Out.withNoCmd

        ClickedDeleteButton id ->
            { model | records = RecordList.delete id model.records }
                |> Out.withNoCmd

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

        ClickedResumeButton id ->
            Task.perform (GotResumeButtonTime id) Time.now
                |> Out.withModel model

        GotResumeButtonTime id time ->
            { model
                | action =
                    CreatingRecord
                        { description = ""
                        , start = time
                        }
            }
                |> Out.withNoCmd
                |> Out.mapModel (setCurrentTime time)



--- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.action of
        CreatingRecord { start } ->
            Time.every
                (if
                    Utils.Duration.fromTimeDifference start model.currentTime
                        |> Utils.Duration.lessThan (Utils.Duration.fromSeconds 60)
                 then
                    1000

                 else
                    1000 * 60
                )
                GotCurrentTime

        _ ->
            Sub.none



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
                { unitedStatesDateNotation = settings.unitedStatesDateNotation
                , language = settings.language
                , changedUnitedStatesDateNotation = ChangedUnitedStatesDateNotation
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
                                |> Utils.Duration.toString
                        , changedDescription = ChangedCreateFormDescription
                        , pressedStop = PressedStopButton
                        }
                , clickedSettings = PressedSettingsButton
                , changedSearchQuery = SearchQueryChanged
                }

        EditingRecord editForm ->
            Default
                { emphasis = View.Sidebar
                , searchQuery = model.searchQuery
                , records = recordsConfig model
                , sidebar = Sidebar.Idle { pressedStart = PressedStartButton }
                , clickedSettings = PressedSettingsButton
                , changedSearchQuery = SearchQueryChanged
                }

        Idle ->
            Default
                { emphasis = View.RecordList
                , searchQuery = model.searchQuery
                , records = recordsConfig model
                , sidebar = Sidebar.Idle { pressedStart = PressedStartButton }
                , clickedSettings = PressedSettingsButton
                , changedSearchQuery = SearchQueryChanged
                }


recordsConfig : Model -> RecordList.Config Msg
recordsConfig { records, searchQuery, selectedRecord, currentTime, unitedStatesDateNotation } =
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
                    , unitedStatesDateNotation = unitedStatesDateNotation
                    }
                )
            |> RecordList.ManyRecords
