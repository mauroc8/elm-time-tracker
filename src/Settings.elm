module Settings exposing
    ( ChangeSettingsConfig
    , Language(..)
    , Settings
    , defaultLanguage
    , defaultUnitedStatesDateNotation
    , view
    )

import Colors
import Element exposing (Element)
import Element.Background as Background
import Element.Border
import Element.Font
import Element.Region
import View



--- Settings


type alias Settings =
    { unitedStatesDateNotation : Bool
    , language : Language
    }


defaultUnitedStatesDateNotation : Bool
defaultUnitedStatesDateNotation =
    False



--- Language


type Language
    = English
    | Spanish


defaultLanguage : Language
defaultLanguage =
    English



--- View


type alias ChangeSettingsConfig msg =
    { unitedStatesDateNotation : Bool
    , language : Language
    , changedUnitedStatesDateNotation : Bool -> msg
    , changedLanguage : Language -> msg
    , pressedSettingsCancelButton : msg
    , pressedSettingsDoneButton : msg
    }


view : ChangeSettingsConfig msg -> Element msg
view config =
    Element.column
        [ Element.width Element.fill
        , Element.height Element.fill
        , Element.padding 24
        , Element.spacing 24
        , Background.color Colors.grayBackground
        ]
        [ settingsHeader
        , settingsBody
        , settingsFooter config
        ]


settingsHeader : Element msg
settingsHeader =
    Element.el
        ([ Element.Region.heading 1
         , Element.Font.semiBold
         ]
            ++ View.fontSize24
        )
        (Element.text "Settings")


settingsBody : Element msg
settingsBody =
    Element.column
        [ Element.spacing 16
        , Element.width Element.fill
        ]
        [ settingsGroup
            [ Element.text "USA date notation (mm/dd/yy)"
            ]
        , settingsGroup
            [ Element.text "English"
            , Element.text "Español"
            ]
        ]


settingsGroup : List (Element msg) -> Element msg
settingsGroup children =
    Element.column
        [ Element.Border.rounded 8
        , Background.color Colors.whiteBackground
        , Element.width Element.fill
        ]
        (List.map
            (Element.el
                ([ Element.padding 16
                 , Element.width Element.fill
                 ]
                    ++ View.fontSize14
                )
            )
            children
            |> List.intersperse
                (Element.el
                    [ Element.width Element.fill
                    , Element.height (Element.px 1)
                    , Background.color Colors.grayBackground
                    ]
                    Element.none
                )
        )


settingsFooter : ChangeSettingsConfig msg -> Element msg
settingsFooter { pressedSettingsCancelButton, pressedSettingsDoneButton } =
    Element.row
        [ Element.alignBottom
        , Element.width Element.fill
        ]
        [ View.linkLikeButton
            { onPress = pressedSettingsCancelButton
            , label = "Cancel"
            , bold = False
            }
        , Element.el [ Element.alignRight ]
            (View.linkLikeButton
                { onPress = pressedSettingsDoneButton
                , label = "Done"
                , bold = True
                }
            )
        ]
