port module LocalStorage exposing
    ( Store
    , clear
    , readFromFlags
    , save
    , store
    )

import Json.Decode
import Json.Encode


{-| Represents an item in localStorage.
-}
type Store a
    = Store
        { key : String
        , encode : a -> Json.Decode.Value
        , decoder : Json.Decode.Decoder a
        }


store :
    { key : String
    , encode : a -> Json.Decode.Value
    , decoder : Json.Decode.Decoder a
    }
    -> Store a
store =
    Store



---


{-| Overrides the current store value with a new value.
-}
save : Store a -> a -> Cmd msg
save store_ value =
    let
        (Store { key, encode }) =
            store_
    in
    setItem
        { key = key
        , value = encode value
        }


{-| Deletes the store value
-}
clear : Store a -> Cmd msg
clear (Store { key }) =
    setItem
        { key = key
        , value = Json.Encode.null
        }


port setItem : { key : String, value : Json.Decode.Value } -> Cmd msg



---


{-| Loads the initial state from flags
-}
readFromFlags : Json.Decode.Value -> Store a -> Result Json.Decode.Error a
readFromFlags flags store_ =
    let
        (Store { key, decoder }) =
            store_
    in
    Json.Decode.decodeValue
        (Json.Decode.field key decoder)
        flags
