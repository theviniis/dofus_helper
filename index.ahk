#Requires AutoHotkey v2.0

#Include ./src/utils/header.ahk
#Include ./src/utils/JSON.ahk
#Include ./src/utils/init.ahk

MAIN_CHARACTER := 'enu'

config := Jxon_Load_File("config.json")
app := Init(config)

; ACCOUNT FOCUS
$#1:: app.account.focus('eni')
$#2:: app.account.focus('panda')
$#3:: app.account.focus('iop')
$#4:: app.account.focus(MAIN_CHARACTER)

; TRAVEL
$^t:: {
    app.client.focus(MAIN_CHARACTER)
    app.travel.use()
}

; USE ZAP
$+h:: app.zap.use()

$^h:: {
    app.account.focus(MAIN_CHARACTER)
    app.zap.useAll()
}

$^Esc:: app.zap.stop()

; COPY WINDOW NAME
$#c:: app.client.copyWindowName()

; MACRO RECORDER
$F9:: {
    app.macro.toggle()
    app.client.sleep(500)
    app.account.focus(MAIN_CHARACTER)
}
