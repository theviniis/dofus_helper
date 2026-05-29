#Requires AutoHotkey v2.0

class TravelNavigator {
    __New(client) {
        this.client := client
    }

    use() {
        state := { value: "", done: false }

        myGui := Gui("+AlwaysOnTop", "Coordenadas")
        GuiTheme.Apply(myGui)
        myGui.Add("Text", "x10 y10 w200", "xx,yy")
        editCtrl := myGui.Add("Edit", "x10 y30 w200 vValue")
        myGui.Add("Button", "x10 y60 w80", "Cancel").OnEvent("Click", OnCancel)
        okBtn := myGui.Add("Button", "x+10 y60 w80 Default", "OK")
        okBtn.SetFont("bold c" Format("{:06X}", GuiTheme.ACCENT))
        okBtn.OnEvent("Click", OnOK)
        myGui.OnEvent("Close", OnClose)
        myGui.Show()
        editCtrl.Focus()

        OnOK(*) {
            state.value := myGui["Value"].Value
            state.done := true
            myGui.Destroy()
        }

        OnCancel(*) {
            state.done := true
            myGui.Destroy()
        }

        OnClose(g) {
            state.done := true
            g.Destroy()
        }

        while !state.done
            Sleep(50)

        if (state.value = "")
            return false

        ; Aceita: xx,yy | [xx,yy | xx,yy] | [xx,yy] | /travel xx,yy | xx,yy]. | xx,yy], (e variantes com colchetes, ponto ou vírgula no fim)
        if !RegExMatch(Trim(state.value), "i)^(?:/travel\s*)?\[?\s*(-?\d+\s*,\s*-?\d+)\s*\]?[.,]?$", &m) {
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
