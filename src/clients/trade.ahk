#Requires AutoHotkey v2.0

class TradeManager {
    __New(tradeConfig, client, account) {
        this.tradeConfig := tradeConfig
        this.client      := client
        this.account     := account
    }

    run() {
        sourceId   := WinExist("A")
        sourceName := this.account.getAccountByWindow(sourceId)

        if (sourceName = "") {
            this._tip("Erro: janela ativa não é uma conta conhecida")
            return
        }

        openAccounts := this.account.getOpenAccounts()
        receivers := []
        for accountName in openAccounts {
            if (accountName != sourceName)
                receivers.Push(accountName)
        }

        if (receivers.Length = 0) {
            this._tip("Nenhuma conta receptora aberta")
            return
        }

        for receiverName in receivers {
            this._proposeTrade(sourceName, receiverName)

            if (!this._acceptTrade(sourceName)) {
                this.account.focus(sourceName)
                return
            }

            if (!this._waitUserAddItems()) {
                this.account.focus(sourceName)
                return
            }

            if (!this._confirmTrade(sourceName, receiverName)) {
                this.account.focus(sourceName)
                return
            }
        }

        this.account.focus(sourceName)
        this._tip("Trocas concluídas")
    }

    _proposeTrade(sourceName, receiverName) {
        sourceIndex := 0
        for accountName, _ in this.account.account {
            if (accountName = sourceName)
                break
            sourceIndex++
        }

        groupBase := this.tradeConfig["groupBase"]["click"]
        spacing   := this.tradeConfig["groupSpacing"]
        srcX := groupBase[1] + sourceIndex * spacing[1]
        srcY := groupBase[2] + sourceIndex * spacing[2]

        offset := this.tradeConfig["proposeMenuOffset"]

        this.account.focus(receiverName)
        this.client.sleep()
        Click(srcX, srcY)
        this.client.sleep()
        Click(srcX + offset[1], srcY + offset[2])
        this.client.sleep()
    }

    _acceptTrade(sourceName) {
        this.account.focus(sourceName)
        this.client.sleep()

        if (!this.client.waitForPixelDetect(this.tradeConfig["acceptButton"]["detect"], 5000)) {
            this._tip("Erro: proposta de troca não detectada (timeout 5s)")
            return false
        }

        acceptClick := this.tradeConfig["acceptButton"]["click"]
        Click(acceptClick[1], acceptClick[2])
        this.client.sleep()
        return true
    }

    _waitUserAddItems() {
        state := { result: false, done: false }

        myGui := Gui("+AlwaysOnTop", "Troca")
        myGui.SetFont("s10")
        myGui.Add("Text", "x10 y10 w280", "Adicione os itens na troca e clique em Confirmar.")

        OnConfirm(*) {
            state.result := true
            state.done   := true
            myGui.Destroy()
        }

        OnCancel(*) {
            state.result := false
            state.done   := true
            myGui.Destroy()
        }

        OnClose(GuiObj) {
            state.result := false
            state.done   := true
            GuiObj.Destroy()
        }

        myGui.Add("Button", "x10 y40 w80", "Cancelar").OnEvent("Click", OnCancel)
        myGui.Add("Button", "x+10 y40 w80 Default", "Confirmar").OnEvent("Click", OnConfirm)
        myGui.OnEvent("Close", OnClose)
        myGui.Show("w300")

        while !state.done {
            Sleep(50)
        }

        return state.result
    }

    _confirmTrade(sourceName, receiverName) {
        confirmClick  := this.tradeConfig["confirmButton"]["click"]
        confirmDetect := this.tradeConfig["confirmButton"]["detect"]

        this.account.focus(sourceName)
        this.client.sleep()
        if (!this.client.waitForPixelDetect(confirmDetect, 5000)) {
            this._tip("Erro: botão confirmar não detectado (fonte)")
            return false
        }
        Click(confirmClick[1], confirmClick[2])
        this.client.sleep()

        this.account.focus(receiverName)
        this.client.sleep()
        if (!this.client.waitForPixelDetect(confirmDetect, 5000)) {
            this._tip("Erro: botão confirmar não detectado (receptor)")
            return false
        }
        Click(confirmClick[1], confirmClick[2])
        this.client.sleep()
        return true
    }

    _tip(msg) {
        BOTTOM_OFFSET := 130
        tipX := A_ScreenWidth // 2 - 150
        tipY := A_ScreenHeight - BOTTOM_OFFSET
        ToolTip(msg, tipX, tipY)
        if (msg = "")
            return
        SetTimer(() => ToolTip("", tipX, tipY), -2000)
    }
}
