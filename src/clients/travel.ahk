#Requires AutoHotkey v2.0

class TravelNavigator {
    __New(client, account, mainCharacter) {
        this.client := client
        this.account := account
        this.mainCharacter := mainCharacter
    }

    use() {
        submitted := false
        savedData := ""

        OkClick(*) {
            savedData := g.Submit()
            submitted := true
            g.Destroy()
        }

        g := Gui(, "Coordenadas")
        g.Add("GroupBox", "x10 y10 w240 h65", "Destino")
        g.Add("Text", "x20 y28", "Coordenadas (xx,yy):")
        g.Add("Edit", "x20 y44 w220 vCoords -E0x200")
        g.Add("GroupBox", "x10 y82 w240 h40", "Opções")
        g.Add("CheckBox", "x20 y97 vFocusMain Checked", "Focar personagem principal?")
        g.Add("Button", "x80 y132 w80", "Cancelar").OnEvent("Click", (*) => g.Destroy())
        g.Add("Button", "x170 y132 w80 Default", "OK").OnEvent("Click", OkClick)
        g.OnEvent("Close", (*) => g.Destroy())

        g.Show("w260")
        WinWaitClose(g)

        if !submitted
            return false

        if (Trim(savedData.Coords) = "")
            return false

        if !RegExMatch(Trim(savedData.Coords), "i)^(?:/travel\s*)?\[?\s*(-?\d+\s*,\s*-?\d+)\s*\]?[.,]?$", &m) {
            ToolTip("Formato inválido. Use xx,yy")
            Sleep(1500)
            ToolTip("")
            return false
        }

        if savedData.FocusMain
            this.account.focus(this.mainCharacter)

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
