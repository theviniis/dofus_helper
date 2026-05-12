#Requires AutoHotkey v2.0

class AccountManager {
    __New(account, client) {
        this.account := account
        this.client := client
    }

    focus(accountName) {
        windowName := this.account.Get(accountName)
        this.client.waitWindow(windowName)
        this.client.focusWindow(windowName)
    }

    getOpenAccounts() {
        openAccounts := []
        for accountName, windowName in this.account {
            if this.client.windowExists(windowName) {
                openAccounts.Push(accountName)
            }
        }
        return openAccounts
    }

    getAccountByWindow(windowId) {
        for accountName, windowName in this.account {
            if WinExist(windowName) = windowId {
                return accountName
            }
        }
        return ""
    }
}
