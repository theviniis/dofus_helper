#Requires AutoHotkey v2.0

SLEEP_TIME := 250

class ZapCoordinator {
    __New(zapNav, accountMgr, clientIF) {
        this.zapNav := zapNav
        this.accountMgr := accountMgr
        this.clientIF := clientIF
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
            Sleep(SLEEP_TIME)

            if (!this.zapNav.use(false)) {
                return
            }
        }

        this.zapNav.destination := ""
        WinActivate(priorWindow)

        Sleep(SLEEP_TIME)
        this.clientIF.allowAllyToFollowLeader()

    }
}
