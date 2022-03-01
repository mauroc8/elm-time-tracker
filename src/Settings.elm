module Settings exposing
    ( Config
    , Settings
    , defaultUnitedStatesDateNotation
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
import Text
import View



--- Settings


type alias Settings =
    { unitedStatesDateNotation : Bool
    , language : Text.Language
    }


defaultUnitedStatesDateNotation : Bool
defaultUnitedStatesDateNotation =
    False



--- View


type alias Config msg =
    { unitedStatesDateNotation : Bool
    , language : Text.Language
    , changedUnitedStatesDateNotation : Bool -> msg
    , changedLanguage : Text.Language -> msg
    , pressedSettingsCancelButton : msg
    , pressedSettingsDoneButton : msg
    }


view : Config msg -> Element msg
view config =
    Element.column
        [ Element.width Element.fill
        , Element.height Element.fill
        , Element.padding 24
        , Element.spacing 24
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
                , checked = config.unitedStatesDateNotation
                , onChange = config.changedUnitedStatesDateNotation
                , padding = 16
                }
            )
        , Element.Input.radio
            [ Background.color Colors.whiteBackground
            , Element.Border.rounded 8
            , Element.width Element.fill
            ]
            { onChange = config.changedLanguage
            , selected = Just config.language
            , label =
                Element.Input.labelHidden <|
                    Text.toString config.language Text.LanguageLabel
            , options =
                let
                    customRadio text optionState =
                        Element.row
                            [ Element.width Element.fill
                            , Element.padding 16
                            ]
                            [ Text.text14 config.language text
                                |> Element.el [ Element.width Element.fill ]
                            , case optionState of
                                Element.Input.Idle ->
                                    Element.none
                                        |> Element.el [ Element.height (Element.px 16) ]

                                Element.Input.Focused ->
                                    Icons.check16
                                        |> Element.el [ Element.Font.color Colors.accent ]

                                Element.Input.Selected ->
                                    Icons.check16
                                        |> Element.el [ Element.Font.color Colors.blackishText ]
                            ]

                    customRadioWithDivider text optionState =
                        Element.column
                            [ Element.width Element.fill
                            ]
                            [ customRadio text optionState
                            , View.horizontalDivider View.White
                            ]
                in
                [ Element.Input.optionWith Text.English (customRadioWithDivider Text.EnglishLanguage)
                , Element.Input.optionWith Text.Spanish (customRadio Text.SpanishLanguage)
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
settingsFooter { pressedSettingsCancelButton, pressedSettingsDoneButton, language } =
    Element.row
        [ Element.alignBottom
        , Element.width Element.fill
        ]
        [ View.linkLikeButton
            { onPress = pressedSettingsCancelButton
            , label = Text.Cancel
            , language = language
            , bold = False
            }
        , Element.el [ Element.alignRight ]
            (View.linkLikeButton
                { onPress = pressedSettingsDoneButton
                , label = Text.Save
                , language = language
                , bold = True
                }
            )
        ]
