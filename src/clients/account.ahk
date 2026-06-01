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

    getAll() {
        return this.accounts
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

    sortByWindowOrder(accounts) {
        allWindows := WinGetList()
        zOrder := Map()
        for idx, hwnd in allWindows {
            zOrder[hwnd] := idx
        }

        entries := []
        for accountName in accounts {
            windowName := this.getWindowName(accountName)
            hwnd := WinExist(windowName)
            pos := (hwnd && zOrder.Has(hwnd)) ? zOrder[hwnd] : 0
            entries.Push({ name: accountName, pos: pos })
        }

        ; Descending by pos: higher idx = lower in Z-stack = opened first
        n := entries.Length
        loop n - 1 {
            i := A_Index
            loop n - i {
                j := A_Index
                if (entries[j].pos < entries[j + 1].pos) {
                    temp := entries[j]
                    entries[j] := entries[j + 1]
                    entries[j + 1] := temp
                }
            }
        }

        sorted := []
        for entry in entries {
            sorted.Push(entry.name)
        }
        return sorted
    }
}
