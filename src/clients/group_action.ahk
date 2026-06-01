#Requires AutoHotkey v2.0

SLEEP_TIME := 200

class GroupActionManager {
    __New(groupConfig, account, client) {
        this.groupConfig := groupConfig
        this.account := account
        this.client := client
        this.gui := ""
    }

    showGui() {
        openAccounts := this.account.getOpenAccounts()
        orderedAccounts := this.account.sortByWindowOrder(openAccounts)

        myGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
        myGui.SetFont("s9")

        rowH := 30
        btnW := 90
        labelW := 60
        padding := 5

        loop orderedAccounts.Length {
            i := A_Index - 1
            accountName := orderedAccounts[A_Index]
            y := padding + i * rowH

            myGui.Add("Text", "x" padding " y" (y + 6) " w" labelW, accountName)

            xBtn := padding + labelW + 5
            followBtn := myGui.Add("Button", "x" xBtn " y" y " w" btnW, "Seguir líder")
            followBtn.OnEvent("Click", ObjBindMethod(this, "followLeader", i))

            inviteBtn := myGui.Add("Button", "x+5 y" y " w" btnW, "Convidar")
            inviteBtn.OnEvent("Click", ObjBindMethod(this, "invite", i))

            kickBtn := myGui.Add("Button", "x+5 y" y " w" btnW, "Expulsar")
            kickBtn.OnEvent("Click", ObjBindMethod(this, "kick", i))

            tradeBtn := myGui.Add("Button", "x+5 y" y " w" btnW, "Propor troca")
            tradeBtn.OnEvent("Click", ObjBindMethod(this, "proposeTrade", i))
        }

        guiX := this.groupConfig["gui"]["x"]
        guiY := this.groupConfig["gui"]["y"]
        myGui.Show("x" guiX " y" guiY " NoActivate")
        this.gui := myGui
    }

    followLeader(i, *) {
        this._performAction(i, "followLeader")
    }

    invite(i, *) {
        this._performAction(i, "invite")
    }

    kick(i, *) {
        this._performAction(i, "kick")
    }

    proposeTrade(i, *) {
        this._performAction(i, "proposeTrade")
    }

    _performAction(i, action) {
        portraitX := this.groupConfig["firstPos"][1] + i * this.groupConfig["offsetX"]
        portraitY := this.groupConfig["firstPos"][2]
        this.clickPortrait(portraitX, portraitY)
        if (!this.waitForMenu(portraitX, portraitY))
            return
        this.clickMenuOption(portraitX, portraitY, action)
    }

    clickPortrait(portraitX, portraitY) {
        this.client.rightClickAt(portraitX, portraitY)
    }

    waitForMenu(portraitX, portraitY) {
        detect := this.groupConfig["menu"]["detect"]
        checkX := portraitX + detect["offsetPos"][1]
        checkY := portraitY + detect["offsetPos"][2]
        color := detect["color"]
        deadline := A_TickCount + 500
        while (A_TickCount < deadline) {
            if (PixelGetColor(checkX, checkY) == color)
                return true
            Sleep(SLEEP_TIME)
        }
        return false
    }

    clickMenuOption(portraitX, portraitY, action) {
        menu := this.groupConfig["menu"]
        optX := portraitX + menu["offsetX"]
        optY := portraitY + menu[action]["offsetY"]
        Click(optX, optY)
    }
}
