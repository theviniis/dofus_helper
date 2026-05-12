#Requires AutoHotkey v2.0

class TravelNavigator {
    __New(client) {
        this.client := client
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

        this.client.openChat()
        Sleep(SLEEP_TIME)
        destination := "/travel " . RegExReplace(m[1], "\s", "")
        this.client.clearInput()
        this.client.sendText(destination)
        Sleep(SLEEP_TIME)
        this.client.confirm()
        this.client.sleep(1000)
        this.client.sendKey("{Esc}")
        return true
    }
}
