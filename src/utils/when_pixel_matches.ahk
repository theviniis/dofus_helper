#Requires AutoHotkey v2.0

whenPixelMatches(posX, posY, color) {
    pixelColor := PixelGetColor(posX, posY)
    result := pixelColor == color
    return result
}
