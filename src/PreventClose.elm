port module PreventClose exposing (off, on)


port setPreventClose : Bool -> Cmd msg


on : Cmd msg
on =
    setPreventClose True


off : Cmd msg
off =
    setPreventClose False
