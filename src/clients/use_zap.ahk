#Requires AutoHotkey v2.0

class ZapNavigator {
    __New(travelersBagConfig, clientIF, historyMgr) {
        this.travelersBagConfig := travelersBagConfig
        this.clientIF := clientIF
        this.historyMgr := historyMgr
        this.running := false
        this.destination := ""
    }

    isOnTravelScreen {
        get {
            return this.clientIF.pixelMatches("zap")
        }
    }

    isZapInterfaceOpen {
        get {
            return this.clientIF.pixelMatches("interfaceZap")
        }
    }

    clickZap() {
        this.clientIF.clickAt("zap")
    }

    clickSearch() {
        this.clientIF.clickAt("search")
    }

    travel() {
        this.clientIF.sendKey("h")
    }

    getDestination() {
        if (this.destination != "") {
            return this.destination
        }

        allDests := this.historyMgr.getAll()
        hasHistory := allDests.Length > 0
        state := { result: "", done: false }

        myGui := Gui("+AlwaysOnTop", "ZapNavigator - Destino")
        myGui.SetFont("s10")
        myGui.Add("Text", "w300", "Selecione ou digite o destino:")

        if (hasHistory) {
            myGui.Add("ListBox", "vSelectedDestination w300 h150", allDests)
        }

        myGui.Add("Edit", "vNewDestination w300")

        OnOK(*) {
            newDest := Trim(myGui["NewDestination"].Value)
            if (newDest != "") {
                state.result := newDest
            } else if (hasHistory) {
                try {
                    state.result := myGui["SelectedDestination"].Text
                }
            }
            state.done := true
            myGui.Destroy()
        }

        OnCancel(*) {
            state.done := true
            myGui.Destroy()
        }

        OnClose(GuiObj) {
            state.done := true
            GuiObj.Destroy()
        }

        myGui.Add("Button", "w80", "Cancel").OnEvent("Click", OnCancel)
        myGui.Add("Button", "x+10 w80 Default", "OK").OnEvent("Click", OnOK)
        myGui.OnEvent("Close", OnClose)
        myGui.Show()
        myGui["NewDestination"].Focus()

        while !state.done {
            Sleep(50)
        }

        if (state.result != "") {
            this.destination := state.result
            this.historyMgr.add(state.result)
        }

        return this.destination
    }

    use(forceInput := true) {
        if (forceInput) {
            this.destination := ""
        }

        if (this.destination = "") {
            dest := this.getDestination()
            if (dest = "") {
                return false
            }
        }

        this.running := true

        while (this.running) {
            isZapOpen := this.isZapInterfaceOpen
            isTravelOpen := this.isOnTravelScreen

            if (isZapOpen) {
                this.clickSearch()
                this.clientIF.sleep()
                this.clientIF.clearInput()
                this.clientIF.sleep()
                this.clientIF.sendText(this.destination)
                this.clientIF.sleep()
                this.clientIF.confirm()
                break
            }
            else if (isTravelOpen) {
                this.clickZap()
            }
            else {
                this.travel()
                this.clientIF.sleep(500)
                ; while (!this.isOnTravelScreen && !this.isZapInterfaceOpen) {
                ;     this.clientIF.sleep()
                ; }
            }

            this.clientIF.sleep()
        }

        this.running := false
        return true
    }

    stop() {
        this.running := false
    }
}
