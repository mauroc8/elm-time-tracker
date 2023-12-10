module Settings exposing
    ( Settings
    , store
    )

import Json.Decode
import Json.Encode
import LocalStorage
import Text
import Utils.Date



--- Settings


type alias Settings =
    { dateNotation : Utils.Date.Notation
    , language : Text.Language
    }


store : LocalStorage.Store Settings
store =
    LocalStorage.store
        { key = "settings"
        , encode = encode
        , decoder = decoder
        }


decoder : Json.Decode.Decoder Settings
decoder =
    Json.Decode.map2 Settings
        (Json.Decode.field "dateNotation" Utils.Date.notationDecoder)
        (Json.Decode.field "language" Text.languageDecoder)


encode : Settings -> Json.Decode.Value
encode { dateNotation, language } =
    Json.Encode.object
        [ ( "dateNotation", Utils.Date.encodeNotation dateNotation )
        , ( "language", Text.encodeLanguage language )
        ]
