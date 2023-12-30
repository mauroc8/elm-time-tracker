module Ui.Toast exposing (render)

import Colors
import Html
import Html.Attributes
import Ui


render : { visible : Bool } -> List (Ui.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
render { visible } attrs children =
    Ui.row
        [ Ui.style "background-color" Colors.lightGreen
        , Ui.style "box-shadow" "1px 2px 3px 0px rgba(0, 0, 0, 0.35)"
        , Ui.paddingXY 8 5
        , Ui.spacing 12
        , Ui.style "border-radius" "8px"
        , Ui.batch attrs
        , Ui.style "position" "fixed"
        , Ui.style "bottom"
            (if visible then
                "16px"

             else
                "-64px"
            )
        , Ui.style "right" "16px"
        , Ui.style "transition" "bottom 0.3s ease-out"
        , if visible then
            Ui.class ""

          else
            Ui.attribute (Html.Attributes.attribute "aria-hidden" "true")
        ]
        children
