#Requires AutoHotkey v2.0

class ClientInterface {
    focusWindow() {
        WinActivate("ahk_exe Dofus.exe")
    }

    openChat() {
        this.focusWindow()
        Sleep(200)
        Send(" ")
    }

    sendText(text) {
        Send(text)
    }

    confirm() {
        Send("{Enter}")
    }
}