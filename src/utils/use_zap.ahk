#Requires AutoHotkey v2.0
#Include does_pixel_matches.ahk

SLEEP_TIME := 500
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

    use() {
        if (this.destination = "") {
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
                Sleep(SLEEP_TIME)
                Send(this.destination)
                Sleep(SLEEP_TIME)
                Send("{Enter}")
                break
            }
            else if (isTravelOpen) {
                this.clickZap()
            }
            else {
                this.travel()
            }

            Sleep(SLEEP_TIME)
        }

        this.running := false
        return true
    }

    stop() {
        this.running := false
    }
}
