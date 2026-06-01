#Requires AutoHotkey v2.0

class AccountManager {
    __New(accounts, client) {
        this.accounts := accounts
        this.client := client
    }

    getWindowName(accountName) {
        for item in this.accounts {
            if item["name"] = accountName {
                return item["windowName"]
            }
        }
        return ""
    }

    focus(accountName) {
        windowName := this.getWindowName(accountName)
        this.client.waitWindow(windowName)
        this.client.focusWindow(windowName)
    }

    getOpenAccounts() {
        openAccounts := []
        for item in this.accounts {
            if this.client.windowExists(item["windowName"]) {
                openAccounts.Push(item["name"])
            }
        }
        return openAccounts
    }

    getAccountByWindow(windowId) {
        for item in this.accounts {
            if this.client.windowExists(item["windowName"]) = windowId {
                return item["name"]
            }
        }
        return ""
    }
}
