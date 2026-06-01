#Requires AutoHotkey v2.0
#Include ../clients/client.ahk
#Include ../clients/travel_history.ahk
#Include ../clients/zap.ahk
#Include ../clients/account.ahk
#Include ../clients/travel.ahk
#Include ../clients/macro_broadcaster.ahk
#Include ../clients/group.ahk

class Init {
    __New(config, mainCharacter) {
        this.client    := ClientInterface(config)
        this.account   := AccountManager(config["accounts"], this.client)
        this.zap       := ZapNavigator(config["travelersBag"], this.client, TravelHistory(), this.account)
        this.travel    := TravelNavigator(this.client, this.account, mainCharacter)
        this.macro     := MacroBroadcaster(this.account, this.client)
        this.group     := GroupManager(config["group"], this.account, this.client)
    }
}
