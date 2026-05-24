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
        BOTTOM_OFFSET := 130
        tipX := A_ScreenWidth // 2 - 150
        tipY := A_ScreenHeight - BOTTOM_OFFSET
        ToolTip(msg, tipX, tipY)
        if (msg = "")
            return
        SetTimer(() => ToolTip("", tipX, tipY), -2000)
    }
}
