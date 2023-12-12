module Ui.Input exposing (button)

import Html exposing (Html)
import Html.Events
import Ui


button : msg -> List (Ui.Attribute msg) -> List (Html msg) -> Html msg
button onClick attrs children =
    Ui.row
        (Ui.htmlTag "button"
            :: Ui.attribute (Html.Events.onClick onClick)
            :: attrs
        )
        children
