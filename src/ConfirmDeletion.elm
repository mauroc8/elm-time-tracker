module ConfirmDeletion exposing (Config, view)

import Element
import Text
import Ui


type alias Config msg =
    { onCancel : msg
    , onConfirm : msg
    , viewport : Ui.Viewport
    , language : Text.Language
    }


view : Config msg -> Element.Element msg
view { onCancel, onConfirm, viewport, language } =
    let
        footer =
            Ui.cancelConfirmButtons
                { onCancel = onCancel
                , onConfirm = onConfirm
                , confirmText = Text.Delete
                , language = language
                , viewport = viewport
                }
    in
    Ui.modalContent
        { header = Text.text24 language Text.ConfirmDeletionHeading
        , body =
            [ Element.paragraph
                [ Element.spacing 6 ]
                [ Text.text14 language Text.ConfirmDeletionBody
                ]
            ]
        , footer = footer
        , viewport = viewport
        , onClose = onCancel
        }
