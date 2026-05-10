#Requires AutoHotkey v2.0
#Include send_tooltip.ahk
#Include go_to_travel.ahk
#Include does_pixel_macthes.ahk

config := {
    sacoDeViagens: {
        zap: {
            click: [1165, 554],
            detect: {
                pos: [1445, 429],
                color: 0xA75F20
            }
        },
        interfaceZap: {
            detect: {
                pos: [1595, 410],
                color: 0x173238
            }
        },
        barraBusca: {
            click: [1334, 515]
        }
    }
}

useZap() {
    ; 1. Vai para o saco de viagens
    goToTravel()

    ; 2. Aguarda o saco de viagens carregar
    isOnZapScreen := doesPixelMatches(
        config.sacoDeViagens.zap.detect.pos[1],
        config.sacoDeViagens.zap.detect.pos[2],
        config.sacoDeViagens.zap.detect.color
    )

    ; 3. Clica no zap
    if (isOnZapScreen) {
        sendTooltip("Clicando no zap...")
        Click(
            config.sacoDeViagens.zap.click[1],
            config.sacoDeViagens.zap.click[2],
        )
    }

    ; 4. Aguarda o a interface do zap abrir
    isZapInterfaceOpen := doesPixelMatches(
        config.sacoDeViagens.interfaceZap.detect.pos[1],
        config.sacoDeViagens.interfaceZap.detect.pos[2],
        config.sacoDeViagens.interfaceZap.detect.color,
    )

    ; 5. Clica na barra de busca
    if (isZapInterfaceOpen) {
        sendTooltip("Clicando na barra de busca...")
        Click(
            config.sacoDeViagens.barraBusca.click[1],
            config.sacoDeViagens.barraBusca.click[2],
        )
    }
}
