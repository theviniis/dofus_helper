#Requires AutoHotkey v2.0

class ClientInterface {
    __New(config) {
        this.config := config
        this.sleepTime := 200
    }

    focusWindow(windowName?) {
        if (windowName = "") {
            WinActivate("ahk_exe Dofus.exe")
        } else {
            WinActivate(windowName)
        }
    }

    waitWindow(windowName) {
        WinWait(windowName)
    }

    windowExists(windowName) {
        return WinExist(windowName)
    }

    sendText(text) {
        Send(text)
    }

    sendKey(key) {
        Send(key)
    }

    openChat() {
        this.focusWindow()
        Sleep(this.sleepTime)
        Send(" ")
    }

    confirm() {
        Send("{Enter}")
    }

    clickAt(coordName) {
        coord := this.config.sacoDeViagens[coordName]
        Click(coord.click[1], coord.click[2])
    }

    pixelMatches(coordName) {
        detect := this.config.sacoDeViagens[coordName].detect
        pixelColor := PixelGetColor(detect.pos[1], detect.pos[2])
        return pixelColor == detect.color
    }

    sleep(ms?) {
        if (ms = "") {
            ms := this.sleepTime
        }
        Sleep(ms)
    }

    copyWindowName() {
        activeTitle := WinGetTitle("A")
        A_Clipboard := activeTitle
    }

    allowAllyToFollowLeader() {
        Send("{Alt down}z{Alt up}")
    }
}
