module Ui.RadioButtonFieldSet exposing (render)

import Colors
import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Ui


render :
    { id : String
    , legend : Html.Html msg
    , value : a
    , onChange : a -> msg
    , caption : Maybe (Html.Html msg)
    }
    -> List ( Html.Html msg, a )
    -> Html.Html msg
render { id, legend, value, onChange, caption } options =
    let
        legendId =
            id ++ "-legend"

        captionId =
            id ++ "-caption"

        -- note: without extra wrapper it does not render correctly (??!!)
        renderLegend =
            Ui.row []
                [ Ui.row
                    [ Ui.htmlTag "legend"
                    , Ui.id legendId
                    , Ui.style "font-weight" "600"
                    ]
                    [ legend ]
                ]

        renderOption ( label, optionValue ) =
            Ui.row [ Ui.htmlTag "label", Ui.spacing 16, Ui.centerY ]
                [ Html.input
                    [ Html.Attributes.type_ "radio"
                    , Html.Attributes.checked (value == optionValue)
                    , Html.Events.on "change" (Json.Decode.succeed (onChange optionValue))
                    ]
                    []
                , Html.span [] [ label ]
                ]

        renderCaption =
            case caption of
                Just captionValue ->
                    [ Ui.row [ Ui.id captionId, Ui.style "font-size" "0.875rem", Ui.style "color" Colors.grayText ]
                        [ captionValue ]
                    ]

                Nothing ->
                    []

        ariaLabelledBy =
            Ui.attribute <|
                Html.Attributes.attribute "aria-labelledby" <|
                    case caption of
                        Just _ ->
                            -- I'm following the advice in this comment: https://stackoverflow.com/a/49147015/5701494
                            legendId ++ " " ++ captionId

                        Nothing ->
                            legendId
    in
    Ui.column
        [ Ui.htmlTag "fieldset"
        , Ui.spacing 8
        , ariaLabelledBy
        ]
        (renderLegend :: List.map renderOption options ++ renderCaption)
