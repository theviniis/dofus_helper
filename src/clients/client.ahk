#Requires AutoHotkey v2.0

class ClientInterface {
    __New(config) {
        this.config := config
    }

    focusWindow(windowName?) {
        if (!IsSet(windowName) or windowName = "") {
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
        Sleep(SLEEP_TIME)
        Send(" ")
    }

    confirm() {
        Send("{Enter}")
    }

    clickAt(coordName) {
        coord := this.config["travelersBag"][coordName]
        Click(coord['click'][1], coord['click'][2])
    }

    pixelMatches(coordName) {
        detect := this.config["travelersBag"][coordName]['detect']
        return this.pixelMatchesDetect(detect)
    }

    pixelMatchesDetect(detect) {
        pixelColor := PixelGetColor(detect['pos'][1], detect['pos'][2])
        return pixelColor == detect['color']
    }

    waitForPixelDetect(detect, timeoutMs := 5000) {
        deadline := A_TickCount + timeoutMs
        while A_TickCount < deadline {
            if this.pixelMatchesDetect(detect)
                return true
            Sleep(100)
        }
        return false
    }

    clearInput() {
        Send("^a")
        this.sleep()
        Send("{Backspace}")
    }

    sleep(ms := SLEEP_TIME) {
        Sleep(ms)
    }

    copyWindowName() {
        activeTitle := WinGetTitle("A")
        A_Clipboard := activeTitle
    }

    allowAllyToFollowLeader() {
        Send("^z")
    }
}
