module Utils.Events exposing
    ( onEnter
    , onEscape
    , onPointerDown
    )

import Element
import Html
import Html.Events
import Html.Events.Extra.Pointer
import Json.Decode as Decode


{-| -}
onEnter : msg -> Element.Attribute msg
onEnter msg =
    onKeyDown "Enter" msg


onEscape : msg -> Element.Attribute msg
onEscape msg =
    onKeyDown "Escape" msg


onKeyDown : String -> a -> Element.Attribute a
onKeyDown key msg =
    Element.htmlAttribute
        (Html.Events.on "keyup"
            (Decode.field "key" Decode.string
                |> Decode.andThen
                    (\eventKey ->
                        if eventKey == key then
                            Decode.succeed msg

                        else
                            Decode.fail ("Not the " ++ key ++ " key")
                    )
            )
        )


onPointerDown : a -> Html.Attribute a
onPointerDown msg =
    Html.Events.Extra.Pointer.onDown (\_ -> msg)
