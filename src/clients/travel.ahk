#Requires AutoHotkey v2.0

SLEEP_TIME := 200

class TravelNavigator {
    __New(clientInterface) {
        this.clientIF := clientInterface
    }

    use() {
        input := InputBox(
            "xx,yy",
            "Coordenadas",
        )
        if (input.result != "OK" or input.value = "") {
            return false
        }

        ; Aceita: xx,yy | [xx,yy | xx,yy] | [xx,yy] | /travel xx,yy (e variantes com colchetes e espaços)
        if !RegExMatch(Trim(input.value), "i)^(?:/travel\s*)?\[?\s*(-?\d+\s*,\s*-?\d+)\s*\]?$", &m) {
            ToolTip("Formato inválido. Use xx,yy")
            Sleep(1500)
            ToolTip("")
            return false
        }

        this.clientIF.openChat()
        Sleep(SLEEP_TIME)
        destination := "/travel " . RegExReplace(m[1], "\s", "")
        this.clientIF.clearInput()
        this.clientIF.sendText(destination)
        Sleep(SLEEP_TIME)
        this.clientIF.confirm()
        this.clientIF.sleep(1000)
        this.clientIf.sendKey("{Esc}")
        return true
    }
}
