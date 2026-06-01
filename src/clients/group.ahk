#Requires AutoHotkey v2.0

class GroupManager {
    __New(groupConfig, account, client) {
        this.groupConfig := groupConfig
        this.account := account
        this.client := client
        this.overlayGui := ""
    }

    toggleOverlay() {
        if (this.overlayGui != "") {
            this.overlayGui.Destroy()
            this.overlayGui := ""
            return
        }

        this.overlayGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
        this.overlayGui.BackColor := "000000"

        openAccounts := this.account.getOpenAccounts()
        orderedAccounts := this.account.sortByWindowOrder(openAccounts)

        loop orderedAccounts.Length {
            pos := this.getCharacterPos(A_Index - 1)
            this.overlayGui.Add("Progress", "x" pos[1] " y" pos[2] " w20 h20 cFF0000 Background000000 Range0-100", 100)
        }

        this.overlayGui.Show("x0 y0 w" A_ScreenWidth " h" A_ScreenHeight " NoActivate")
        WinSetTransColor("000000", "ahk_id " this.overlayGui.Hwnd)
    }

    getCharacterPos(i) {
        firstPos := this.groupConfig["firstPos"]
        offsetX := this.groupConfig["offsetX"]
        return [firstPos[1] + i * offsetX, firstPos[2]]
    }
}
