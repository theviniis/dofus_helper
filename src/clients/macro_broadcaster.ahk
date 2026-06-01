#Requires AutoHotkey v2.0

; MacroBroadcaster — Grava entradas de teclado e mouse enquanto F9 está ativo
; e replica a sequência em todas as contas abertas ao parar a gravação.

class MacroBroadcaster {
    recording := false
    actions := []
    lastTime := 0
    originWindowId := 0   ; ID da janela ativa quando a gravação foi iniciada

    __New(accountMgr, client) {
        this.accountMgr := accountMgr
        this.client := client
    }

    ; ─── API pública ────────────────────────────────────────────────────────

    ; Alterna entre iniciar e parar a gravação
    toggle() {
        if (this.recording) {
            this.client.allowAllyToFollowLeader()
            this.client.sleep()
            this.stopRecording()
        } else {
            this.startRecording()
            this.client.sleep()
            this.client.allowAllyToFollowLeader()
        }
    }

    startRecording() {
        if (this.recording)
            return
        this.actions := []
        this.lastTime := A_TickCount
        this.originWindowId := WinExist("A")   ; salva a janela de origem
        this.recording := true
        this._setHooks(true)
        this._tip("🔴 Gravando macro... (F9 para parar)")
    }

    stopRecording() {
        if (!this.recording)
            return
        this.recording := false
        this._setHooks(false)

        ; Captura o intervalo entre a última ação gravada e o F9 de parada
        this._logDelay()

        count := this.actions.Length
        this._tip("⏹ " count " ações gravadas. Replicando nas contas...")
        this.broadcastToAll()
        this._tip("")
    }

    ; Repete as ações gravadas em todas as contas abertas,
    ; exceto a conta de origem (onde F9 foi pressionado para iniciar).
    broadcastToAll() {
        openAccounts := this.accountMgr.getOpenAccounts()
        if (openAccounts.Length = 0) {
            this._tip("Nenhuma conta aberta encontrada.")
            this.client.sleep(1500)
            return
        }

        for accountName in openAccounts {
            ; Pula a janela onde a gravação foi iniciada
            windowName := this.accountMgr.getWindowName(accountName)
            if (WinExist(windowName) = this.originWindowId)
                continue

            this._tip("▶ Replicando em: " accountName)
            this.accountMgr.focus(accountName)
            this.client.sleep(300)
            this._replayActions()
        }
    }

    ; ─── Gravação ───────────────────────────────────────────────────────────

    _setHooks(enable) {
        state := enable ? "On" : "Off"

        ; Registra/remove hotkeys para todas as teclas virtuais (exceto F9 e modificadores puros)
        loop 254 {
            vk := Format("vk{:X}", A_Index)
            k := GetKeyName(vk)
            ; Ignora a tecla de toggle e entradas vazias
            if (k = "F9" || k = "")
                continue
            try Hotkey("~*" vk, this._onKey.Bind(this), state)
        }

        ; Teclas de navegação via scancode (garantia extra para Home, End, setas, etc.)
        for k in StrSplit("NumpadEnter|Home|End|PgUp|PgDn|Left|Right|Up|Down|Delete|Insert", "|") {
            sc := Format("sc{:03X}", GetKeySC(k))
            try Hotkey("~*" sc, this._onKey.Bind(this), state)
        }

        ; Botões do mouse
        for btn in ["LButton", "RButton", "MButton"] {
            try Hotkey("~*" btn, this._onMouse.Bind(this), state)
        }
    }

    ; Adiciona um this.client.sleep proporcional ao intervalo desde a última ação
    _logDelay() {
        t := A_TickCount
        delay := this.lastTime ? t - this.lastTime : 0
        this.lastTime := t
        if (delay > 200)
            this.actions.Push({ type: "this.client.sleep", duration: delay // 2 })
    }

    _onKey(hotkeyName) {
        Critical()
        vksc := SubStr(A_ThisHotkey, 3)          ; remove o prefixo "~*"
        k := GetKeyName(vksc)
        k := StrReplace(k, "Control", "Ctrl")
        modifier := SubStr(k, 2)

        ; Teclas modificadoras: gravar Down + Up
        if (modifier ~= "^(?i:Alt|Ctrl|Shift|Win)$") {
            this._logDelay()
            this.actions.Push({ type: "key", key: "{" k " Down}" })
            Critical("Off")
            KeyWait(k)
            Critical()
            this._logDelay()
            this.actions.Push({ type: "key", key: "{" k " Up}" })
            return
        }

        ; Teclas normais
        sendKey := StrLen(k) > 1 ? "{" k "}" : (k ~= "\w" ? k : "{" vksc "}")
        this._logDelay()
        this.actions.Push({ type: "key", key: sendKey })
    }

    _onMouse(hotkeyName) {
        Critical()
        k := GetKeyName(SubStr(A_ThisHotkey, 3))
        btn := SubStr(k, 1, 1)   ; "L", "R" ou "M"

        CoordMode("Mouse", "Screen")
        MouseGetPos(&x, &y)

        this._logDelay()
        this.actions.Push({ type: "mouse", button: btn, x: x, y: y, state: "D" })

        x1 := x, y1 := y
        t1 := A_TickCount
        Critical("Off")
        KeyWait(k)
        Critical()
        t2 := A_TickCount

        ; Se o botão foi solto rapidamente, considera a mesma posição
        if (t2 - t1 <= 200) {
            x2 := x1, y2 := y1
        } else {
            CoordMode("Mouse", "Screen")
            MouseGetPos(&x2, &y2)
        }

        this._logDelay()
        this.actions.Push({ type: "mouse", button: btn, x: x + x2 - x1, y: y + y2 - y1, state: "U" })
    }

    ; ─── Replay ─────────────────────────────────────────────────────────────

    _replayActions() {
        CoordMode("Mouse", "Screen")
        SetKeyDelay(30)
        SendMode("Event")

        for action in this.actions {
            switch action.type {
                case "this.client.sleep":
                    this.client.sleep(action.duration)
                case "key":
                    Send("{Blind}" action.key)
                case "mouse":
                    MouseClick(action.button, action.x, action.y, , , action.state)
            }
        }

        ; Restaura o modo padrão do projeto
        SendMode("Input")
    }

    ; ─── Utilitário ─────────────────────────────────────────────────────────

    _tip(msg) {
        BOTTOM_OFFSET := 130
        tipX := A_ScreenWidth // 2 - 150
        tipY := A_ScreenHeight - BOTTOM_OFFSET
        ToolTip(msg, tipX, tipY)
        if (msg = "")
            return
        ; Auto-remove após 2 s caso não seja sobrescrito antes
        SetTimer(() => ToolTip("", tipX, tipY), -2000)
    }
}
