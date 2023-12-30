module Ui.HorizontalSeparator exposing (render)

import Colors
import Html
import Html.Attributes


render : Html.Html msg
render =
    Html.div [ Html.Attributes.style "width" "100%", Html.Attributes.style "border-bottom" ("1px solid " ++ Colors.grayBackground) ] []
