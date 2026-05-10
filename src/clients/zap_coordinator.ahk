#Requires AutoHotkey v2.0

class ZapCoordinator {
    __New(zapNav, accountMgr) {
        this.zapNav := zapNav
        this.accountMgr := accountMgr
    }

    runAll() {
        priorWindow := WinExist("A")
        openAccounts := this.accountMgr.getOpenAccounts()

        if (openAccounts.Length = 0) {
            return
        }

        activeAccount := this.accountMgr.getAccountByWindow(priorWindow)
        if (activeAccount != "") {
            for i, name in openAccounts {
                if (name = activeAccount) {
                    openAccounts.RemoveAt(i)
                    openAccounts.InsertAt(1, activeAccount)
                    break
                }
            }
        }

        this.zapNav.destination := ""

        for accountName in openAccounts {
            this.accountMgr.focus(accountName)
            Sleep(200)

            if (!this.zapNav.use(false)) {
                return
            }
        }

        this.zapNav.destination := ""
        WinActivate(priorWindow)
    }
}
