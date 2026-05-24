#Requires AutoHotkey v2.0
#Include ../clients/client.ahk
#Include ../clients/travel_history.ahk
#Include ../clients/zap.ahk
#Include ../clients/account.ahk
#Include ../clients/travel.ahk
#Include ../clients/macro_broadcaster.ahk
#Include ../clients/trade.ahk

class Init {
    __New(config) {
        this.client    := ClientInterface(config)
        this.account   := AccountManager(config["accounts"], this.client)
        this.zap       := ZapNavigator(config["travelersBag"], this.client, TravelHistory(), this.account)
        this.travel    := TravelNavigator(this.client)
        this.macro     := MacroBroadcaster(this.account, this.client)
        this.trade     := TradeManager(config["trade"], this.client, this.account)
    }
}
