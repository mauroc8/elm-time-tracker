module Utils exposing
    ( debugError
    , decodeLiteral
    , emptyAttribute
    )

import Element
import Html.Attributes
import Json.Decode


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


debugError : String -> a -> a
debugError str value =
    debugLog ("Error: " ++ str) value


debugLog : String -> a -> a
debugLog str value =
    -- I manually change this line to `value` each time I make a build
    Debug.log str value


emptyAttribute : Element.Attribute msg
emptyAttribute =
    Element.htmlAttribute (Html.Attributes.class "")
