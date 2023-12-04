module ChangeStartTime exposing (Config, Model, initialModel, setErrorMessage, view)

import Clock
import Colors
import CreateRecord
import Element
import Element.Border
import Element.Font
import Element.Input
import Element.Region
import Text
import Time
import Ui
import Utils.Date
import Utils.Time


type alias Model =
    { inputValue : String
    , inputError : Maybe Text.Text
    }


initialModel :
    { a
        | timeZone : Time.Zone
        , language : Text.Language
    }
    -> Time.Posix
    -> Model
initialModel { timeZone, language } startTime =
    { inputValue =
        Utils.Time.fromZoneAndPosix timeZone startTime
            |> Utils.Time.toHhMm
    , inputError = Nothing
    }


setErrorMessage : Text.Text -> Model -> Model
setErrorMessage errorMessage model =
    { model | inputError = Just errorMessage }


type alias Config msg =
    { onCancel : msg
    , onConfirm : Clock.Time -> msg
    , onChange : Model -> msg
    , viewport : Ui.Viewport
    , language : Text.Language
    }


view : Config msg -> Model -> Element.Element msg
view { language, onChange, onCancel, onConfirm, viewport } { inputValue, inputError } =
    let
        header =
            Text.text24 language Text.ChangeStartTimeHeading

        input =
            Element.Input.text
                [ Element.width (Element.px 150)
                , Element.Border.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
                , Element.Border.color Colors.darkGrayBackground
                , Element.Border.rounded 0
                , Element.paddingXY 0 8
                ]
                { label =
                    Element.Input.labelAbove
                        [ Element.Font.semiBold ]
                        (Text.text14 language Text.ChangeStartTimeLabel)
                , onChange = \value -> onChange { inputValue = value, inputError = Nothing }
                , placeholder =
                    Just (Text.text16 language <| Text.String "16:45")
                , text = inputValue
                }

        error =
            case inputError of
                Just errorMessage ->
                    Element.paragraph
                        [ Element.Font.color Colors.red
                        , Element.Region.announce
                        ]
                        [ Text.text14 language errorMessage ]

                Nothing ->
                    Element.none

        body =
            [ input
            , error
            ]

        confirm =
            case Utils.Time.fromHhMm inputValue of
                Ok time ->
                    onConfirm time

                Err errorMessage ->
                    onChange { inputValue = inputValue, inputError = Just errorMessage }

        footer =
            Ui.cancelConfirmButtons
                { onCancel = onCancel
                , onConfirm = confirm
                , confirmText = Text.Confirm
                , language = language
                , viewport = viewport
                }
    in
    Ui.modalContent
        { header = header
        , body = body
        , footer = footer
        , viewport = viewport
        , onClose = onCancel
        }
