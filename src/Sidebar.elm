module Sidebar exposing (Config(..), view)

import CreateForm
import Element exposing (Element)
import Icons
import View



--- SIDE BAR


type Config msg
    = Idle { pressedStart : msg }
    | CreatingRecord (CreateForm.Config msg)
    | EditingRecord
        { description : String
        , changedDescription : String -> msg
        , startTime : String
        , changedStartTime : String -> msg
        , duration : String
        , changedDuration : String -> msg
        , endTime : String
        , changedEndTime : String -> msg
        , date : String
        , changedDate : String -> msg
        , pressedCancel : msg
        , pressedSave : msg
        }


view : Config msg -> Element msg
view config =
    case config of
        Idle { pressedStart } ->
            View.button
                [ Element.centerX
                ]
                { onPress = View.enabled pressedStart
                , label = Icons.playButton
                }

        _ ->
            View.button
                [ Element.centerX
                ]
                { onPress = View.disabled
                , label = Icons.stopButton
                }
