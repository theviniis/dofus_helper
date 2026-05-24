#Requires AutoHotkey v2.0

class TradeManager {
    __New(tradeConfig, client, account) {
        this.tradeConfig := tradeConfig
        this.client      := client
        this.account     := account
    }

    run() {
    }

    _proposeTrade(receiverName) {
        this.account.focus(receiverName)
        this.client.sleep()

        srcClick := this.tradeConfig["sourceCharacter"]["click"]
        Click(srcClick[1], srcClick[2])
        this.client.sleep()

        offset   := this.tradeConfig["proposeMenuOffset"]
        proposeX := srcClick[1] + offset[1]
        proposeY := srcClick[2] + offset[2]
        Click(proposeX, proposeY)
        this.client.sleep()
    }

    _acceptTrade(sourceName) {
        return false
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
