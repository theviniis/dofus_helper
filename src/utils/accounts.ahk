#Requires AutoHotkey v2.0

class AccountManager {
    __New(accountList, clientIF) {
        this.accountList := accountList
        this.clientIF := clientIF
    }

    focus(accountName) {
        windowName := this.accountList.Get(accountName)
        this.clientIF.waitWindow(windowName)
        this.clientIF.focusWindow(windowName)
    }

    getOpenAccounts() {
        openAccounts := []
        for accountName, windowName in this.accountList {
            if this.clientIF.windowExists(windowName) {
                openAccounts.Push(accountName)
            }
        }
        return openAccounts
    }

    getAccountByWindow(windowId) {
        for accountName, windowName in this.accountList {
            if WinExist(windowName) = windowId {
                return accountName
            }
        }
        return ""
    }
}