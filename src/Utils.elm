module Utils exposing
    ( debugError
    , decodeLiteral
    )

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
    -- I manually toggle these lines to make a build:
    -- value
    Debug.log str value
