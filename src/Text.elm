module Text exposing
    ( Language(..)
    , Text(..)
    , defaultLanguage
    , encodeLanguage
    , languageDecoder
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
import Json.Decode
import Json.Encode
import Time
import Utils



--- Language


type Language
    = English
    | Spanish


defaultLanguage : Language
defaultLanguage =
    English


languageToString : Language -> String
languageToString lang =
    case lang of
        English ->
            "English"

        Spanish ->
            "Spanish"


encodeLanguage : Language -> Json.Encode.Value
encodeLanguage lang =
    Json.Encode.string (languageToString lang)


languageDecoder : Json.Decode.Decoder Language
languageDecoder =
    Json.Decode.oneOf
        [ Utils.decodeLiteral English (languageToString English)
        , Utils.decodeLiteral Spanish (languageToString Spanish)
        ]



-- Text


type
    Text
    -- Settings
    = SettingsHeading
    | DateNotationLabel
    | InternationalDateNotation
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
    | ClearSearch
    | NoDescription
      -- Operators
    | Text String
    | Integer Int
    | Words (List Text)
      -- Duration
    | Second
    | Seconds
    | Hour
    | Hours
    | Minute
    | Minutes
    | Day
    | Days
      -- Date
    | Today
    | Yesterday
    | Tomorrow
    | Weekday Time.Weekday
    | InternationalDate Int Time.Month Int
    | UsaDate Time.Month Int Int


toString : Language -> Text -> String
toString lang text =
    case ( text, lang ) of
        -- Settings
        ( SettingsHeading, English ) ->
            "Settings"

        ( SettingsHeading, Spanish ) ->
            "Opciones"

        ( DateNotationLabel, English ) ->
            "Date notation"

        ( DateNotationLabel, Spanish ) ->
            "Formato de fechas"

        ( InternationalDateNotation, English ) ->
            "International date notation"

        ( InternationalDateNotation, Spanish ) ->
            "Formato de fecha internacional"

        ( UsaDateNotation, English ) ->
            "USA date notation"

        ( UsaDateNotation, Spanish ) ->
            "Formato de fecha de EE.UU."

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

        ( ClearSearch, English ) ->
            "Clear"

        ( ClearSearch, Spanish ) ->
            "Limpiar"

        ( NoDescription, English ) ->
            "no description"

        ( NoDescription, Spanish ) ->
            "descripción vacía"

        -- Operators
        ( Text str, _ ) ->
            str

        ( Integer int, _ ) ->
            String.fromInt int

        ( Words words, _ ) ->
            String.join " "
                (List.map (toString lang) words)

        -- Duration
        ( Second, English ) ->
            "second"

        ( Second, Spanish ) ->
            "segundo"

        ( Seconds, English ) ->
            "seconds"

        ( Seconds, Spanish ) ->
            "segundos"

        ( Hour, English ) ->
            "hour"

        ( Hours, English ) ->
            "hours"

        ( Hour, Spanish ) ->
            "hora"

        ( Hours, Spanish ) ->
            "horas"

        ( Minute, English ) ->
            "minute"

        ( Minutes, English ) ->
            "minutes"

        ( Minute, Spanish ) ->
            "minuto"

        ( Minutes, Spanish ) ->
            "minutos"

        ( Day, English ) ->
            "day"

        ( Day, Spanish ) ->
            "día"

        ( Days, English ) ->
            "days"

        ( Days, Spanish ) ->
            "días"

        -- Date
        ( Today, English ) ->
            "today"

        ( Today, Spanish ) ->
            "hoy"

        ( Yesterday, English ) ->
            "yesterday"

        ( Yesterday, Spanish ) ->
            "ayer"

        ( Tomorrow, English ) ->
            "tomorrow"

        ( Tomorrow, Spanish ) ->
            "mañana"

        ( Weekday wkd, English ) ->
            weekdayToEnglish wkd

        ( Weekday wkd, Spanish ) ->
            weekdayToSpanish wkd

        ( InternationalDate day month year, _ ) ->
            String.join "/"
                [ String.fromInt day
                , monthToString month
                , String.fromInt year
                ]

        ( UsaDate month day year, _ ) ->
            String.join "/"
                [ monthToString month
                , String.fromInt day
                , String.fromInt year
                ]


weekdayToEnglish : Time.Weekday -> String
weekdayToEnglish weekday =
    case weekday of
        Time.Mon ->
            "monday"

        Time.Tue ->
            "tuesday"

        Time.Wed ->
            "wednesday"

        Time.Thu ->
            "thursday"

        Time.Fri ->
            "friday"

        Time.Sat ->
            "saturday"

        Time.Sun ->
            "sunday"


weekdayToSpanish : Time.Weekday -> String
weekdayToSpanish weekday =
    case weekday of
        Time.Mon ->
            "lunes"

        Time.Tue ->
            "martes"

        Time.Wed ->
            "miércoles"

        Time.Thu ->
            "jueves"

        Time.Fri ->
            "viernes"

        Time.Sat ->
            "sábado"

        Time.Sun ->
            "domingo"


monthToString : Time.Month -> String
monthToString month =
    case month of
        Time.Jan ->
            "1"

        Time.Feb ->
            "2"

        Time.Mar ->
            "3"

        Time.Apr ->
            "4"

        Time.May ->
            "5"

        Time.Jun ->
            "6"

        Time.Jul ->
            "7"

        Time.Aug ->
            "8"

        Time.Sep ->
            "9"

        Time.Oct ->
            "10"

        Time.Nov ->
            "11"

        Time.Dec ->
            "12"



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
