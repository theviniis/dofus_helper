#Requires AutoHotkey v2.0

class ZapNavigator {
    __New(travelersBagConfig, client, travelHistory, account) {
        this.travelersBagConfig := travelersBagConfig
        this.client := client
        this.travelHistory := travelHistory
        this.running := false
        this.destination := ""
        this.selectedAccounts := []
        this.account := account
    }

    isOnTravelScreen {
        get {
            return this.client.pixelMatches("zap")
        }
    }

    isZapInterfaceOpen {
        get {
            return this.client.pixelMatches("zapInterface")
        }
    }

    clickZap() {
        this.client.clickAt("zap")
    }

    clickSearch() {
        this.client.clickAt("search")
    }

    travel() {
        this.client.sendKey("h")
    }

    getDestination(showAccounts := false) {
        if (!showAccounts && this.destination != "") {
            return this.destination
        }

        allDests := this.travelHistory.getAll()
        hasHistory := allDests.Length > 0
        state := { result: "", done: false }

        myGui := Gui("+AlwaysOnTop", "ZapNavigator - Destino")
        myGui.SetFont("s10")
        myGui.Add("Text", "Section w300", "Selecione ou digite o destino:")

        if (hasHistory) {
            myGui.Add("ListBox", "vSelectedDestination w300 h150", allDests)
        }

        myGui.Add("Edit", "vNewDestination w300")

        if (showAccounts) {
            rightColX := 330
            myGui.Add("Text", "x" rightColX " ys w150", "Contas:")
            for accountName, windowName in this.account.account {
                isOpen := this.client.windowExists(windowName)
                if (this.selectedAccounts.Length = 0) {
                    isChecked := isOpen
                } else {
                    isChecked := false
                    for _, name in this.selectedAccounts {
                        if (name = accountName) {
                            isChecked := isOpen
                            break
                        }
                    }
                }
                opts := "xp yp+20 w150 v__cb_" accountName
                if (!isOpen)
                    opts .= " Disabled"
                if (isChecked)
                    opts .= " Checked"
                myGui.Add("CheckBox", opts, accountName)
            }
        }

        OnOK(*) {
            newDest := Trim(myGui["NewDestination"].Value)
            if (newDest != "") {
                state.result := newDest
            } else if (hasHistory) {
                try {
                    state.result := myGui["SelectedDestination"].Text
                }
            }
            if (showAccounts) {
                selected := []
                for accountName, _ in this.account.account {
                    if (myGui["__cb_" accountName].Value)
                        selected.Push(accountName)
                }
                this.selectedAccounts := selected
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
            this.travelHistory.add(state.result)
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
                this.client.sleep()
                this.client.clearInput()
                this.client.sleep()
                this.client.sendText(this.destination)
                this.client.sleep()
                this.client.confirm()
                break
            } else if (isTravelOpen) {
                this.clickZap()
            } else {
                this.travel()
                this.client.sleep(500)
            }

            this.client.sleep()
        }

        this.running := false
        return true
    }

    useAll() {
        priorWindow := WinExist("A")
        openAccounts := this.account.getOpenAccounts()

        if (openAccounts.Length = 0) {
            return
        }

        dest := this.getDestination(true)
        if (dest = "" || this.selectedAccounts.Length = 0) {
            this.destination := ""
            return
        }

        for accountName in this.selectedAccounts {
            windowName := this.account.account.Get(accountName)
            if (!this.client.windowExists(windowName))
                continue
            this.account.focus(accountName)
            Sleep(SLEEP_TIME)

            if (!this.use(false)) {
                this.destination := ""
                return
            }
        }

        this.destination := ""
        WinActivate(priorWindow)

        Sleep(SLEEP_TIME)
        this.client.allowAllyToFollowLeader()
    }

    stop() {
        this.running := false
    }
}
