module Records exposing
    ( Records
    , empty
    )

import Dict exposing (Dict)
import Record exposing (Record)



--- Records


type Records
    = Records (Dict Int Record)


empty : Records
empty =
    Records Dict.empty
