#Requires AutoHotkey v2.0

SLEEP_TIME := 200

class ClientInterface {
    focusWindow() {
        WinActivate("ahk_exe Dofus.exe")
    }

    openChat() {
        this.focusWindow()
        Sleep(SLEEP_TIME)
        Send(" ")
    }

    sendText(text) {
        Send(text)
    }

    confirm() {
        Send("{Enter}")
    }
}