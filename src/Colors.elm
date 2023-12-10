module Colors exposing
    ( accent
    , blackText
    , blackishText
    , darkGrayBackground
    , darkerGrayBackground
    , grayBackground
    , grayText
    , lightGrayText
    , lighterGrayText
    , red
    , transparent
    , whiteBackground
    )


rgb255 : Int -> Int -> Int -> String
rgb255 r g b =
    let
        rgb =
            [ r, g, b ]
                |> List.map String.fromInt
                |> String.join ", "
    in
    "rgb("
        ++ rgb
        ++ ")"


whiteBackground : String
whiteBackground =
    rgb255 255 255 255


grayBackground : String
grayBackground =
    rgb255 240 240 240


darkGrayBackground : String
darkGrayBackground =
    rgb255 228 228 228


darkerGrayBackground : String
darkerGrayBackground =
    rgb255 215 215 215


blackText : String
blackText =
    rgb255 0 0 0


blackishText : String
blackishText =
    rgb255 46 46 46


grayText : String
grayText =
    rgb255 100 100 100


lightGrayText : String
lightGrayText =
    rgb255 140 140 140


lighterGrayText : String
lighterGrayText =
    rgb255 170 170 170


accent : String
accent =
    rgb255 113 163 240


red : String
red =
    rgb255 241 97 97


transparent : String
transparent =
    "rgba(1, 1, 1, 0)"
