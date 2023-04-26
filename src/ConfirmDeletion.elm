module ConfirmDeletion exposing (view)

import Element
import View
import Text
import Utils

type alias Config msg =
    { onCancel : msg
    , onConfirm : msg
    , viewport : View.Viewport
    , language : Text.Language
    }

view : Config msg -> Element.Element msg
view { onCancel, onConfirm, viewport, language } =
    let
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
        { header = Text.text24 language Text.ConfirmDeletionHeading
        , body = [
            Text.text14 language Text.ConfirmDeletionBody
        ]
        , footer = footer
        , viewport = viewport
        }
