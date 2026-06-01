#Requires AutoHotkey v2.0

class AccountManager {
    __New(accounts, client) {
        this.client := client
        this.account := Map()
        this.mainCharacter := ""
        for entry in accounts {
            this.account[entry["name"]] := entry["windowName"]
            if entry.Has("main") && entry["main"]
                this.mainCharacter := entry["name"]
        }
        this._registerHotkeys()
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

    focusByIndex(n, *) {
        open := this.sortByWindowOrder(this.getOpenAccounts())
        if n > open.Length
            return
        this.focus(open[n])
    }

    sortByWindowOrder(accounts) {
        allWindows := WinGetList()
        zOrder := Map()
        for idx, hwnd in allWindows {
            zOrder[hwnd] := idx
        }

        entries := []
        for accountName in accounts {
            windowName := this.account.Get(accountName)
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

    _registerHotkeys() {
        loop this.account.Count {
            n := A_Index
            Hotkey("$#" n, ObjBindMethod(this, "focusByIndex", n))
        }
    }
}
