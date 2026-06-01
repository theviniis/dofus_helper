#Requires AutoHotkey v2.0

SLEEP_TIME := 200

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
        g.Add("Text",, "Coordenadas (xx,yy):")
        g.Add("Edit", "w200 vCoords")
        g.Add("CheckBox", "vFocusMain Checked", "Focar personagem principal?")
        g.Add("Button", "Default w80", "OK").OnEvent("Click", OkClick)
        g.Add("Button", "w80", "Cancelar").OnEvent("Click", (*) => g.Destroy())
        g.OnEvent("Close", (*) => g.Destroy())

        g.Show()
        WinWaitClose(g)

        if !submitted
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
