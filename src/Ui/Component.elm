module Ui.Component exposing (biggerButton, button)

import Colors
import Html exposing (Html)
import Html.Events
import Ui


button : msg -> List (Ui.Attribute msg) -> List (Html msg) -> Html msg
button onClick attrs children =
    baseButton onClick [ Ui.style "font-size" "1rem", Ui.batch attrs ] children


biggerButton : msg -> List (Ui.Attribute msg) -> List (Html msg) -> Html msg
biggerButton onClick attrs children =
    baseButton onClick [ Ui.style "font-size" "1.25rem", Ui.batch attrs ] children


baseButton : msg -> List (Ui.Attribute msg) -> List (Html msg) -> Html msg
baseButton onClick attrs children =
    Ui.button onClick
        [ Ui.spacing 4
        , Ui.centerY
        , Ui.style "text-transform" "uppercase"
        , Ui.style "cursor" "pointer"
        , Ui.style "color" Colors.accentBlue
        , Ui.batch attrs
        ]
        children
