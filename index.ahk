#SingleInstance Force
#Requires AutoHotkey v2.0
#HotIf WinActive("ahk_exe Dofus.exe")
#Include ./src/utils/use_zap.ahk
#Include ./src/utils/accounts.ahk
#Include ./src/utils/zap_coordinator.ahk
#Include ./src/utils/copy_window_name.ahk

SetTitleMatchMode 3
SendMode "Input"
CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")

config := {
    accountList: Map(
        'iop', 'Bate-no-sigilo - Iop - 3.5.14.18 - Release',
        'eni', 'Cura-no-sigilo - Eniripsa - 3.5.14.18 - Release',
        'sac', 'Berserker-no-sigilo - Sacrier - 3.5.14.18 - Release',
    ),
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

acc := AccountManager(config.accountList)
zapNav := ZapNavigator(config.sacoDeViagens)
coordinator := ZapCoordinator(zapNav, acc)

$#1:: acc.focus('iop')
$#2:: acc.focus('eni')
$#3:: acc.focus('sac')

$h:: coordinator.runAll()
Esc:: zap.stop()

$#c:: copyWindowName()