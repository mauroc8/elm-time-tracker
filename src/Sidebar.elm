module Sidebar exposing (Config(..), view)

import CreateForm
import Element exposing (Element)
import Element.Input
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
                ]
                { onPress = View.enabled pressedStart
                , label = Icons.playButton
                }

        CreatingRecord createFormConfig ->
            CreateForm.view createFormConfig
