module Text exposing
    ( Language(..)
    , Text(..)
    , defaultLanguage
    , encodeLanguage
    , languageDecoder
    , toHtml
    , toString
    )

import Html exposing (Html)
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
    [ English
    , Spanish
    ]
        |> List.map
            (\language -> Utils.decodeLiteral language (languageToString language))
        |> Json.Decode.oneOf



-- Text


type
    Text
    -- Settings
    = Settings
    | Back
    | DateNotationLabel
    | InternationalDateNotation
    | UsaDateNotation
    | LanguageLabel
    | EnglishLanguage
    | SpanishLanguage
    | AboutThisWebsite
    | YesterdayWas
    | TodayIs
      -- Running screen
    | Start
    | ChangeStartTimeButton
      -- Change Start Time
    | ChangeStartTimeHeading
    | ChangeStartTimeLabel
    | InvalidTime
    | InvalidTimeFormat
      -- History
    | History
    | YouDeletedARecord
    | Undo
    | Delete
    | Integer Int
    | Words (List Text)
      -- Duration
    | Seconds
    | Hours
    | Minutes
    | Days
      -- Date
    | Today
    | Yesterday
    | Tomorrow
    | Weekday Time.Weekday
    | InternationalDate Int Time.Month Int
    | UsaDate Time.Month Int Int
      -- Other
    | CommentAboutStorage


toString : Language -> Text -> String
toString lang text =
    case ( text, lang ) of
        -- Settings
        ( Settings, English ) ->
            "Settings"

        ( Settings, Spanish ) ->
            "Opciones"

        ( Back, English ) ->
            "Back"

        ( Back, Spanish ) ->
            "Volver"

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

        ( AboutThisWebsite, English ) ->
            "About this website"

        ( AboutThisWebsite, Spanish ) ->
            "Acerca de este sitio"

        ( YesterdayWas, English ) ->
            "Yesterday was"

        ( YesterdayWas, Spanish ) ->
            "Ayer fue"

        ( TodayIs, English ) ->
            "Today is"

        ( TodayIs, Spanish ) ->
            "Hoy es"

        -- Create Form
        ( Start, English ) ->
            "Start"

        ( Start, Spanish ) ->
            "Iniciar"

        ( ChangeStartTimeButton, English ) ->
            "change start time"

        ( ChangeStartTimeButton, Spanish ) ->
            "cambiar tiempo de inicio"

        -- Change Start Time
        ( ChangeStartTimeHeading, English ) ->
            "Change start time"

        ( ChangeStartTimeHeading, Spanish ) ->
            "Cambiar tiempo de inicio"

        ( ChangeStartTimeLabel, English ) ->
            "Start time"

        ( ChangeStartTimeLabel, Spanish ) ->
            "Tiempo de inicio"

        ( InvalidTime, English ) ->
            "The time is not valid"

        ( InvalidTime, Spanish ) ->
            "La hora ingresada no es válida"

        ( InvalidTimeFormat, English ) ->
            "The time must be formatted as hh:mm"

        ( InvalidTimeFormat, Spanish ) ->
            "La hora debe estar en el formato hh:mm"

        -- History
        ( History, English ) ->
            "History"

        ( History, Spanish ) ->
            "Historial"

        ( YouDeletedARecord, English ) ->
            "You deleted a record"

        ( YouDeletedARecord, Spanish ) ->
            "Borraste un registro"

        ( Undo, English ) ->
            "Undo"

        ( Undo, Spanish ) ->
            "Deshacer"

        ( Delete, English ) ->
            "Delete"

        ( Delete, Spanish ) ->
            "Eliminar"

        ( Integer int, _ ) ->
            String.fromInt int

        ( Words words, _ ) ->
            String.join " "
                (List.map (toString lang) words)

        -- Duration
        ( Seconds, _ ) ->
            "s"

        ( Hours, _ ) ->
            "h"

        ( Minutes, _ ) ->
            "m"

        ( Days, _ ) ->
            "d"

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

        -- Other
        ( CommentAboutStorage, English ) ->
            "The data is stored on your browser's cache. You'll lose all records when you clear the cache."

        ( CommentAboutStorage, Spanish ) ->
            "Los datos se guardan en la caché del navegador. Perderás todos los registros al limpiar la caché."


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


toHtml : Language -> Text -> Html msg
toHtml language text =
    Html.text (toString language text)
