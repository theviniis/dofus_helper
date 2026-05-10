#Requires AutoHotkey v2.0
#Include does_pixel_matches.ahk

class ZapNavigator {
    __New(travelersBagConfig) {
        this.travelersBagConfig := travelersBagConfig
        this.running := false
        this.destination := ""
    }

    isOnTravelScreen {
        get {
            return doesPixelMatches(
                this.travelersBagConfig.zap.detect.pos[1],
                this.travelersBagConfig.zap.detect.pos[2],
                this.travelersBagConfig.zap.detect.color,
            )
        }
    }

    isZapInterfaceOpen {
        get {
            return doesPixelMatches(
                this.travelersBagConfig.interfaceZap.detect.pos[1],
                this.travelersBagConfig.interfaceZap.detect.pos[2],
                this.travelersBagConfig.interfaceZap.detect.color,
            )
        }
    }

    clickZap() {
        Click(
            this.travelersBagConfig.zap.click[1],
            this.travelersBagConfig.zap.click[2],
        )
    }

    clickSearch() {
        Click(
            this.travelersBagConfig.barraBusca.click[1],
            this.travelersBagConfig.barraBusca.click[2],
        )
    }

    travel() {
        Send("h")
    }

    getDestination() {
        if (this.destination != "") {
            return this.destination
        }
        destination := InputBox(
            "Para onde deseja viajar?",
            "Destino",
        )
        if (destination.result = "OK" and destination.value != "") {
            this.destination := destination.value
            return this.destination
        }
        return ""
    }

    use() {
        this.running := true
        destination := this.getDestination()

        while (this.running) {
            isZapOpen := this.isZapInterfaceOpen
            isTravelOpen := this.isOnTravelScreen

            if (isZapOpen) {
                this.clickSearch()
                if (destination != "") {
                    Sleep(300)
                    Send(destination)
                    Sleep(300)
                    Send("{Enter}")
                }
                break
            }
            else if (isTravelOpen) {
                this.clickZap()
            }
            else {
                this.travel()
            }

            Sleep(500)
        }

        this.running := false
    }

    stop() {
        this.running := false
    }
}
