module Settings exposing
    ( Config
    , Settings
    , decoder
    , encode
    , view
    )

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
        [ Element.el
            [ Element.Border.rounded 8
            , Background.color Colors.whiteBackground
            , Element.width Element.fill
            ]
            (View.settingsToggle
                { label = Text.UsaDateNotation
                , language = config.language
                , checked = config.dateNotation == Utils.Date.unitedStatesNotation
                , onChange =
                    \val ->
                        config.changedDateNotation <|
                            if val then
                                Utils.Date.unitedStatesNotation

                            else
                                Utils.Date.westernNotation
                , padding = 16
                }
            )
        , Element.Input.radio
            [ Background.color Colors.whiteBackground
            , Element.Border.rounded 8
            , Element.Border.width 1
            , Element.Border.color Colors.transparent
            , Element.focused
                [ Element.Border.color Colors.accent
                ]
            , Element.width Element.fill
            ]
            { onChange = config.changedLanguage
            , selected = Just config.language
            , label =
                Element.Input.labelHidden <|
                    Text.toString config.language Text.LanguageLabel
            , options =
                let
                    label text =
                        Text.text14 config.language text
                            |> Element.el [ Element.width Element.fill ]

                    customRadio text optionState =
                        case optionState of
                            Element.Input.Idle ->
                                Element.row
                                    [ Element.width Element.fill
                                    , Element.padding 16
                                    ]
                                    [ label text
                                    , Element.none
                                        |> Element.el [ Element.height (Element.px 16) ]
                                    ]

                            Element.Input.Focused ->
                                Element.row
                                    [ Element.width Element.fill
                                    , Element.padding 16
                                    ]
                                    [ label text
                                    , Icons.check16
                                        |> Element.el [ Element.Font.color Colors.accent ]
                                    ]

                            Element.Input.Selected ->
                                Element.row
                                    [ Element.width Element.fill
                                    , Element.padding 16
                                    ]
                                    [ label text
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
                            , View.horizontalDivider View.White
                            ]
                in
                [ customRadioWithDivider Text.EnglishLanguage
                    |> Element.Input.optionWith Text.English
                , customRadio Text.SpanishLanguage
                    |> Element.Input.optionWith Text.Spanish
                ]
            }
        ]


settingsGroup : List (Element msg) -> Element msg
settingsGroup children =
    Element.column
        [ Element.Border.rounded 8
        , Background.color Colors.whiteBackground
        , Element.width Element.fill
        ]
        (children
            |> List.intersperse (View.horizontalDivider View.White)
        )


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
