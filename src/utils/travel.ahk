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

        if !RegExMatch(input.value, "^\d+,\d+$") {
            ToolTip("Formato inválido. Use xx,yy")
            Sleep(1500)
            ToolTip("")
            return false
        }

        this.clientIF.openChat()
        Sleep(SLEEP_TIME)
        this.clientIF.sendText("/travel " . input.value)
        Sleep(SLEEP_TIME)
        this.clientIF.confirm()
        return true
    }
}
