module Storage exposing
    ( Storage
    , createForm
    , persist
    , recordList
    , settings
    )

import CreateForm exposing (CreateForm)
import Json.Decode
import Json.Encode
import RecordList exposing (RecordList)
import Settings exposing (Settings)


type Storage a
    = Storage String (Json.Decode.Decoder a) (a -> Json.Decode.Value)


createForm : Storage (Maybe CreateForm)
createForm =
    Storage "createForm" (nullable CreateForm.decoder) (encodeNullable CreateForm.encoder)


nullable : Json.Decode.Decoder a -> Json.Decode.Decoder (Maybe a)
nullable decoder =
    Json.Decode.oneOf
        [ decoder
            |> Json.Decode.map Just
        , Json.Decode.null Nothing
        ]


encodeNullable : (a -> Json.Encode.Value) -> Maybe a -> Json.Encode.Value
encodeNullable encoder value =
    case value of
        Just x ->
            encoder x

        Nothing ->
            Json.Encode.null


recordList =
    Debug.todo ""


settings =
    Debug.todo ""


type Error
    = DecodeError Json.Decode.Error
    | NotFound


load : (Result Error a -> msg) -> Storage a -> Cmd msg
load =
    Debug.todo ""


persist : Storage a -> a -> Cmd msg
persist =
    Debug.todo ""
