module ChangeStartTime exposing (Config, Model, view)

import Colors
import CreateRecord
import Element
import Element.Font
import Element.Input
import Element.Region
import Text
import Time
import Utils.Date
import View


type alias Model =
    { inputValue : String
    , showInputError : Bool
    }


initialModel :
    { timezone : Time.Zone
    , dateNotation : Utils.Date.Notation
    , language : Text.Language
    }
    -> CreateRecord.CreateRecord
    -> Model
initialModel { timezone, dateNotation, language } { start } =
    { inputValue =
        Utils.Date.fromZoneAndPosix timezone start
            |> Utils.Date.toLabel dateNotation
            |> Text.toString language
    , showInputError = False
    }


type alias Config msg =
    { onCancel : msg
    , onConfirm : msg
    , onChange : String -> msg
    , viewport : View.Viewport
    , language : Text.Language
    }


view : Config msg -> Model -> Element.Element msg
view { language, onChange, onCancel, onConfirm, viewport } { inputValue, showInputError } =
    let
        header =
            Text.text24 language Text.ChangeStartTimeHeading

        body =
            [ Element.Input.text
                [ Element.width (Element.px 80)
                ]
                { label =
                    Element.Input.labelAbove
                        [ Element.Font.semiBold
                        ]
                        (Text.text14 language <| Text.String "Hora de inicio") -- TODO:
                , onChange = onChange
                , placeholder =
                    Just (Element.Input.placeholder [] (Text.text16 language <| Text.String "16:45"))
                , text = inputValue
                }
            , if showInputError then
                Element.paragraph
                    [ Element.Font.color Colors.red
                    , Element.Region.announce
                    ]
                    [ Text.text14 language (Text.String "La hora ingresada no es válida") ]

              else
                Element.none
            ]

        footer =
            View.cancelConfirmButtons
                { onCancel = onCancel
                , onConfirm = onConfirm
                , confirmText = Text.Confirm
                , language = language
                , viewport = viewport
                }
    in
    View.modalContent
        { header = header
        , body = body
        , footer = footer
        , viewport = viewport
        }
