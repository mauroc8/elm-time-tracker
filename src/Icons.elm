module Icons exposing (..)

import Colors
import Element
import Svg exposing (..)
import Svg.Attributes exposing (..)


options : Element.Element msg
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


search : Element.Element msg
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


xButton : Element.Element msg
xButton =
    svg
        [ width "16"
        , height "16"
        , viewBox "0 0 16 16"
        , fill "none"
        ]
        [ Svg.path
            [ d "M12.5 3.5L3.5 12.5"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            , strokeWidth "1.1"
            ]
            []
        , Svg.path
            [ d "M12.5 12.5L3.5 3.5"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            , strokeWidth "1.1"
            ]
            []
        ]
        |> Element.html


playButton : Element.Element msg
playButton =
    svg
        [ width "53"
        , height "52"
        , viewBox "0 0 53 52"
        , fill "none"
        ]
        [ circle
            [ cx "26.5"
            , cy "26"
            , r "25"
            , fill "white"
            , stroke (Colors.toCss Colors.lightGrayText)
            , strokeWidth "2"
            ]
            []
        , Svg.path
            [ d "M40.5333 24.2876L22.5369 13.3009C22.2371 13.1109 21.8909 13.0069 21.5361 13.0003C21.1813 12.9937 20.8314 13.0847 20.5248 13.2634C20.2136 13.4342 19.9542 13.6856 19.7739 13.9914C19.5935 14.2971 19.4989 14.6458 19.5 15.0008V36.9992C19.4989 37.3542 19.5935 37.7029 19.7739 38.0086C19.9542 38.3144 20.2136 38.5658 20.5248 38.7366C20.8314 38.9153 21.1813 39.0063 21.5361 38.9997C21.8909 38.9931 22.2371 38.8891 22.5369 38.6991L40.5333 27.7124C40.8283 27.5344 41.0723 27.2832 41.2416 26.9832C41.411 26.6832 41.5 26.3445 41.5 26C41.5 25.6555 41.411 25.3168 41.2416 25.0168C41.0723 24.7168 40.8283 24.4656 40.5333 24.2876Z"
            , fill (Colors.toCss Colors.accent)
            ]
            []
        ]
        |> Element.html


stopButton : Element.Element msg
stopButton =
    svg
        [ width "53"
        , height "52"
        , viewBox "0 0 53 52"
        , fill "none"
        ]
        [ circle
            [ cx "26.5"
            , cy "26"
            , r "25"
            , fill "white"
            , stroke (Colors.toCss Colors.lightGrayText)
            , strokeWidth "2"
            ]
            []
        , rect
            [ x "16"
            , y "15"
            , width "22"
            , height "22"
            , rx "2"
            , fill (Colors.toCss Colors.red)
            ]
            []
        ]
        |> Element.html


toggleOff : Element.Element msg
toggleOff =
    svg
        [ width "16"
        , height "16"
        , viewBox "0 0 16 16"
        , fill "none"
        ]
        [ Svg.path
            [ d "M11 4H5C2.79086 4 1 5.79086 1 8C1 10.2091 2.79086 12 5 12H11C13.2091 12 15 10.2091 15 8C15 5.79086 13.2091 4 11 4Z"
            , fill (Colors.toCss Colors.grayBackground)
            , stroke (Colors.toCss Colors.blackishText)
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        , Svg.path
            [ d "M5 10C6.10457 10 7 9.10457 7 8C7 6.89543 6.10457 6 5 6C3.89543 6 3 6.89543 3 8C3 9.10457 3.89543 10 5 10Z"
            , fill (Colors.toCss Colors.blackishText)
            , stroke (Colors.toCss Colors.blackishText)
            , strokeWidth "2"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        ]
        |> Element.html


toggleOn : Element.Element msg
toggleOn =
    svg
        [ width "16"
        , height "16"
        , viewBox "0 0 16 16"
        , fill "none"
        ]
        [ Svg.path
            [ d "M11 4H5C2.79086 4 1 5.79086 1 8C1 10.2091 2.79086 12 5 12H11C13.2091 12 15 10.2091 15 8C15 5.79086 13.2091 4 11 4Z"
            , fill (Colors.toCss Colors.grayBackground)
            , stroke (Colors.toCss Colors.blackishText)
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        , Svg.path
            [ d "M11 10C12.1046 10 13 9.10457 13 8C13 6.89543 12.1046 6 11 6C9.89543 6 9 6.89543 9 8C9 9.10457 9.89543 10 11 10Z"
            , fill (Colors.toCss Colors.blackishText)
            , stroke (Colors.toCss Colors.blackishText)
            , strokeWidth "2"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        ]
        |> Element.html
