module StartButton exposing (view)

import Colors
import Element exposing (Element)
import Element.Font
import Icons
import Ui



--- SIDE BAR


view : { pressedStart : msg, modalIsOpen : Bool } -> Element msg
view { pressedStart, modalIsOpen } =
    Ui.button
        [ Element.centerX
        , Element.Font.color Colors.lightGrayText
        , Element.focused
            [ Element.Font.color Colors.accent
            ]
        ]
        { onPress =
            Ui.enabled pressedStart
                |> Ui.disableIf modalIsOpen
        , label = Icons.playButton
        }
