module Utils.Events exposing
    ( onKeyDown
    , onPointerDown
    )

import Element
import Html
import Html.Events
import Html.Events.Extra.Pointer
import Json.Decode as Decode


onKeyDown : List ( String, msg ) -> Element.Attribute msg
onKeyDown msgs =
    let
        decodeKey msgs_ key =
            case msgs_ of
                ( eventKey, msg ) :: tail ->
                    if eventKey == key then
                        Decode.succeed msg

                    else
                        decodeKey tail key

                _ ->
                    Decode.fail "onKeyDown"
    in
    Element.htmlAttribute
        (Html.Events.on "keydown"
            (Decode.field "key" Decode.string
                |> Decode.andThen (decodeKey msgs)
            )
        )


onPointerDown : a -> Html.Attribute a
onPointerDown msg =
    Html.Events.Extra.Pointer.onDown (\_ -> msg)
