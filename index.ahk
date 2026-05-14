#Requires AutoHotkey v2.0

#Include ./src/utils/header.ahk
#Include ./src/utils/JSON.ahk
#Include ./src/utils/init.ahk

config := Jxon_Load_File("config.json")
app := Init(config)

$#1:: app.account.focus('iop')
$#2:: app.account.focus('eni')
$#3:: app.account.focus('cra')
$#4:: app.account.focus('sac')

$^t:: app.travel.use()
$+h:: app.zap.use()

$^h:: {
    app.account.focus('sac')
    app.zap.useAll()
}

$^Esc:: app.zap.stop()

$#c:: app.client.copyWindowName()

; ── Macro Broadcaster ──────────────────────────────────────────────────────
; F9: inicia a gravação de teclado/mouse.
; F9 novamente: para e replica as ações em todas as contas abertas.
$F9:: {
    app.macro.toggle()
    app.client.sleep(500)
    app.account.focus('sac')
}
