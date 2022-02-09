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
    { status : Status
    , records : Records
    , selectedRecord : Maybe Record.Id
    , searchQuery : String

    -- Settings
    , unitedStatesDateNotation : Bool
    , language : Lang

    -- Time
    , now : Time.Posix
    , timeZone : Time.Zone

    -- Responsiveness
    , windowWidth : Int
    , windowHeight : Int

    -- Autosave
    , lastSaved : Time.Posix
    }


initialModel : Model
initialModel =
    { status = Idle
    , records = Records.empty
    , selectedRecord = Nothing
    , searchQuery = ""
    , unitedStatesDateNotation = False
    , language = Lang.English
    , now = Time.millisToPosix 0
    , timeZone = Time.utc
    , windowWidth = 0
    , windowHeight = 0
    , lastSaved = Time.millisToPosix 0
    }


setTimeZone timeZone model =
    { model | timeZone = timeZone }


setCurrentTime posixTime model =
    { model | now = posixTime }


setSearchQuery searchQuery model =
    { model | searchQuery = searchQuery }



--- Status


type Status
    = Idle
    | CreatingRecord CreateForm
    | EditingRecord EditForm
    | ChangingSettings SettingsForm



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



--- Settings Form


type alias SettingsForm =
    { unitedStatesDateNotation : Bool
    , language : Lang
    }


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
        ChangingSettings settingsForm ->
            View.settings

        _ ->
            Element.column
                [ Element.width Element.fill
                , Element.height Element.fill
                ]
                [ View.header
                    { emphasis =
                        if status == Idle then
                            View.highlight

                        else
                            View.deemphasize
                    , searchQuery = searchQuery
                    , onSearchQueryChange = SearchQueryChanged
                    }
                , View.body
                    { emphasis =
                        if status == Idle then
                            View.highlight

                        else
                            View.deemphasize
                    , content =
                        if records == Records.empty then
                            View.bodyWithNoRecords

                        else
                            View.bodyWithRecords records
                    }
                , View.footer
                ]
