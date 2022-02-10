module Records exposing
    ( Records
    , empty
    , search
    )

import Dict exposing (Dict)
import Levenshtein
import Record exposing (Record)



--- Records


type Records
    = Records (Dict Int Record)


empty : Records
empty =
    Records Dict.empty


search : String -> Records -> Records
search query (Records records) =
    let
        queryLength =
            String.length query
    in
    records
        |> Dict.filter
            (\key record ->
                Levenshtein.distance
                    query
                    (String.left
                        queryLength
                        (Record.description record)
                    )
                    <= (queryLength // 3)
            )
        |> Records
