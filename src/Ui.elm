module Ui exposing
    ( Attribute
    , Viewport(..)
    , alignBottom
    , alignLeft
    , alignRight
    , alignTop
    , attribute
    , attributesToHtml
    , breakpoints
    , centerX
    , centerY
    , class
    , column
    , fillHeight
    , fillWidth
    , fromScreenWidth
    , htmlTag
    , padding
    , paddingXY
    , px
    , row
    , spaceBetween
    , spacing
    , style
    , styles
    )

import Html exposing (Html)
import Html.Attributes



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



---


type Attribute msg
    = HtmlAttributes (List (Html.Attribute msg))
    | TagName String


attribute : Html.Attribute msg -> Attribute msg
attribute attr =
    HtmlAttributes [ attr ]


htmlTag : String -> Attribute msg
htmlTag =
    TagName


attributesToHtml : List (Attribute msg) -> List (Html.Attribute msg)
attributesToHtml attrs =
    attrs
        |> List.concatMap
            (\attr ->
                case attr of
                    HtmlAttributes htmlAttrs ->
                        htmlAttrs

                    TagName _ ->
                        []
            )


attributesToTagName : List (Attribute msg) -> String
attributesToTagName attrs =
    attrs
        |> List.filterMap
            (\attr ->
                case attr of
                    HtmlAttributes _ ->
                        Nothing

                    TagName tagName ->
                        Just tagName
            )
        |> List.head
        |> Maybe.withDefault "div"


class : String -> Attribute msg
class className =
    HtmlAttributes [ Html.Attributes.class className ]


style : String -> String -> Attribute msg
style prop value =
    HtmlAttributes [ Html.Attributes.style prop value ]


styles : List ( String, String ) -> Attribute msg
styles styleList =
    HtmlAttributes (List.map (\( prop, value ) -> Html.Attributes.style prop value) styleList)


fillWidth : Attribute msg
fillWidth =
    class "fill-width"


fillHeight : Attribute msg
fillHeight =
    class "fill-height"


padding : Int -> Attribute msg
padding value =
    style "padding" (px value)


paddingXY : ( Int, Int ) -> Attribute msg
paddingXY ( x, y ) =
    style "padding" (px y ++ " " ++ px x)


px : Int -> String
px value =
    String.fromInt value ++ "px"


spacing : Int -> Attribute msg
spacing value =
    HtmlAttributes [ Html.Attributes.style "gap" (px value) ]


alignLeft : Attribute msg
alignLeft =
    class "align-left"


{-| Centers in the X axis (horizontal axis)

Note: May not work as expected if you don't use `fillWidth`

-}
centerX : Attribute msg
centerX =
    class "center-x"


alignRight : Attribute msg
alignRight =
    class "align-right"


alignTop : Attribute msg
alignTop =
    class "align-top"


{-| Centers in the Y axis (vertical axis)

Note: May not work as expected if you don't use `fillHeight`

-}
centerY : Attribute msg
centerY =
    class "center-y"


alignBottom : Attribute msg
alignBottom =
    class "align-bottom"


{-| A type of alignment that distributes all the available space (if any) evenly between the children.

Aligns the first child to the left and the last child to the right.

-}
spaceBetween : Attribute msg
spaceBetween =
    class "space-between"



---


column : List (Attribute msg) -> List (Html msg) -> Html msg
column attrs children =
    Html.node (attributesToTagName attrs)
        (Html.Attributes.class "column" :: attributesToHtml attrs)
        children


row : List (Attribute msg) -> List (Html msg) -> Html msg
row attrs children =
    Html.node (attributesToTagName attrs)
        (Html.Attributes.class "row" :: attributesToHtml attrs)
        children
