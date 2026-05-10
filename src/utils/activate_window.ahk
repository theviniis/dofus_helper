#Requires AutoHotkey v2.0

activateWindow(windowName) {
    WinWait windowName
    WinActivate windowName
}
