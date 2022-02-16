module Main exposing (..)

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
import RecordList exposing (Records)
import Settings exposing (ChangeSettingsConfig, Language, Settings)
import Sidebar
import Task
import Time
import Utils.Out as Out
import View



--- Model


type alias Model =
    { -- Entities
      records : Records

    -- UI
    , action : Status
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


setTimeZone timeZone model =
    { model | timeZone = timeZone }


setCurrentTime posixTime model =
    { model | currentTime = posixTime }


setSearchQuery searchQuery model =
    { model | searchQuery = searchQuery }


setStatus action model =
    { model | action = action }


{-| Returns the unsaved settings of the "Settings" form, or
the saved settings.
-}
appliedSettings : Model -> Settings
appliedSettings model =
    case model.action of
        ChangingSettings settings ->
            settings

        _ ->
            { unitedStatesDateNotation = model.unitedStatesDateNotation
            , language = model.language
            }


setSettings : Settings -> Model -> Model
setSettings settings model =
    { model
        | unitedStatesDateNotation = settings.unitedStatesDateNotation
        , language = settings.language
    }



--- Status


type Status
    = Idle
    | CreatingRecord CreateForm
    | EditingRecord EditForm
    | ChangingSettings Settings



--- Edit Form


type alias EditForm =
    { id : Record.Id
    , description : String
    , start : String
    , end : String
    , duration : String
    , date : String
    }



--- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
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



--- UPDATE


type Msg
    = NoOp
    | GotTimeZone Time.Zone
    | GotCurrentTime Time.Posix
    | SearchQueryChanged String
    | PressedSettingsButton
    | PressedSettingsCancelButton
    | PressedSettingsDoneButton
    | PressedStartButton
    | GotStartButtonPressTime Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
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
            setStatus
                (ChangingSettings
                    { unitedStatesDateNotation = model.unitedStatesDateNotation
                    , language = model.language
                    }
                )
                model
                |> Out.withNoCmd

        PressedSettingsCancelButton ->
            setStatus Idle model
                |> Out.withNoCmd

        PressedSettingsDoneButton ->
            setStatus Idle model
                |> setSettings (appliedSettings model)
                |> Out.withNoCmd

        PressedStartButton ->
            Task.perform GotStartButtonPressTime Time.now
                |> Out.withModel model

        GotStartButtonPressTime time ->
            setStatus (CreatingRecord (CreateForm.empty time)) model
                |> Out.withNoCmd



--- VIEW


{-| There are two main views.

This type describes them.

-}
type Config msg
    = ChangeSettings (ChangeSettingsConfig msg)
    | Default (DefaultView.Config msg)


view : Model -> Html Msg
view model =
    Element.layoutWith
        { options =
            [ Element.focusStyle focusStyle
            ]
        }
        rootAttributes
        (rootElement (viewConfig model))


focusStyle : Element.FocusStyle
focusStyle =
    { borderColor = Just Colors.accent
    , backgroundColor = Nothing
    , shadow = Nothing
    }


rootAttributes : List (Attribute msg)
rootAttributes =
    [ Element.width Element.fill
    , Element.height Element.fill
    , Font.family [ Font.typeface "Manrope", Font.sansSerif ]
    ]


viewConfig : Model -> Config Msg
viewConfig model =
    case model.action of
        ChangingSettings settings ->
            ChangeSettings
                { unitedStatesDateNotation = settings.unitedStatesDateNotation
                , language = settings.language
                , changedUnitedStatesDateNotation = always NoOp
                , changedLanguage = always NoOp
                , pressedSettingsCancelButton = PressedSettingsCancelButton
                , pressedSettingsDoneButton = PressedSettingsDoneButton
                }

        _ ->
            Default
                { emphasis =
                    case model.action of
                        Idle ->
                            View.RecordList

                        _ ->
                            View.Sidebar
                , searchQuery = model.searchQuery
                , records = recordsConfig model
                , sidebar = sidebarConfig model
                , clickedSettings = PressedSettingsButton
                , changedSearchQuery = SearchQueryChanged
                }


recordsConfig : Model -> RecordList.Config Msg
recordsConfig { records, searchQuery } =
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
            |> List.map recordConfig
            |> RecordList.ManyRecords


recordConfig : ( Int, Record ) -> Record.Config Msg
recordConfig ( id, record ) =
    { description = record.description
    , date = "today"
    , duration = "15 minutes"
    , status =
        Record.NotSelected
            { select = always NoOp
            }
    }


sidebarConfig : Model -> Sidebar.Config Msg
sidebarConfig {} =
    Sidebar.Idle { pressedStart = PressedStartButton }


rootElement : Config Msg -> Element Msg
rootElement config =
    case config of
        ChangeSettings settings ->
            Settings.view settings

        Default defaultViewConfig ->
            DefaultView.view defaultViewConfig
