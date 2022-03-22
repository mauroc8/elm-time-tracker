module Settings exposing
    ( Config
    , Settings
    , decoder
    , encode
    , view
    )

import Calendar
import Colors
import Element exposing (Element)
import Element.Background as Background
import Element.Border
import Element.Font
import Element.Input
import Element.Region
import Icons
import Json.Decode
import Json.Encode
import Text
import Utils
import Utils.Date
import View



--- Settings


type alias Settings =
    { dateNotation : Utils.Date.Notation
    , language : Text.Language
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



--- View


type alias Config msg =
    { dateNotation : Utils.Date.Notation
    , language : Text.Language
    , changedDateNotation : Utils.Date.Notation -> msg
    , changedLanguage : Text.Language -> msg
    , pressedSettingsCancelButton : msg
    , pressedSettingsDoneButton : msg
    , viewport : View.Viewport
    , today : Calendar.Date
    }


view : Config msg -> Element msg
view config =
    let
        ( padding, spacing ) =
            case config.viewport of
                View.Mobile ->
                    ( 24, 24 )

                View.Desktop ->
                    ( 48, 32 )
    in
    Element.column
        [ Element.width Element.fill
        , Element.centerX
        , case config.viewport of
            View.Mobile ->
                Element.height Element.fill

            View.Desktop ->
                Element.width (Element.maximum 600 Element.fill)
        , Element.padding padding
        , Element.spacing spacing
        ]
        [ settingsHeader config.language
        , settingsBody config
        , aboutLink config
        , settingsFooter config
        ]


settingsHeader : Text.Language -> Element msg
settingsHeader language =
    Element.el
        [ Element.Region.heading 1
        , Element.Font.semiBold
        ]
        (Text.text24 language Text.SettingsHeading)


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
                    View.Mobile ->
                        Element.column

                    View.Desktop ->
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
                            (Utils.Date.toText Utils.Date.westernNotation config.today)
                  , value = Utils.Date.westernNotation
                  }
                , { label =
                        label Text.UsaDateNotation
                            (Utils.Date.toText Utils.Date.unitedStatesNotation config.today)
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
        { url = "https://github.com/mauroc8/simple-time-tracker#readme"
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
        [ Background.color Colors.whiteBackground
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
                        [ View.horizontalDivider View.White
                        , customRadio text optionState
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
    Element.row
        [ Element.alignBottom
        , Element.width Element.fill
        , Element.spacing 32
        ]
        [ View.linkLikeButton
            { onPress = pressedSettingsCancelButton
            , label = Text.Cancel
            , language = language
            , bold = False
            }
            |> Element.el
                [ case viewport of
                    View.Mobile ->
                        Utils.emptyAttribute

                    View.Desktop ->
                        Element.alignRight
                ]
        , View.linkLikeButton
            { onPress = pressedSettingsDoneButton
            , label = Text.Save
            , language = language
            , bold = True
            }
            |> Element.el
                [ Element.alignRight ]
        ]
