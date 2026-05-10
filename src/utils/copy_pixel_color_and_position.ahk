#Requires AutoHotkey v2.0
CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")

LControl & RAlt:: copyPixelColorAndPosition()

copyPixelColorAndPosition() {
    MouseGetPos(&x, &y)
    color := PixelGetColor(x, y)
    text := x . ", " . y . ", " . color
    A_Clipboard := text
    ToolTip("Cor copiada!" . text)
    Sleep(250)
    ToolTip("")
}
