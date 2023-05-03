module ChangeStartTime exposing (Config, Model, initialModel, view)

import Colors
import CreateRecord
import Element
import Element.Font
import Element.Input
import Element.Region
import Text
import Time
import Utils.Date
import Utils.Time
import View
import Debug


type alias Model =
    { inputValue : String
    , showInputError : Bool
    }


initialModel :
    { a
        | timeZone : Time.Zone
        , language : Text.Language
    }
    -> CreateRecord.CreateRecord
    -> Model
initialModel { timeZone, language } { start } =
    let
        _ = Debug.log "start" start
    in
    { inputValue =
        Utils.Time.fromZoneAndPosix timeZone start
            |> Utils.Time.toHhMm
    , showInputError = False
    }


type alias Config msg =
    { onCancel : msg
    , onConfirm : msg -- TODO: Time.Posix -> msg
    , onChange :
        String
        -> msg -- TODO: Model -> msg
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
                        (Text.text14 language Text.ChangeStartTimeLabel)
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
                    [ Text.text14 language Text.InvalidStartTimeMessage ]

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
        , onClose = onCancel
        }
