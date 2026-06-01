#Requires AutoHotkey v2.0

#Include ./src/utils/header.ahk
#Include ./src/utils/JSON.ahk
#Include ./src/utils/init.ahk

#Include ./src/utils/copy_pixel_color_and_position.ahk

config := Jxon_Load_File("config.json")
app := Init(config)
MAIN_CHARACTER := app.account.mainCharacter

; TRAVEL
$^t:: app.travel.use()

; USE ZAP
$+h:: app.zap.use()

$^h:: app.zap.useAll()

$^Esc:: app.zap.stop()

; COPY WINDOW NAME
$#c:: app.client.copyWindowName()

; MACRO RECORDER
$F9:: {
    app.macro.toggle()
    app.client.sleep(500)
    app.account.focus(MAIN_CHARACTER)
}

; GROUP OVERLAY
$^g:: app.group.toggleOverlay()