#Requires AutoHotkey v2.0

class GroupActionManager {
    __New(groupConfig, account, client) {
        this.groupConfig := groupConfig
        this.account := account
        this.client := client
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
    }

    followLeader(i, *) {
        portraitX := this.groupConfig["firstPos"][1] + i * this.groupConfig["offsetX"]
        portraitY := this.groupConfig["firstPos"][2]
        this.clickPortrait(portraitX, portraitY)
        if (!this.waitForMenu(portraitX, portraitY))
            return
        this.clickMenuOption(portraitX, portraitY, "followLeader")
    }

    invite(i, *) {
        portraitX := this.groupConfig["firstPos"][1] + i * this.groupConfig["offsetX"]
        portraitY := this.groupConfig["firstPos"][2]
        this.clickPortrait(portraitX, portraitY)
        if (!this.waitForMenu(portraitX, portraitY))
            return
        this.clickMenuOption(portraitX, portraitY, "invite")
    }

    kick(i, *) {
        portraitX := this.groupConfig["firstPos"][1] + i * this.groupConfig["offsetX"]
        portraitY := this.groupConfig["firstPos"][2]
        this.clickPortrait(portraitX, portraitY)
        if (!this.waitForMenu(portraitX, portraitY))
            return
        this.clickMenuOption(portraitX, portraitY, "kick")
    }

    proposeTrade(i, *) {
        portraitX := this.groupConfig["firstPos"][1] + i * this.groupConfig["offsetX"]
        portraitY := this.groupConfig["firstPos"][2]
        this.clickPortrait(portraitX, portraitY)
        if (!this.waitForMenu(portraitX, portraitY))
            return
        this.clickMenuOption(portraitX, portraitY, "proposeTrade")
    }

    clickPortrait(portraitX, portraitY) {
        MouseClick("Right", portraitX, portraitY)
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
