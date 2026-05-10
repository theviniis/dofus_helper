#Requires AutoHotkey v2.0

copyWindowName() {
    activeTitle := WinGetTitle("A")
    A_Clipboard := activeTitle
}
