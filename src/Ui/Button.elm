module Ui.Button exposing (Attribute, attribute, bigger, lighter, render)

import Colors
import Html exposing (Html)
import Ui


type Attribute msg
    = ButtonAttribute (Ui.Attribute msg)


attribute : Ui.Attribute msg -> Attribute msg
attribute attr =
    ButtonAttribute attr


bigger : Attribute msg
bigger =
    attribute (Ui.style "font-size" "1.25rem")


lighter : Attribute msg
lighter =
    attribute (Ui.style "color" Colors.lightAccentBlue)


render : msg -> List (Attribute msg) -> List (Html msg) -> Html msg
render onClick attrs children =
    Ui.button onClick
        [ Ui.spacing 4
        , Ui.centerY
        , Ui.style "text-transform" "uppercase"
        , Ui.style "cursor" "pointer"
        , Ui.style "color" Colors.accentBlue
        , Ui.style "font-size" "1rem"
        , Ui.batch (attrs |> List.map (\(ButtonAttribute attr) -> attr))
        ]
        children
