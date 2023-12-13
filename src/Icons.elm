module Icons exposing (chevronLeft, externalLink, play, playButton, settings, stopButton, trash)

import Colors
import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes exposing (..)


settings : Int -> Html msg
settings size =
    svg
        [ width (String.fromInt size)
        , height (String.fromInt size)
        , viewBox "0 0 16 16"
        , fill "none"
        ]
        [ Svg.path
            [ d "M6.46667 15.1666L6.13334 13.0666C5.92222 12.9889 5.7 12.8833 5.46667 12.75C5.23334 12.6166 5.02778 12.4778 4.85 12.3333L2.88334 13.2333L1.33334 10.5L3.13334 9.18331C3.11111 9.08331 3.09722 8.96942 3.09167 8.84165C3.08611 8.71387 3.08334 8.59998 3.08334 8.49998C3.08334 8.39998 3.08611 8.28609 3.09167 8.15831C3.09722 8.03053 3.11111 7.91665 3.13334 7.81665L1.33334 6.49998L2.88334 3.76665L4.85 4.66665C5.02778 4.5222 5.23334 4.38331 5.46667 4.24998C5.7 4.11665 5.92222 4.01665 6.13334 3.94998L6.46667 1.83331H9.53334L9.86667 3.93331C10.0778 4.01109 10.3028 4.11387 10.5417 4.24165C10.7806 4.36942 10.9833 4.51109 11.15 4.66665L13.1167 3.76665L14.6667 6.49998L12.8667 7.78331C12.8889 7.89442 12.9028 8.01387 12.9083 8.14165C12.9139 8.26942 12.9167 8.38887 12.9167 8.49998C12.9167 8.61109 12.9139 8.72776 12.9083 8.84998C12.9028 8.9722 12.8889 9.08887 12.8667 9.19998L14.6667 10.5L13.1167 13.2333L11.15 12.3333C10.9722 12.4778 10.7694 12.6194 10.5417 12.7583C10.3139 12.8972 10.0889 13 9.86667 13.0666L9.53334 15.1666H6.46667ZM8 10.6666C8.6 10.6666 9.11111 10.4555 9.53334 10.0333C9.95556 9.61109 10.1667 9.09998 10.1667 8.49998C10.1667 7.89998 9.95556 7.38887 9.53334 6.96665C9.11111 6.54442 8.6 6.33331 8 6.33331C7.4 6.33331 6.88889 6.54442 6.46667 6.96665C6.04445 7.38887 5.83334 7.89998 5.83334 8.49998C5.83334 9.09998 6.04445 9.61109 6.46667 10.0333C6.88889 10.4555 7.4 10.6666 8 10.6666ZM8 9.66665C7.67778 9.66665 7.40278 9.55276 7.175 9.32498C6.94722 9.0972 6.83334 8.8222 6.83334 8.49998C6.83334 8.17776 6.94722 7.90276 7.175 7.67498C7.40278 7.4472 7.67778 7.33331 8 7.33331C8.32222 7.33331 8.59722 7.4472 8.825 7.67498C9.05278 7.90276 9.16667 8.17776 9.16667 8.49998C9.16667 8.8222 9.05278 9.0972 8.825 9.32498C8.59722 9.55276 8.32222 9.66665 8 9.66665ZM7.26667 14.1666H8.73334L8.96667 12.3C9.33334 12.2111 9.68056 12.0722 10.0083 11.8833C10.3361 11.6944 10.6333 11.4666 10.9 11.2L12.6667 11.9666L13.3333 10.7666L11.7667 9.61665C11.8111 9.42776 11.8472 9.24165 11.875 9.05831C11.9028 8.87498 11.9167 8.68887 11.9167 8.49998C11.9167 8.31109 11.9056 8.12498 11.8833 7.94165C11.8611 7.75831 11.8222 7.5722 11.7667 7.38331L13.3333 6.23331L12.6667 5.03331L10.9 5.79998C10.6444 5.51109 10.3556 5.26942 10.0333 5.07498C9.71111 4.88054 9.35556 4.75554 8.96667 4.69998L8.73334 2.83331H7.26667L7.03334 4.69998C6.65556 4.77776 6.30278 4.91109 5.975 5.09998C5.64722 5.28887 5.35556 5.5222 5.1 5.79998L3.33334 5.03331L2.66667 6.23331L4.23334 7.38331C4.18889 7.5722 4.15278 7.75831 4.125 7.94165C4.09722 8.12498 4.08334 8.31109 4.08334 8.49998C4.08334 8.68887 4.09722 8.87498 4.125 9.05831C4.15278 9.24165 4.18889 9.42776 4.23334 9.61665L2.66667 10.7666L3.33334 11.9666L5.1 11.2C5.36667 11.4666 5.66389 11.6944 5.99167 11.8833C6.31945 12.0722 6.66667 12.2111 7.03334 12.3L7.26667 14.1666Z"
            , fill "currentColor"
            ]
            []
        ]


chevronLeft : Int -> Html msg
chevronLeft size =
    svg
        [ width (String.fromInt size)
        , height (String.fromInt size)
        , viewBox "0 0 24 24"
        , fill "none"
        ]
        [ Svg.path
            [ d "M14.025 18L8 11.975L14.025 5.95L15.1 7.025L10.15 11.975L15.1 16.925L14.025 18Z"
            , fill "currentColor"
            ]
            []
        ]


playButton : Int -> Html msg
playButton size =
    svg
        [ width (String.fromInt size)
        , height (String.fromInt size)
        , viewBox "0 0 52 52"
        , fill "none"
        ]
        [ circle
            [ cx "26"
            , cy "26"
            , r "25"
            , fill "white"
            , stroke "currentColor"
            , strokeWidth "2"
            ]
            []
        , Svg.path
            [ d "M40.5333 24.2876L22.5369 13.3009C22.2371 13.1109 21.8909 13.0069 21.5361 13.0003C21.1813 12.9937 20.8314 13.0847 20.5248 13.2634C20.2136 13.4342 19.9542 13.6856 19.7739 13.9914C19.5935 14.2971 19.4989 14.6458 19.5 15.0008V36.9992C19.4989 37.3542 19.5935 37.7029 19.7739 38.0086C19.9542 38.3144 20.2136 38.5658 20.5248 38.7366C20.8314 38.9153 21.1813 39.0063 21.5361 38.9997C21.8909 38.9931 22.2371 38.8891 22.5369 38.6991L40.5333 27.7124C40.8283 27.5344 41.0723 27.2832 41.2416 26.9832C41.411 26.6832 41.5 26.3445 41.5 26C41.5 25.6555 41.411 25.3168 41.2416 25.0168C41.0723 24.7168 40.8283 24.4656 40.5333 24.2876Z"
            , fill Colors.red
            ]
            []
        ]


stopButton : Html msg
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
            , fill Colors.red
            ]
            []
        ]


play : Html msg
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


trash : Html msg
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


externalLink : Html msg
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
