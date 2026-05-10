#Requires AutoHotkey v2.0
#Include go_to_travel.ahk
#Include when_pixel_matches.ahk

class ZapNavigator {
    __New(config) {
        this.config := config
        this.running := false
    }

    isOnTravelScreen {
        get {
            return whenPixelMatches(
                this.config.sacoDeViagens.zap.detect.pos[1],
                this.config.sacoDeViagens.zap.detect.pos[2],
                this.config.sacoDeViagens.zap.detect.color,
            )
        }
    }

    isZapInterfaceOpen {
        get {
            return whenPixelMatches(
                this.config.sacoDeViagens.interfaceZap.detect.pos[1],
                this.config.sacoDeViagens.interfaceZap.detect.pos[2],
                this.config.sacoDeViagens.interfaceZap.detect.color,
            )
        }
    }

    clickZap() {
        Click(
            this.config.sacoDeViagens.zap.click[1],
            this.config.sacoDeViagens.zap.click[2],
        )
    }

    clickSearch() {
        Click(
            this.config.sacoDeViagens.barraBusca.click[1],
            this.config.sacoDeViagens.barraBusca.click[2],
        )
    }

    travel() {
        Send("h")
    }

    getDestination() {
        destination := InputBox(
            "Para onde deseja viajar?",
            "Destino",
            ,
            ,
            ,
            ,
            ,
            ,
            ""
        )
        if (destination.result = "OK" and destination.value != "") {
            return destination.value
        }
        return ""
    }

    use() {
        this.running := true

        while (this.running) {
            isZapOpen := this.isZapInterfaceOpen
            isTravelOpen := this.isOnTravelScreen

            if (isZapOpen) {
                destination := this.getDestination()
                this.clickSearch()
                if (destination != "") {
                    Sleep(300)
                    Send(destination)
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
