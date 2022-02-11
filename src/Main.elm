module Main exposing (..)

import Browser
import Colors
import DateTime
import Dict exposing (Dict)
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font exposing (Font)
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes
import Icons
import Lang exposing (Lang)
import Platform exposing (Task)
import Record exposing (Record)
import Records exposing (Records)
import Task
import Time
import Utils.Out as Out
import View



--- Model


type alias Model =
    { -- Entities
      records : Records

    -- UI
    , status : Action
    , selectedRecord : Maybe Record.Id
    , searchQuery : String

    -- Settings
    , unitedStatesDateNotation : Bool
    , language : Lang

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
    { status = NoAction
    , records = Records.empty
    , selectedRecord = Nothing
    , searchQuery = ""
    , unitedStatesDateNotation = defaultSettings.unitedStatesDateNotation
    , language = defaultSettings.language
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


setStatus status model =
    { model | status = status }


{-| Returns the unsaved settings of the "Settings" form, or
the saved settings.
-}
appliedSettings : Model -> Settings
appliedSettings model =
    case model.status of
        ChangeSettings settings ->
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



--- Action


type Action
    = NoAction
    | CreateRecord CreateForm
    | EditRecord EditForm
    | ChangeSettings Settings



--- Create Form


type alias CreateForm =
    { start : Time.Posix
    , description : String
    }



--- Edit Form


type alias EditForm =
    { id : Record.Id
    , description : String
    , start : String
    , end : String
    , duration : String
    , date : String
    }



--- Settings


type alias Settings =
    { unitedStatesDateNotation : Bool
    , language : Lang
    }


defaultSettings : Settings
defaultSettings =
    { unitedStatesDateNotation = False
    , language = Lang.English
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
                (ChangeSettings
                    { unitedStatesDateNotation = model.unitedStatesDateNotation
                    , language = model.language
                    }
                )
                model
                |> Out.withNoCmd

        PressedSettingsCancelButton ->
            setStatus NoAction model
                |> Out.withNoCmd

        PressedSettingsDoneButton ->
            setStatus NoAction model
                |> setSettings (appliedSettings model)
                |> Out.withNoCmd



--- VIEW


view : Model -> Html Msg
view model =
    Element.layoutWith
        { options =
            [ Element.focusStyle focusStyle
            ]
        }
        rootAttributes
        (rootElement model)


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


rootElement : Model -> Element Msg
rootElement { status, searchQuery, records } =
    case status of
        ChangeSettings settingsForm ->
            View.settings
                { pressedCancelButton = PressedSettingsCancelButton
                , pressedDoneButton = PressedSettingsDoneButton
                }

        _ ->
            Element.column
                [ Element.width Element.fill
                , Element.height Element.fill
                ]
                [ View.header
                    { emphasis =
                        if status == NoAction then
                            View.highlight

                        else
                            View.deemphasize
                    , searchQuery = searchQuery
                    , searchQueryChanged = SearchQueryChanged
                    , pressedSettingsButton = PressedSettingsButton
                    }
                , View.body
                    { emphasis =
                        if status == NoAction then
                            View.highlight

                        else
                            View.deemphasize
                    , content =
                        if records == Records.empty then
                            View.bodyWithNoRecords

                        else
                            let
                                searchResults =
                                    Records.search searchQuery records
                            in
                            if searchResults == Records.empty then
                                View.bodyWithNoSearchResults

                            else
                                View.bodyWithRecords searchResults
                    }
                , View.footer
                ]
