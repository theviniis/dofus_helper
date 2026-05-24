#Requires AutoHotkey v2.0

class TradeManager {
    __New(tradeConfig, client, account) {
        this.tradeConfig := tradeConfig
        this.client      := client
        this.account     := account
    }

    run() {
    }

    _proposeTrade(receiverName) {
    }

    _acceptTrade(sourceName) {
        return false
    }

    _waitUserAddItems() {
        return false
    }

    _confirmTrade(sourceName, receiverName) {
    }

    _tip(msg) {
    }
}
