module DefaultView exposing (Config, view)

import Element exposing (Element)
import Icons
import Record
import RecordList
import Sidebar
import Text
import Time
import Utils.Date
import View exposing (Emphasis)


type alias Config msg =
    { emphasis : Emphasis
    , language : Text.Language
    , viewport : View.Viewport
    , currentTime : Time.Posix
    , dateNotation : Utils.Date.Notation
    , timeZone : Time.Zone
    , records : RecordList.RecordList
    , sidebar : Sidebar.Config msg
    , clickedSettings : msg
    , clickedDeleteButton : Record.Id -> msg
    }


view : Config msg -> Element msg
view ({ emphasis, sidebar, viewport } as config) =
    let
        viewRecordListWithHeading =
            [ -- Heading
              headingSection config
                |> withHeaderLayout config
                |> withHorizontalDivider emphasis

            -- RecordList
            , RecordList.view config
            ]

        viewSidebar =
            [ Sidebar.view sidebar
                |> Element.el
                    [ Element.width (Element.fill |> Element.maximum 600)
                    , Element.padding 24
                    , Element.centerX
                    ]
                |> Element.el
                    (Element.width Element.fill :: View.sidebarBackgroundColor emphasis)
            ]
    in
    Element.column
        [ Element.width Element.fill
        , Element.height Element.fill
        , Element.scrollbarX
        ]
        (viewSidebar
            ++ (case viewport of
                    View.Mobile ->
                        viewRecordListWithHeading

                    View.Desktop ->
                        [ Element.column
                            [ Element.width (Element.fill |> Element.maximum 600)
                            , Element.centerX
                            , Element.height Element.fill
                            ]
                            viewRecordListWithHeading
                        ]
               )
        )



--- Heading


headingSection : Config msg -> Element msg
headingSection config =
    Element.row
        [ Element.spacing 16
        , Element.width Element.fill
        ]
        [ settingsButton config
        ]


withHeaderLayout : { config | viewport : View.Viewport } -> Element msg -> Element msg
withHeaderLayout { viewport } =
    let
        padding =
            case viewport of
                View.Mobile ->
                    Element.padding 16

                View.Desktop ->
                    Element.paddingXY 0 16
    in
    Element.el
        [ padding
        , Element.width Element.fill
        ]


withHorizontalDivider : Emphasis -> Element msg -> Element msg
withHorizontalDivider emphasis el =
    Element.column
        [ Element.width Element.fill
        ]
        [ el
        , View.recordListHorizontalDivider emphasis
        ]


settingsButton :
    { a
        | emphasis : Emphasis
        , clickedSettings : msg
    }
    -> Element msg
settingsButton { emphasis, clickedSettings } =
    View.recordListButton
        { emphasis = emphasis
        , onClick = clickedSettings
        , label = Icons.options
        }
