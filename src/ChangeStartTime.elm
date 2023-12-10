module ChangeStartTime exposing (Model, initialModel, setErrorMessage)

import Clock
import Colors
import CreateRecord
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
