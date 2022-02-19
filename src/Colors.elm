module Colors exposing (..)

import Element exposing (Color)


whiteBackground : Color
whiteBackground =
    Element.rgb255 255 255 255


grayBackground : Color
grayBackground =
    Element.rgb255 240 240 240


blackText : Color
blackText =
    Element.rgb255 0 0 0


blackishText : Color
blackishText =
    Element.rgb255 46 46 46


darkGrayText : Color
darkGrayText =
    Element.rgb255 73 73 73


grayText : Color
grayText =
    Element.rgb255 100 100 100


lightGrayText : Color
lightGrayText =
    Element.rgb255 140 140 140


lighterGrayText : Color
lighterGrayText =
    Element.rgb255 170 170 170


accent : Color
accent =
    Element.rgb255 113 163 240


red : Color
red =
    Element.rgb255 241 97 97


transparent : Color
transparent =
    Element.rgba 1 1 1 0


toCss : Color -> String
toCss color =
    let
        rgb =
            Element.toRgb color

        roundFloat n =
            n |> round |> String.fromInt
    in
    "rgba("
        ++ String.join ","
            [ rgb.red * 255 |> roundFloat
            , rgb.green * 255 |> roundFloat
            , rgb.blue * 255 |> roundFloat
            , rgb.alpha |> String.fromFloat
            ]
        ++ ")"
