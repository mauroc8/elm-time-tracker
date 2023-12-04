module Settings exposing
    ( Config
    , Settings
    , store
    , view
    )

import Calendar
import Colors
import Element exposing (Element)
import Element.Background as Background
import Element.Border
import Element.Font
import Element.Input
import Icons
import Json.Decode
import Json.Encode
import LocalStorage
import Text
import Ui
import Utils.Date



--- Settings


type alias Settings =
    { dateNotation : Utils.Date.Notation
    , language : Text.Language
    }


store : LocalStorage.Store Settings
store =
    LocalStorage.store
        { key = "settings"
        , encode = encode
        , decoder = decoder
        }


decoder : Json.Decode.Decoder Settings
decoder =
    Json.Decode.map2 Settings
        (Json.Decode.field "dateNotation" Utils.Date.notationDecoder)
        (Json.Decode.field "language" Text.languageDecoder)


encode : Settings -> Json.Decode.Value
encode { dateNotation, language } =
    Json.Encode.object
        [ ( "dateNotation", Utils.Date.encodeNotation dateNotation )
        , ( "language", Text.encodeLanguage language )
        ]



--- Ui


type alias Config msg =
    { dateNotation : Utils.Date.Notation
    , language : Text.Language
    , changedDateNotation : Utils.Date.Notation -> msg
    , changedLanguage : Text.Language -> msg
    , pressedSettingsCancelButton : msg
    , pressedSettingsDoneButton : msg
    , viewport : Ui.Viewport
    , today : Calendar.Date
    }


view : Config msg -> Element msg
view config =
    Ui.modalContent
        { header = settingsHeader config.language
        , body = [ settingsBody config, aboutLink config ]
        , footer = settingsFooter config
        , viewport = config.viewport
        , onClose = config.pressedSettingsCancelButton
        }


settingsHeader : Text.Language -> Element msg
settingsHeader language =
    Text.text24 language Text.SettingsHeading


settingsBody : Config msg -> Element msg
settingsBody config =
    Element.column
        [ Element.spacing 16
        , Element.width Element.fill
        ]
        [ radioInputGroup
            { onChange = config.changedLanguage
            , selected = config.language
            , label = Text.LanguageLabel
            , language = config.language
            , options =
                [ { label = Text.text14 config.language Text.EnglishLanguage
                  , value = Text.English
                  }
                , { label = Text.text14 config.language Text.SpanishLanguage
                  , value = Text.Spanish
                  }
                ]
            }
        , let
            label blackText grayText =
                (case config.viewport of
                    Ui.Mobile ->
                        Element.column

                    Ui.Desktop ->
                        Element.row
                )
                    [ Element.spacing 8 ]
                    [ Text.text14 config.language blackText
                    , Text.text12 config.language grayText
                        |> Element.el
                            [ Element.Font.color Colors.grayText
                            , Element.alignBottom
                            ]
                    ]
          in
          radioInputGroup
            { onChange = config.changedDateNotation
            , selected = config.dateNotation
            , label = Text.DateNotationLabel
            , language = config.language
            , options =
                [ { label =
                        label Text.InternationalDateNotation
                            (Utils.Date.toLabel Utils.Date.westernNotation config.today)
                  , value = Utils.Date.westernNotation
                  }
                , { label =
                        label Text.UsaDateNotation
                            (Utils.Date.toLabel Utils.Date.unitedStatesNotation config.today)
                  , value = Utils.Date.unitedStatesNotation
                  }
                ]
            }
        ]


aboutLink : { a | language : Text.Language } -> Element msg
aboutLink config =
    let
        color =
            Colors.blackishText

        focusColor =
            Colors.accent

        zero =
            { top = 0, left = 0, right = 0, bottom = 0 }
    in
    Element.newTabLink
        [ Element.Font.color color

        --
        , Element.paddingEach { zero | bottom = 4 }
        , Element.Border.widthEach { zero | bottom = 1 }
        , Element.Border.color color
        , Element.focused
            [ Element.Font.color focusColor
            , Element.Border.color focusColor
            ]
        ]
        { url = "https://github.com/mauroc8/elm-time-tracker#readme"
        , label =
            Element.row
                [ Element.spacing 6 ]
                [ Text.text14 config.language Text.AboutThisWebsite
                , Icons.externalLink
                ]
        }


radioInputGroup :
    { onChange : a -> msg
    , selected : a
    , label : Text.Text
    , language : Text.Language
    , options : List { label : Element msg, value : a }
    }
    -> Element msg
radioInputGroup config =
    Element.Input.radio
        [ Background.color Colors.grayBackground
        , Element.Border.rounded 8
        , Element.Border.width 1
        , Element.Border.color Colors.transparent
        , Element.focused
            [ Element.Border.color Colors.accent
            ]
        , Element.width Element.fill
        ]
        { onChange = config.onChange
        , selected = Just config.selected
        , label =
            Element.Input.labelHidden <|
                Text.toString config.language config.label
        , options =
            let
                customRadio label optionState =
                    case optionState of
                        Element.Input.Idle ->
                            Element.row
                                [ Element.width Element.fill
                                , Element.padding 16
                                ]
                                [ label
                                    |> Element.el [ Element.width Element.fill ]
                                , Element.none
                                    |> Element.el
                                        [ Element.width (Element.px 16)
                                        , Element.height (Element.px 16)
                                        ]
                                ]

                        Element.Input.Focused ->
                            Element.row
                                [ Element.width Element.fill
                                , Element.padding 16
                                ]
                                [ label
                                    |> Element.el [ Element.width Element.fill ]
                                , Icons.check16
                                    |> Element.el [ Element.Font.color Colors.accent ]
                                ]

                        Element.Input.Selected ->
                            Element.row
                                [ Element.width Element.fill
                                , Element.padding 16
                                ]
                                [ label
                                    |> Element.el [ Element.width Element.fill ]
                                , Icons.check16
                                    |> Element.el [ Element.Font.color Colors.accent ]
                                ]

                customRadioWithDivider text optionState =
                    Element.column
                        [ Element.width Element.fill
                        , Element.Border.width 1
                        , Element.Border.color Colors.transparent
                        ]
                        [ customRadio text optionState
                        ]

                radioWithDividerFromOption option =
                    customRadioWithDivider option.label
                        |> Element.Input.optionWith option.value
            in
            case config.options of
                option :: otherOptions ->
                    (customRadio option.label
                        |> Element.Input.optionWith option.value
                    )
                        :: List.map radioWithDividerFromOption otherOptions

                [] ->
                    []
        }


settingsFooter : Config msg -> Element msg
settingsFooter { pressedSettingsCancelButton, pressedSettingsDoneButton, language, viewport } =
    Ui.cancelConfirmButtons
        { onCancel = pressedSettingsCancelButton
        , onConfirm = pressedSettingsDoneButton
        , confirmText = Text.Save
        , language = language
        , viewport = viewport
        }
