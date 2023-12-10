module RecordList exposing
    ( RecordList
    , delete
    , empty
    , find
    , push
    , store
    , toList
    )

import Dict exposing (Dict)
import Json.Decode
import Json.Encode
import Levenshtein
import LocalStorage
import Record exposing (Record)
import Time



--- Records


{-| A list of records ordered by start time.
-}
type RecordList
    = RecordList (Dict Int Record)


empty : RecordList
empty =
    RecordList Dict.empty


fromList : List Record -> RecordList
fromList list =
    Dict.fromList
        (List.map (\record -> ( Time.posixToMillis record.startDateTime, record )) list)
        |> RecordList


store : LocalStorage.Store RecordList
store =
    LocalStorage.store
        { key = "recordList"
        , encode = encode
        , decoder = decoder
        }


decoder : Json.Decode.Decoder RecordList
decoder =
    Json.Decode.list Record.decoder
        |> Json.Decode.map fromList


encode : RecordList -> Json.Encode.Value
encode recordList =
    recordList
        |> toList
        |> Json.Encode.list Record.encode



---


matchesSearchQuery : String -> String -> Bool
matchesSearchQuery query str =
    let
        queryLength =
            String.length query
    in
    Levenshtein.distance
        query
        (String.left
            queryLength
            str
        )
        <= (queryLength // 3)


toList : RecordList -> List Record
toList (RecordList records) =
    Dict.toList records
        |> List.map Tuple.second
        -- The dict is ordered by startDateTime. The order should be from latest to earliest startDateTime
        |> List.reverse
        -- The super intelligent garbage collector (for performance reasons there can't be many records)
        -- Note: If we estimate 10 DOM nodes per record, 1000 hits the recommended maximum of 10.000
        |> List.take 1000


push : Record -> RecordList -> RecordList
push record (RecordList records) =
    Dict.insert (Time.posixToMillis record.startDateTime) record records
        |> RecordList


delete : Record.Id -> RecordList -> RecordList
delete id (RecordList records) =
    Dict.filter (\_ record -> record.id /= id)
        records
        |> RecordList


find : Record.Id -> RecordList -> Maybe Record.Record
find id recordList =
    recordList
        |> toList
        |> List.filter (\r -> r.id == id)
        |> List.head
