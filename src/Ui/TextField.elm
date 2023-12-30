module Ui.TextField exposing (field)

import Colors
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Ui


field :
    List (Ui.Attribute msg)
    ->
        { id : String
        , value : String
        , onChange : String -> msg
        , label : Html msg
        , error : Maybe (Html msg)
        }
    -> Html msg
field attrs { id, value, onChange, label, error } =
    let
        errorMessageId =
            id ++ "-error"
    in
    Ui.column attrs
        [ Ui.label { for = id }
            [ case error of
                Just _ ->
                    Ui.batch
                        [ Ui.attribute (Html.Attributes.attribute "aria-invalid" "true")
                        , Ui.attribute (Html.Attributes.attribute "aria-errormessage" errorMessageId)
                        ]

                Nothing ->
                    Ui.batch []
            , Ui.fillWidth
            , Ui.style "font-weight" "600"
            , Ui.style "font-size" "1rem"
            ]
            [ label ]
        , input [ Html.Attributes.id id ] { value = value, onChange = onChange }
        , case error of
            Just errorMessage ->
                Html.div [ Html.Attributes.id errorMessageId, Html.Attributes.style "color" Colors.red ] [ errorMessage ]

            Nothing ->
                Html.text ""
        ]


input : List (Html.Attribute msg) -> { value : String, onChange : String -> msg } -> Html msg
input attrs { value, onChange } =
    Html.input
        ([ Html.Attributes.value value
         , Html.Events.onInput onChange
         , Html.Attributes.style "padding" "8px 12px"
         , Html.Attributes.style "border" "1px solid white"
         , Html.Attributes.style "border-radius" "8px"
         , Html.Attributes.style "font-weight" "600"
         , Html.Attributes.style "font-size" "1rem"
         ]
            ++ attrs
        )
        []
