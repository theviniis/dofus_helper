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
        currentIndex := 0
        hotkeysCleanedUp := false

        ; Layout constants (s10 font, 96 DPI)
        gbX := 10, gbW := 320, innerX := 20, innerW := 300
        gbTitleH := 20  ; height of GroupBox title area

        ; GroupBox "Destino"
        destGbH := hasHistory ? 252 : 80
        myGui := Gui("+AlwaysOnTop", "ZapNavigator - Destino")
        myGui.SetFont("s10")
        myGui.Add("GroupBox", "x" gbX " ym w" gbW " h" destGbH, "Destino")
        myGui.Add("Text", "x" innerX " y30 w" innerW, "Selecione ou digite o destino:")
        if (hasHistory) {
            myGui.Add("ListBox", "x" innerX " y50 vSelectedDestination w" innerW " h167", allDests)
            myGui["SelectedDestination"].OnEvent("Change", OnListboxChange)
            myGui.Add("Edit", "-E0x200 x" innerX " y225 vNewDestination w" innerW)
        } else {
            myGui.Add("Edit", "-E0x200 x" innerX " y50 vNewDestination w" innerW)
        }

        ; GroupBox "Contas"
        btnY := 10 + destGbH + 8
        if (showAccounts) {
            contasGbY := btnY
            contasGbH := 48
            myGui.Add("GroupBox", "x" gbX " y" contasGbY " w" gbW " h" contasGbH, "Contas")
            checkY := contasGbY + gbTitleH + 4
            firstCheckbox := true
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
                opts := (firstCheckbox ? "x" innerX : "x+15") " y" checkY " v__cb_" accountName
                if (!isOpen)
                    opts .= " Disabled"
                if (isChecked)
                    opts .= " Checked"
                myGui.Add("CheckBox", opts, accountName)
                firstCheckbox := false
            }
            btnY := contasGbY + contasGbH + 8
        }

        NavUp(*) {
            if (ControlGetFocus("A") != myGui["NewDestination"].Hwnd)
                return
            if (currentIndex = 0)
                currentIndex := 1
            else if (currentIndex = 1)
                currentIndex := allDests.Length
            else
                currentIndex--
            myGui["SelectedDestination"].Choose(currentIndex)
            myGui["NewDestination"].Value := allDests[currentIndex]
            myGui["NewDestination"].Focus()
        }

        NavDown(*) {
            if (ControlGetFocus("A") != myGui["NewDestination"].Hwnd)
                return
            if (currentIndex = 0 || currentIndex = allDests.Length)
                currentIndex := 1
            else
                currentIndex++
            myGui["SelectedDestination"].Choose(currentIndex)
            myGui["NewDestination"].Value := allDests[currentIndex]
            myGui["NewDestination"].Focus()
        }

        CleanupHotkeys() {
            if (hotkeysCleanedUp)
                return
            hotkeysCleanedUp := true
            HotIfWinActive("ZapNavigator - Destino")
            try HotKey("Up", NavUp, "Off")
            try HotKey("Down", NavDown, "Off")
            HotIfWinActive()
        }

        OnListboxChange(*) {
            selected := myGui["SelectedDestination"].Text
            loop allDests.Length {
                if (allDests[A_Index] = selected) {
                    currentIndex := A_Index
                    break
                }
            }
            myGui["NewDestination"].Value := selected
            myGui["NewDestination"].Focus()
        }

        OnOK(*) {
            CleanupHotkeys()
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
            CleanupHotkeys()
            state.done := true
            myGui.Destroy()
        }

        OnClose(GuiObj) {
            CleanupHotkeys()
            state.done := true
            GuiObj.Destroy()
        }

        myGui.Add("Button", "x" gbX " y" btnY " w80", "Cancel").OnEvent("Click", OnCancel)
        myGui.Add("Button", "x+10 y" btnY " w80 Default", "OK").OnEvent("Click", OnOK)
        myGui.OnEvent("Close", OnClose)
        if (hasHistory) {
            HotIfWinActive("ZapNavigator - Destino")
            HotKey("Up", NavUp)
            HotKey("Down", NavDown)
            HotIfWinActive()
        }
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

        orderedAccounts := this.account.sortByWindowOrder(this.selectedAccounts)

        for accountName in orderedAccounts {
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
