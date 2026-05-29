#Requires AutoHotkey v2.0

class GuiTheme {
    ; Paleta dark fantasy / âmbar
    static BG_DARK    := 0x1A1510
    static BG_CONTROL := 0x2B2218
    static FG_TEXT    := 0xE8D5A3
    static FG_DIM     := 0x8A7355
    static ACCENT     := 0xC89B3C
    static BG_BUTTON  := 0x3D2E1A
    static FONT_NAME  := "Segoe UI"
    static FONT_SIZE  := 10

    ; Estado interno
    static _registered := false
    static _darkBrush  := 0
    static _ctrlBrush  := 0
    static _btnBrush   := 0
    static _cb         := 0

    ; Aplica tema na janela: fundo, fonte e registra WM_CTLCOLOR* (uma única vez)
    static Apply(gui) {
        gui.BackColor := Format("{:06X}", GuiTheme.BG_DARK)
        gui.SetFont(
            "s" GuiTheme.FONT_SIZE " c" Format("{:06X}", GuiTheme.FG_TEXT),
            GuiTheme.FONT_NAME
        )
        if (!GuiTheme._registered) {
            GuiTheme._cb := ObjBindMethod(GuiTheme, "_OnCtlColor")
            OnMessage(0x0133, GuiTheme._cb)  ; WM_CTLCOLOREDIT
            OnMessage(0x0134, GuiTheme._cb)  ; WM_CTLCOLORLISTBOX
            OnMessage(0x0135, GuiTheme._cb)  ; WM_CTLCOLORBTN
            OnMessage(0x0138, GuiTheme._cb)  ; WM_CTLCOLORSTATIC
            GuiTheme._registered := true
        }
    }

    ; Converte 0xRRGGBB (AHK) para 0x00BBGGRR (Win32 COLORREF)
    static _ToCOLORREF(rgb) {
        r := (rgb >> 16) & 0xFF
        g := (rgb >> 8) & 0xFF
        b := rgb & 0xFF
        return (b << 16) | (g << 8) | r
    }

    static _GetDarkBrush() {
        if (!GuiTheme._darkBrush)
            GuiTheme._darkBrush := DllCall("gdi32\CreateSolidBrush",
                "UInt", GuiTheme._ToCOLORREF(GuiTheme.BG_DARK), "Ptr")
        return GuiTheme._darkBrush
    }

    static _GetCtrlBrush() {
        if (!GuiTheme._ctrlBrush)
            GuiTheme._ctrlBrush := DllCall("gdi32\CreateSolidBrush",
                "UInt", GuiTheme._ToCOLORREF(GuiTheme.BG_CONTROL), "Ptr")
        return GuiTheme._ctrlBrush
    }

    static _GetBtnBrush() {
        if (!GuiTheme._btnBrush)
            GuiTheme._btnBrush := DllCall("gdi32\CreateSolidBrush",
                "UInt", GuiTheme._ToCOLORREF(GuiTheme.BG_BUTTON), "Ptr")
        return GuiTheme._btnBrush
    }

    ; Handler Win32: chamado pelo Windows ao renderizar cada controle
    static _OnCtlColor(wParam, lParam, msg, hwnd) {
        hdc := wParam

        if (msg = 0x0133 || msg = 0x0134) {  ; Edit ou ListBox
            DllCall("gdi32\SetTextColor", "Ptr", hdc,
                "UInt", GuiTheme._ToCOLORREF(GuiTheme.FG_TEXT))
            DllCall("gdi32\SetBkColor", "Ptr", hdc,
                "UInt", GuiTheme._ToCOLORREF(GuiTheme.BG_CONTROL))
            return GuiTheme._GetCtrlBrush()
        }

        if (msg = 0x0135) {  ; Button
            DllCall("gdi32\SetTextColor", "Ptr", hdc,
                "UInt", GuiTheme._ToCOLORREF(GuiTheme.FG_TEXT))
            DllCall("gdi32\SetBkColor", "Ptr", hdc,
                "UInt", GuiTheme._ToCOLORREF(GuiTheme.BG_BUTTON))
            return GuiTheme._GetBtnBrush()
        }

        if (msg = 0x0138) {  ; CheckBox, GroupBox, Text (Static)
            isEnabled := DllCall("user32\IsWindowEnabled", "Ptr", lParam, "Int")
            textColor := isEnabled ? GuiTheme.FG_TEXT : GuiTheme.FG_DIM
            DllCall("gdi32\SetTextColor", "Ptr", hdc,
                "UInt", GuiTheme._ToCOLORREF(textColor))
            DllCall("gdi32\SetBkColor", "Ptr", hdc,
                "UInt", GuiTheme._ToCOLORREF(GuiTheme.BG_DARK))
            return GuiTheme._GetDarkBrush()
        }

        return ""
    }
}
