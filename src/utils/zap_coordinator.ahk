#Requires AutoHotkey v2.0

class ZapCoordinator {
    __New(zapNav, accountMgr) {
        this.zapNav := zapNav
        this.accountMgr := accountMgr
    }

    runAll() {
        openAccounts := this.accountMgr.getOpenAccounts()

        if (openAccounts.Length = 0) {
            return
        }

        for accountName in openAccounts {
            this.accountMgr.focus(accountName)
            Sleep(200)

            if (!this.zapNav.use()) {
                return
            }
        }
    }
}
