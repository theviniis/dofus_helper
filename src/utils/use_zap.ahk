#Requires AutoHotkey v2.0

class ZapNavigator {
    __New(travelersBagConfig, clientIF) {
        this.travelersBagConfig := travelersBagConfig
        this.clientIF := clientIF
        this.running := false
        this.destination := ""
    }

    isOnTravelScreen {
        get {
            return this.clientIF.pixelMatches("zap")
        }
    }

    isZapInterfaceOpen {
        get {
            return this.clientIF.pixelMatches("interfaceZap")
        }
    }

    clickZap() {
        this.clientIF.clickAt("zap")
    }

    clickSearch() {
        this.clientIF.clickAt("search")
    }

    travel() {
        this.clientIF.sendKey("h")
    }

    use(forceInput := true) {
        if (this.destination = "" || forceInput) {
            destination := InputBox(
                "Para onde deseja viajar?",
                "Destino",
            )
            if (destination.result != "OK" or destination.value = "") {
                return false
            }
            this.destination := destination.value
        }

        this.running := true

        while (this.running) {
            isZapOpen := this.isZapInterfaceOpen
            isTravelOpen := this.isOnTravelScreen

            if (isZapOpen) {
                this.clickSearch()
                this.clientIF.sleep()
                this.clientIF.sendText(this.destination)
                this.clientIF.sleep()
                this.clientIF.confirm()
                break
            }
            else if (isTravelOpen) {
                this.clickZap()
            }
            else {
                this.travel()
            }

            this.clientIF.sleep()
        }

        this.running := false
        return true
    }

    stop() {
        this.running := false
    }
}