#Requires AutoHotkey v2.0

debugArray(arr) {
    text := ""

    for key, value in arr {
        text .= key ": " value "`n"
    }

    ToolTip(text)
    Sleep(10000)
    ToolTip("")
}
