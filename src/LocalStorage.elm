port module LocalStorage exposing
    ( Store
    , clear
    , createForm
    , load
    , recordList
    , save
    , settings
    )

import CreateForm exposing (CreateForm)
import Json.Decode
import Json.Encode
import RecordList exposing (RecordList)
import Settings exposing (Settings)


{-| -}
type Store a
    = Store
        { key : String
        , encode : a -> Json.Decode.Value
        , decoder : Json.Decode.Decoder a
        }


createForm : Store CreateForm
createForm =
    Store
        { key = "createForm"
        , encode = CreateForm.encode
        , decoder = CreateForm.decoder
        }


recordList : Store RecordList
recordList =
    Store
        { key = "recordList"
        , encode = RecordList.encode
        , decoder = RecordList.decoder
        }


settings : Store Settings
settings =
    Store
        { key = "settings"
        , encode = Settings.encode
        , decoder = Settings.decoder
        }



---


{-| Overrides the current store value with a new value.
-}
save : { store : Store a, value : a } -> Cmd msg
save { store, value } =
    let
        (Store { key, encode }) =
            store
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
load : { store : Store a, flags : Json.Decode.Value } -> Result Json.Decode.Error a
load { store, flags } =
    let
        (Store { key, decoder }) =
            store
    in
    Json.Decode.decodeValue
        (Json.Decode.field key decoder)
        flags
