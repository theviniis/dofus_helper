#Requires AutoHotkey v2.0

sendTooltip(text, timeout := 250) {
    ToolTip(text)
    Sleep(timeout)
    ToolTip("")
}
