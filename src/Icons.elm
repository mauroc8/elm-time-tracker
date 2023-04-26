module Icons exposing (check16, externalLink, options, play, playButton, search, stopButton, trash, xButton)

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
            , stroke "currentColor"
            , strokeWidth "2"
            ]
            []
        , Svg.path
            [ d "M40.5333 24.2876L22.5369 13.3009C22.2371 13.1109 21.8909 13.0069 21.5361 13.0003C21.1813 12.9937 20.8314 13.0847 20.5248 13.2634C20.2136 13.4342 19.9542 13.6856 19.7739 13.9914C19.5935 14.2971 19.4989 14.6458 19.5 15.0008V36.9992C19.4989 37.3542 19.5935 37.7029 19.7739 38.0086C19.9542 38.3144 20.2136 38.5658 20.5248 38.7366C20.8314 38.9153 21.1813 39.0063 21.5361 38.9997C21.8909 38.9931 22.2371 38.8891 22.5369 38.6991L40.5333 27.7124C40.8283 27.5344 41.0723 27.2832 41.2416 26.9832C41.411 26.6832 41.5 26.3445 41.5 26C41.5 25.6555 41.411 25.3168 41.2416 25.0168C41.0723 24.7168 40.8283 24.4656 40.5333 24.2876Z"
            , fill (Colors.toCss Colors.red)
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
            , stroke "currentColor"
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


play : Element.Element msg
play =
    svg
        [ width "12"
        , height "14"
        , viewBox "0 0 12 14"
        , fill "none"
        ]
        [ Svg.path
            [ d "M10.7563 6.57445L1.7625 1.07445C1.68679 1.02775 1.59999 1.00209 1.51106 1.00012C1.42212 0.998155 1.33427 1.01995 1.25657 1.06326C1.17887 1.10657 1.11413 1.16982 1.06903 1.2465C1.02393 1.32317 1.0001 1.41049 1 1.49945V12.4995C1.0001 12.5884 1.02393 12.6757 1.06903 12.7524C1.11413 12.8291 1.17887 12.8923 1.25657 12.9356C1.33427 12.979 1.42212 13.0007 1.51106 12.9988C1.59999 12.9968 1.68679 12.9712 1.7625 12.9245L10.7563 7.42445C10.8301 7.38078 10.8913 7.31862 10.9338 7.24409C10.9763 7.16957 10.9987 7.08525 10.9987 6.99945C10.9987 6.91365 10.9763 6.82934 10.9338 6.75481C10.8913 6.68028 10.8301 6.61812 10.7563 6.57445V6.57445Z"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        ]
        |> Element.html


trash : Element.Element msg
trash =
    svg [ width "12", height "13", viewBox "0 0 12 13", fill "none" ]
        [ Svg.path
            [ d "M11.5 2.5H0.5"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        , Svg.path
            [ d "M4.5 5.5V9.5"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        , Svg.path
            [ d "M7.5 5.5V9.5"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        , Svg.path
            [ d "M10.5 2.5V12C10.5 12.1326 10.4473 12.2598 10.3536 12.3536C10.2598 12.4473 10.1326 12.5 10 12.5H2C1.86739 12.5 1.74021 12.4473 1.64645 12.3536C1.55268 12.2598 1.5 12.1326 1.5 12V2.5"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        , Svg.path
            [ d "M8.5 2.5V1.5C8.5 1.23478 8.39464 0.98043 8.20711 0.792893C8.01957 0.605357 7.76522 0.5 7.5 0.5H4.5C4.23478 0.5 3.98043 0.605357 3.79289 0.792893C3.60536 0.98043 3.5 1.23478 3.5 1.5V2.5"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        ]
        |> Element.html


check16 : Element.Element msg
check16 =
    svg
        [ width "16"
        , height "16"
        , viewBox "0 0 16 16"
        , fill "none"
        ]
        [ Svg.path
            [ d "M13.5 4.5L6.5 11.5L3 8"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            , strokeWidth "1.1"
            ]
            []
        ]
        |> Element.html


externalLink : Element.Element msg
externalLink =
    svg
        [ width "14"
        , height "14"
        , viewBox "0 0 14 14"
        , fill "none"
        ]
        [ Svg.path
            [ d "M13.375 5.21875V1H9.15625"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        , Svg.path
            [ d "M8.3125 6.0625L13.375 1"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        , Svg.path
            [ d "M11.125 8.3125V12.8125C11.125 12.9617 11.0657 13.1048 10.9602 13.2102C10.8548 13.3157 10.7117 13.375 10.5625 13.375H1.5625C1.41332 13.375 1.27024 13.3157 1.16475 13.2102C1.05926 13.1048 1 12.9617 1 12.8125V3.8125C1 3.66332 1.05926 3.52024 1.16475 3.41475C1.27024 3.30926 1.41332 3.25 1.5625 3.25H6.0625"
            , stroke "currentColor"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        ]
        |> Element.html
        |> Element.el []
