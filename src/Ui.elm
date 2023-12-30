module Ui exposing
    ( Attribute
    , alignBottom
    , alignLeft
    , alignRight
    , alignTop
    , attribute
    , batch
    , box
    , button
    , centerX
    , centerY
    , class
    , column
    , fillHeight
    , fillWidth
    , filler
    , htmlTag
    , id
    , label
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
import Html.Events
import Maybe.Extra



---


type Attribute msg
    = HtmlAttribute (Html.Attribute msg)
    | TagName String
    | Batch (List (Attribute msg))


attribute : Html.Attribute msg -> Attribute msg
attribute attr =
    HtmlAttribute attr


batch : List (Attribute msg) -> Attribute msg
batch attrs =
    Batch attrs


htmlTag : String -> Attribute msg
htmlTag =
    TagName


and : Attribute msg -> Attribute msg -> Attribute msg
and second first =
    batch [ first, second ]


attributesToHtml : List (Attribute msg) -> List (Html.Attribute msg)
attributesToHtml attrs =
    attrs
        |> List.concatMap
            (\attr ->
                case attr of
                    HtmlAttribute htmlAttr ->
                        [ htmlAttr ]

                    TagName _ ->
                        []

                    Batch innerAttrs ->
                        attributesToHtml innerAttrs
            )


attributesToTagName : List (Attribute msg) -> String
attributesToTagName attrs =
    let
        getTagName attributes =
            case attributes of
                (TagName tagName) :: _ ->
                    Just tagName

                (HtmlAttribute _) :: otherAttributes ->
                    getTagName otherAttributes

                (Batch innerAttributes) :: otherAttributes ->
                    getTagName innerAttributes
                        |> Maybe.Extra.orElse (getTagName otherAttributes)

                [] ->
                    Nothing
    in
    getTagName attrs
        |> Maybe.withDefault "div"


class : String -> Attribute msg
class className =
    attribute (Html.Attributes.class className)


style : String -> String -> Attribute msg
style prop value =
    attribute (Html.Attributes.style prop value)


styles : List ( String, String ) -> Attribute msg
styles styleList =
    batch (List.map (\( prop, value ) -> style prop value) styleList)


fillWidth : Attribute msg
fillWidth =
    class "fill-width"


fillHeight : Attribute msg
fillHeight =
    class "fill-height"


padding : Int -> Attribute msg
padding value =
    style "padding" (px value)


paddingXY : Int -> Int -> Attribute msg
paddingXY x y =
    style "padding" (px y ++ " " ++ px x)


px : Int -> String
px value =
    String.fromInt value ++ "px"


spacing : Int -> Attribute msg
spacing value =
    style "gap" (px value)


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



---


box : Int -> List (Attribute msg) -> Html msg
box size attrs =
    column
        [ style "width" (px size)
        , style "height" (px size)
        , batch attrs
        ]
        [ Html.text " " ]


filler : List (Attribute msg) -> Html msg
filler attrs =
    column
        [ fillWidth
        , fillHeight
        , batch attrs
        ]
        [ Html.text " " ]


button : msg -> List (Attribute msg) -> List (Html msg) -> Html msg
button onClick attrs children =
    row
        [ htmlTag "button"
        , attribute (Html.Events.onClick onClick)
        , batch attrs
        ]
        children


label : { for : String } -> List (Attribute msg) -> List (Html msg) -> Html msg
label { for } attrs children =
    column
        [ htmlTag "label"
        , attribute (Html.Attributes.for for)
        , batch attrs
        ]
        children


id : String -> Attribute msg
id value_ =
    attribute (Html.Attributes.id value_)
