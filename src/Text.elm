module Text exposing
    ( Language(..)
    , Text(..)
    , defaultLanguage
    , text12
    , text13
    , text14
    , text16
    , text24
    , toString
    )

import Element exposing (Attribute, Element)
import Element.Font as Font
import Html.Attributes



--- Language


type Language
    = English
    | Spanish


defaultLanguage : Language
defaultLanguage =
    English



-- Text


type
    Text
    -- Settings
    = SettingsHeading
    | UsaDateNotation
    | LanguageLabel
    | EnglishLanguage
    | SpanishLanguage
    | Cancel
    | Save
      -- Create Form
    | WhatAreYouWorkingOn
    | DescriptionLabel
      -- Empty states
    | PressTheStartButtonToCreateARecord
    | NothingFound
      -- Record List
    | SearchPlaceholder
    | Search
    | NoDescription
      -- Other
    | Unlocalized String
      -- Date and Time
    | Prepend String Text


toString : Language -> Text -> String
toString lang text =
    case ( text, lang ) of
        -- Settings
        ( SettingsHeading, English ) ->
            "Settings"

        ( SettingsHeading, Spanish ) ->
            "Opciones"

        ( UsaDateNotation, English ) ->
            "USA date format (mm/dd/yyyy)"

        ( UsaDateNotation, Spanish ) ->
            "Ver fechas como en EEUU (mm/dd/yyyy)"

        ( LanguageLabel, English ) ->
            "Language"

        ( LanguageLabel, Spanish ) ->
            "Idioma"

        ( EnglishLanguage, _ ) ->
            "English"

        ( SpanishLanguage, _ ) ->
            "Español"

        ( Cancel, English ) ->
            "Cancel"

        ( Cancel, Spanish ) ->
            "Cancelar"

        ( Save, English ) ->
            "Save"

        ( Save, Spanish ) ->
            "Guardar"

        -- Create Form
        ( WhatAreYouWorkingOn, English ) ->
            "what are you working on?"

        ( WhatAreYouWorkingOn, Spanish ) ->
            "en qué estás trabajando?"

        ( DescriptionLabel, English ) ->
            "Description"

        ( DescriptionLabel, Spanish ) ->
            "Descripción"

        -- Empty states
        ( PressTheStartButtonToCreateARecord, English ) ->
            "Press the Start button to create a record"

        ( PressTheStartButtonToCreateARecord, Spanish ) ->
            "Presiona Play para crear un registro"

        ( NothingFound, English ) ->
            "Nothing found"

        ( NothingFound, Spanish ) ->
            "No hay resultados"

        -- Record List
        ( SearchPlaceholder, _ ) ->
            toString lang Search ++ "…"

        ( Search, English ) ->
            "Search"

        ( Search, Spanish ) ->
            "Buscar"

        ( NoDescription, English ) ->
            "no description"

        ( NoDescription, Spanish ) ->
            "descripción vacía"

        -- Other
        ( Unlocalized str, _ ) ->
            str

        ( Prepend str text_, _ ) ->
            str ++ toString lang text_



--- FONT SIZE


text12 : Language -> Text -> Element msg
text12 =
    textWith
        { lineHeight = 9
        , fontSize = 12
        }


text13 : Language -> Text -> Element msg
text13 =
    textWith
        { lineHeight = 11
        , fontSize = 13
        }


text14 : Language -> Text -> Element msg
text14 =
    textWith
        { lineHeight = 10
        , fontSize = 14
        }


text16 : Language -> Text -> Element msg
text16 =
    textWith
        { lineHeight = 12
        , fontSize = 16
        }


text24 : Language -> Text -> Element msg
text24 =
    textWith
        { lineHeight = 19
        , fontSize = 24
        }


textWith :
    { lineHeight : Int
    , fontSize : Int
    }
    -> Language
    -> Text
    -> Element msg
textWith { lineHeight, fontSize } language text =
    Element.el
        [ Font.size fontSize
        , lineHeightAttr lineHeight
        ]
        (Element.text (toString language text))


lineHeightAttr : Int -> Attribute msg
lineHeightAttr value =
    Element.htmlAttribute
        (Html.Attributes.style
            "line-height"
            (String.fromInt value ++ "px")
        )
