module Sidebar exposing (Config(..), view)

import Colors
import CreateRecord
import Element exposing (Element)
import Element.Font
import Icons
import View



--- SIDE BAR


type Config msg
    = Idle { pressedStart : msg }
    | CreateRecord (CreateRecord.Config msg)


view : Config msg -> Element msg
view config =
    case config of
        Idle { pressedStart } ->
            View.button
                [ Element.centerX
                , Element.Font.color Colors.lightGrayText
                , Element.focused
                    [ Element.Font.color Colors.accent
                    ]
                ]
                { onPress = View.enabled pressedStart
                , label = Icons.playButton
                }

        CreateRecord createFormConfig ->
            CreateRecord.view createFormConfig
