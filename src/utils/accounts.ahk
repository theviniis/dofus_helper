#Requires AutoHotkey v2.0

class AccountManager {
    __New(accountList) {
        this.accountList := accountList
    }

    focus(accountName) {
        windowName := this.accountList.Get(accountName)
        WinWait(windowName)
        WinActivate(windowName)
    }

    getOpenAccounts() {
        openAccounts := []
        for accountName, windowName in this.accountList {
            if WinExist(windowName) {
                openAccounts.Push(accountName)
            }
        }
        return openAccounts
    }
}
