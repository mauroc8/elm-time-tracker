module Main exposing (Modal, Model, Msg, main)

import Browser
import Browser.Dom
import Browser.Events
import ChangeStartTime
import Clock
import DateTime
import Colors
import ConfirmDeletion
import CreateRecord exposing (CreateRecord)
import Element exposing (Attribute, Element)
import Element.Font as Font
import Html exposing (Html)
import Html.Attributes
import Icons
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
import Utils.Time
import View exposing (Emphasis)



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
    , createRecordForm : Maybe CreateRecord
    , modal : Modal

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
    { createRecordForm = Nothing
    , modal = ClosedModal
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


setModal : Modal -> Model -> Model
setModal modal model =
    { model | modal = modal }


setSettings : Settings -> Model -> Model
setSettings settings model =
    { model
        | dateNotation = settings.dateNotation
        , language = settings.language
    }


editDateNotation : Utils.Date.Notation -> Model -> Model
editDateNotation dateNotation model =
    case model.modal of
        ChangeSettingsModal settings ->
            setModal
                (ChangeSettingsModal
                    { settings
                        | dateNotation = dateNotation
                    }
                )
                model

        _ ->
            { model | dateNotation = dateNotation }


editLanguage : Language -> Model -> Model
editLanguage language model =
    case model.modal of
        ChangeSettingsModal settings ->
            setModal
                (ChangeSettingsModal
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
        |> setCreateRecord (Just <| CreateRecord.new description model.currentTime)
        |> Out.withCmd
            (\_ ->
                Browser.Dom.focus CreateRecord.descriptionInputId
                    |> Task.attempt (\_ -> FocusedCreateFormDescriptionInput)
            )
        |> Out.addCmd (\_ -> PreventClose.on)


setCreateRecord : Maybe CreateRecord -> Model -> Model
setCreateRecord createRecord model =
    { model | createRecordForm = createRecord }


stopCreatingRecord : Model -> ( Model, Cmd Msg )
stopCreatingRecord model =
    case model.createRecordForm of
        Just createForm ->
            let
                record =
                    Record.fromCreateForm model.currentTime createForm
            in
            model
                |> pushRecord record
                |> setCreateRecord Nothing
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
    case model.createRecordForm of
        Just createForm ->
            setCreateRecord
                (Just
                    { createForm
                        | description = description
                    }
                )
                model

        _ ->
            model


changeCreateFormStartTime : Clock.Time -> Model -> Model
changeCreateFormStartTime startTime ({ createRecordForm, timeZone, currentTime } as model) =
    case createRecordForm of
        Just createRecord ->
            case CreateRecord.setStartTime model startTime createRecord of
                Ok updatedCreateRecord ->
                    model
                        |> setCreateRecord (Just updatedCreateRecord)
                        |> setModal ClosedModal

                Err errorMessage ->
                    case model.modal of
                        ChangeStartTimeModal changeStartTimeModel ->
                            model
                                |> setModal (ChangeStartTimeModal { changeStartTimeModel | inputError = Just errorMessage })

                        _ ->
                            model

        _ ->
            model


loadCreateForm : Json.Decode.Value -> Model -> Model
loadCreateForm flags model =
    LocalStorage.load
        { store = LocalStorage.createForm
        , flags = flags
        }
        |> Result.map (\createForm -> { model | createRecordForm = Just createForm })
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
    case model.createRecordForm of
        Just createForm ->
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
    getModalSettings model.modal
        |> Maybe.withDefault (savedSettings model)



--- Modal


type Modal
    = ClosedModal
    | ChangeSettingsModal Settings
    | ConfirmDeletionModal Record.Id
    | ChangeStartTimeModal ChangeStartTime.Model


getModalSettings : Modal -> Maybe Settings
getModalSettings modal =
    case modal of
        ChangeSettingsModal settings ->
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
      -- Change start time
    | ConfirmStartTime Clock.Time
    | CancelStartTime
    | ChangeStartTime ChangeStartTime.Model
      -- Record List
    | ClickedDeleteButton Record.Id
      -- Confirm deletion modal
    | CancelDeleteRecord
    | ConfirmDeleteRecord Record.Id


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
            setModal
                (ChangeSettingsModal
                    { dateNotation = model.dateNotation
                    , language = model.language
                    }
                )
                model
                |> Out.withNoCmd

        -- Settings
        PressedSettingsCancelButton ->
            setModal ClosedModal model
                |> Out.withNoCmd

        PressedSettingsDoneButton ->
            setModal ClosedModal model
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
                |> setModal ClosedModal
                |> Out.withCmd saveCreateForm

        PressedChangeStartTimeInCreateRecord ->
            case model.createRecordForm of
                Just createForm ->
                    model
                        |> setModal (ChangeStartTimeModal <| ChangeStartTime.initialModel model createForm)
                        |> Out.withNoCmd

                Nothing ->
                    model |> Out.withNoCmd

        FocusedCreateFormDescriptionInput ->
            model
                |> Out.withNoCmd

        -- Change start time
        ConfirmStartTime newStartTime ->
            model
                |> changeCreateFormStartTime newStartTime
                |> Out.withNoCmd

        CancelStartTime ->
            model
                |> setModal ClosedModal
                |> Out.withNoCmd

        ChangeStartTime changeStartTimeModel ->
            model
                |> setModal (ChangeStartTimeModal changeStartTimeModel)
                |> Out.withNoCmd

        -- Record List
        ClickedDeleteButton id ->
            { model | modal = ConfirmDeletionModal id }
                |> Out.withNoCmd

        -- Confirm deletion modal
        CancelDeleteRecord ->
            { model | modal = ClosedModal }
                |> Out.withNoCmd

        ConfirmDeleteRecord id ->
            { model
                | records = RecordList.delete id model.records
                , modal = ClosedModal
            }
                |> Out.withCmd saveRecords



--- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ if model.visibility == Browser.Events.Visible then
            case model.createRecordForm of
                Just createForm ->
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
    let
        ( attrs, el ) =
            rootElement model
    in
    Element.layoutWith
        { options =
            [ Element.focusStyle focusStyle
            ]
        }
        attrs
        el


focusStyle : Element.FocusStyle
focusStyle =
    { borderColor = Just Colors.accent
    , backgroundColor = Nothing
    , shadow = Nothing
    }


rootElement : Model -> ( List (Attribute Msg), Element Msg )
rootElement model =
    let
        emphasis =
            case model.createRecordForm of
                Just _ ->
                    View.TopBar

                Nothing ->
                    View.RecordList

        modalIsOpen =
            model.modal /= ClosedModal

        topBar =
            case model.createRecordForm of
                Just createRecord ->
                    CreateRecord.view
                        { description = createRecord.description
                        , elapsedTime =
                            Utils.Duration.fromTimeDifference model.currentTime createRecord.start
                                |> Utils.Duration.label
                        , changedDescription = ChangedCreateFormDescription
                        , pressedStop = PressedStopButton
                        , pressedEnter = PressedEnterInCreateRecord
                        , pressedEscape = PressedEscapeInCreateRecord
                        , pressedChangeStartTime = PressedChangeStartTimeInCreateRecord
                        , language = model.language
                        , modalIsOpen = modalIsOpen
                        }

                Nothing ->
                    StartButton.view
                        { pressedStart = PressedStartButton
                        , modalIsOpen = modalIsOpen
                        }

        config =
            { emphasis = emphasis
            , records = model.records
            , topBar = topBar
            , clickedSettings = PressedSettingsButton
            , language = model.language
            , viewport = model.viewport
            , clickedDeleteButton = ClickedDeleteButton
            , currentTime = model.currentTime
            , dateNotation = model.dateNotation
            , timeZone = model.timeZone
            , modalIsOpen = modalIsOpen
            }

        viewRecordListWithHeading =
            [ -- Heading
              headingSection config
                |> withHeaderLayout config
                |> withHorizontalDivider emphasis

            -- RecordList
            , RecordList.view config
            ]

        topBarWrapped =
            [ topBar
                |> Element.el
                    [ Element.width (Element.fill |> Element.maximum 600)
                    , Element.padding 24
                    , Element.centerX
                    ]
                |> Element.el
                    (Element.width Element.fill :: View.sidebarBackgroundColor emphasis)
            ]

        shared =
            [ Element.width Element.fill
            , Element.height Element.fill
            , Font.family [ Font.typeface "Manrope", Font.sansSerif ]
            ]
                ++ (case viewModal config model.modal of
                        Just modal ->
                            [ Element.inFront modal
                            , Element.htmlAttribute (Html.Attributes.style "height" "100vh")
                            ]

                        Nothing ->
                            [ Element.height Element.fill ]
                   )
    in
    ( shared
        ++ View.recordListBackgroundColor emphasis
    , Element.column
        [ Element.width Element.fill
        , Element.height Element.fill
        , if modalIsOpen then
            Element.clipX

          else
            Element.scrollbarX
        ]
        (topBarWrapped
            ++ (case config.viewport of
                    View.Mobile ->
                        viewRecordListWithHeading

                    View.Desktop ->
                        [ Element.column
                            [ Element.width (Element.fill |> Element.maximum 600)
                            , Element.centerX
                            , Element.height Element.fill
                            ]
                            viewRecordListWithHeading
                        ]
               )
        )
    )


viewModal config modal =
    case modal of
        ChangeSettingsModal settings ->
            Settings.view
                { dateNotation = settings.dateNotation
                , language = settings.language
                , changedDateNotation = ChangedDateNotation
                , changedLanguage = ChangedLanguage
                , pressedSettingsCancelButton = PressedSettingsCancelButton
                , pressedSettingsDoneButton = PressedSettingsDoneButton
                , viewport = config.viewport
                , today = Utils.Date.fromZoneAndPosix config.timeZone config.currentTime
                }
                |> Just

        ConfirmDeletionModal recordId ->
            ConfirmDeletion.view
                { onConfirm = ConfirmDeleteRecord recordId
                , onCancel = CancelDeleteRecord
                , viewport = config.viewport
                , language = config.language
                }
                |> Just

        ChangeStartTimeModal changeStartTimeModel ->
            ChangeStartTime.view
                { onConfirm = ConfirmStartTime
                , onCancel = CancelStartTime
                , onChange = ChangeStartTime
                , viewport = config.viewport
                , language = config.language
                }
                changeStartTimeModel
                |> Just

        ClosedModal ->
            Nothing


type alias Config msg =
    { emphasis : Emphasis
    , language : Text.Language
    , viewport : View.Viewport
    , currentTime : Time.Posix
    , dateNotation : Utils.Date.Notation
    , timeZone : Time.Zone
    , records : RecordList.RecordList
    , topBar : Element.Element msg
    , clickedSettings : msg
    , clickedDeleteButton : Record.Id -> msg
    , modal : Modal
    }



--- Heading


headingSection :
    { a
        | clickedSettings : msg
        , modalIsOpen : Bool
    }
    -> Element msg
headingSection { clickedSettings, modalIsOpen } =
    let
        settingsButton =
            View.accentButton
                { onPress =
                    View.enabled clickedSettings
                        |> View.disableIf modalIsOpen
                , label = Icons.options
                }
    in
    Element.row
        [ Element.spacing 16
        , Element.width Element.fill
        ]
        [ settingsButton
        ]


withHeaderLayout : { config | viewport : View.Viewport } -> Element msg -> Element msg
withHeaderLayout { viewport } =
    let
        padding =
            case viewport of
                View.Mobile ->
                    Element.padding 16

                View.Desktop ->
                    Element.paddingXY 0 16
    in
    Element.el
        [ padding
        , Element.width Element.fill
        ]


withHorizontalDivider : Emphasis -> Element msg -> Element msg
withHorizontalDivider emphasis el =
    Element.column
        [ Element.width Element.fill
        ]
        [ el
        , View.recordListHorizontalDivider emphasis
        ]
