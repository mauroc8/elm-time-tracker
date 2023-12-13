module Viewport exposing (Viewport(..), breakpoints, fromScreenWidth)

--- Viewport


type Viewport
    = Desktop
    | Tablet
    | Mobile


fromScreenWidth : Int -> Viewport
fromScreenWidth screenWidth =
    if screenWidth >= 1024 then
        Desktop

    else if screenWidth >= 768 then
        Tablet

    else
        Mobile


breakpoints : Viewport -> c -> c -> c -> c
breakpoints vwpt desktop tablet mobile =
    case vwpt of
        Desktop ->
            desktop

        Tablet ->
            tablet

        Mobile ->
            mobile
