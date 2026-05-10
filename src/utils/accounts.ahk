#Requires AutoHotkey v2.0

class Accounts {
    __New(accountList) {
        this.accountList := accountList
    }

    focus(accountName) {

        windowName := this.accountList.Get(accountName)
        ToolTip(accountName . '  ' . windowName)
        WinWait(windowName)
        WinActivate(windowName)
    }
}
