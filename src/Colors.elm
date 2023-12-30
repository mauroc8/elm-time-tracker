module Colors exposing
    ( accentBlue
    , black
    , grayBackground
    , grayText
    , lightAccentBlue
    , lightGreen
    , red
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


grayText : String
grayText =
    "#333333"


accentBlue : String
accentBlue =
    "#2C3BC1"


lightAccentBlue : String
lightAccentBlue =
    "#7785FF"
