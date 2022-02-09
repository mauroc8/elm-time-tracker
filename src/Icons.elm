module Icons exposing (..)

import Element
import Svg exposing (..)
import Svg.Attributes exposing (..)


options =
    svg
        [ width "13"
        , height "10"
        , viewBox "0 0 13 10"
        , fill "none"
        ]
        [ Svg.path
            [ d "M7.75 7.75H1"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        , Svg.path
            [ d "M12 7.75H10.25"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        , Svg.path
            [ d "M9 9C9.69036 9 10.25 8.44036 10.25 7.75C10.25 7.05964 9.69036 6.5 9 6.5C8.30964 6.5 7.75 7.05964 7.75 7.75C7.75 8.44036 8.30964 9 9 9Z"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        , Svg.path
            [ d "M3.75 2.25H1"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        , Svg.path
            [ d "M12 2.25H6.25"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        , Svg.path
            [ d "M5 3.5C5.69036 3.5 6.25 2.94036 6.25 2.25C6.25 1.55964 5.69036 1 5 1C4.30964 1 3.75 1.55964 3.75 2.25C3.75 2.94036 4.30964 3.5 5 3.5Z"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        ]
        |> Element.html


search =
    svg
        [ width "14"
        , height "14"
        , viewBox "0 0 14 14"
        , fill "none"
        ]
        [ Svg.path
            [ d "M6.25 11.5C9.1495 11.5 11.5 9.1495 11.5 6.25C11.5 3.35051 9.1495 1 6.25 1C3.35051 1 1 3.35051 1 6.25C1 9.1495 3.35051 11.5 6.25 11.5Z"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        , Svg.path
            [ d "M9.96252 9.96249L13 13"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        ]
        |> Element.html


x =
    svg
        [ width "16"
        , height "16"
        , viewBox "0 0 16 16"
        , fill "none"
        ]
        [ Svg.path
            [ d "M12.5 3.5L3.5 12.5"
            , stroke "#71A3F0"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            , strokeWidth "1.1"
            ]
            []
        , Svg.path
            [ d "M12.5 12.5L3.5 3.5"
            , stroke "#71A3F0"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            , strokeWidth "1.1"
            ]
            []
        ]
        |> Element.html
