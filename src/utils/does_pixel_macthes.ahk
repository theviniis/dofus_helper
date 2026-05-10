#Requires AutoHotkey v2.0
#Include send_tooltip.ahk

doesPixelMatches(posX, posY, color) {
    loop {
        pixelColor := PixelGetColor(posX, posY)
        result := pixelColor == color
        if (result) {
            sendTooltip("Pixel encontrado!")
            return result
        } else {
            ToolTip("Procurando pixel...")
        }
        Sleep(100)
    }
}
