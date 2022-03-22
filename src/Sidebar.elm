module Sidebar exposing (Config(..), view)

import Colors
import CreateForm
import Element exposing (Element)
import Element.Font
import Icons
import View



--- SIDE BAR


type Config msg
    = Idle { pressedStart : msg }
    | CreatingRecord (CreateForm.Config msg)


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

        CreatingRecord createFormConfig ->
            CreateForm.view createFormConfig
