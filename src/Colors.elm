module Colors exposing (..)

import Element exposing (Color)


background =
    { white =
        Element.rgb255 255 255 255
    , gray =
        Element.rgb255 240 240 240
    }


text =
    { black = Element.rgb255 0 0 0
    , blackish = Element.rgb255 46 46 46
    , darkGray = Element.rgb255 73 73 73
    , gray = Element.rgb255 100 100 100
    , lightGray = Element.rgb255 140 140 140
    , lighterGray = Element.rgb255 170 170 170
    }


accent =
    Element.rgb255 113 163 240


red =
    Element.rgb255 241 97 97


transparent =
    Element.rgba 1 1 1 0
