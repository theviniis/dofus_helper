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

        if !RegExMatch(input.value, "^-?\d+,-?\d+$") && !RegExMatch(input.value, "i)^/travel\s*-?\d+,-?\d+$") {
            ToolTip("Formato inválido. Use xx,yy")
            Sleep(1500)
            ToolTip("")
            return false
        }

        this.clientIF.openChat()
        Sleep(SLEEP_TIME)
        destination := input.value
        if !RegExMatch(destination, "i)^/travel") {
            destination := "/travel " . destination
        }
        this.clientIF.sendText(destination)
        Sleep(SLEEP_TIME)
        this.clientIF.confirm()
        return true
    }
}
