module Sidebar exposing (Config(..), view)

import Element exposing (Element)
import Icons
import View



--- SIDE BAR


type Config msg
    = NotPlaying { start : msg }
    | Playing
        { description : String
        , elapsedTime : String
        , changedDescription : String -> msg
        , stop : msg
        }
    | Editing
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
        NotPlaying { start } ->
            View.button
                [ Element.centerX
                ]
                { onPress = View.enabled start
                , label = Icons.playButton
                }

        _ ->
            View.button
                [ Element.centerX
                ]
                { onPress = View.disabled
                , label = Icons.stopButton
                }
