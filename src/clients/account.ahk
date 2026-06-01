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

    focus(index, accountName?) {
        if Type(index) = "String" {
            sorted := this.sortByWindowOrder(this.getOpenAccounts())
            for idx, name in sorted {
                if (name = index) {
                    index := idx
                    break
                }
            }
        }

        if Type(index) != "Integer"
            return

        hwnds := WinGetList("ahk_exe Dofus.exe")
        n := hwnds.Length
        loop n - 1 {
            i := A_Index
            loop n - i {
                j := A_Index
                if (hwnds[j] > hwnds[j + 1]) {
                    tmp := hwnds[j]
                    hwnds[j] := hwnds[j + 1]
                    hwnds[j + 1] := tmp
                }
            }
        }

        if index <= hwnds.Length
            WinActivate(hwnds[index])
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

    getIndex(accountName) {
        sorted := this.sortByWindowOrder(this.getOpenAccounts())
        for idx, name in sorted {
            if (name = accountName)
                return idx
        }
        return 0
    }

    focusByIndex(n, *) {
        this.focus(n)
    }

    sortByWindowOrder(accounts) {
        entries := []
        for accountName in accounts {
            windowName := this.account.Get(accountName)
            hwnd := WinExist(windowName)
            ; Lower HWND = window created first (launch order)
            pos := hwnd ? hwnd : 0xFFFFFFFF
            entries.Push({ name: accountName, pos: pos })
        }

        ; Ascending by pos: lower HWND = opened earlier = first
        n := entries.Length
        loop n - 1 {
            i := A_Index
            loop n - i {
                j := A_Index
                if (entries[j].pos > entries[j + 1].pos) {
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
