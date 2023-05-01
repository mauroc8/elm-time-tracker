module StartButton exposing (view)

import Colors
import Element exposing (Element)
import Element.Font
import Icons
import View



--- SIDE BAR


view : { pressedStart : msg, modalIsOpen : Bool } -> Element msg
view { pressedStart, modalIsOpen } =
    View.button
        [ Element.centerX
        , Element.Font.color Colors.lightGrayText
        , Element.focused
            [ Element.Font.color Colors.accent
            ]
        ]
        { onPress =
            View.enabled pressedStart
                |> View.disableIf modalIsOpen
        , label = Icons.playButton
        }
