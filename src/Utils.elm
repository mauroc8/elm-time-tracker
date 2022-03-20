module Utils exposing
    ( debugError
    , decodeLiteral
    , emptyAttribute
    , encodeNullable
    , nullableDecoder
    )

import Element
import Html.Attributes
import Json.Decode
import Json.Encode


decodeLiteral : a -> String -> Json.Decode.Decoder a
decodeLiteral constructor stringLiteral =
    Json.Decode.string
        |> Json.Decode.andThen
            (\decodedString ->
                if decodedString == stringLiteral then
                    Json.Decode.succeed constructor

                else
                    Json.Decode.fail <|
                        "Expecting literal \""
                            ++ stringLiteral
                            ++ "\" but found: \""
                            ++ decodedString
                            ++ "\""
            )


encodeNullable : (a -> Json.Encode.Value) -> Maybe a -> Json.Encode.Value
encodeNullable encoder value =
    case value of
        Just x ->
            encoder x

        Nothing ->
            Json.Encode.null


nullableDecoder : Json.Decode.Decoder a -> Json.Decode.Decoder (Maybe a)
nullableDecoder decoder =
    Json.Decode.oneOf
        [ decoder
            |> Json.Decode.map Just
        , Json.Decode.null
            Nothing
        ]


debugError : String -> a -> a
debugError str value =
    debugLog ("Error: " ++ str) value


debugLog : String -> a -> a
debugLog str value =
    Debug.log str value


emptyAttribute : Element.Attribute msg
emptyAttribute =
    Element.htmlAttribute (Html.Attributes.class "")
