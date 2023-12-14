module Colors exposing
    ( accentBlue
    , black
    , blackText
    , blackishText
    , darkGrayBackground
    , darkerGrayBackground
    , grayBackground
    , grayText
    , lightAccentBlue
    , lightGrayText
    , lightGreen
    , lighterGrayText
    , red
    , transparent
    , white
    )


lightGreen : String
lightGreen =
    "#4DED83"


black : String
black =
    "#000"


red : String
red =
    "#FD3407"


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


white : String
white =
    "#FFFFFF"


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


accentBlue : String
accentBlue =
    "#2C3BC1"


transparent : String
transparent =
    "rgba(1, 1, 1, 0)"


lightAccentBlue : String
lightAccentBlue =
    "#7785FF"
