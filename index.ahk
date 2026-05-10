#SingleInstance Force
#Requires AutoHotkey v2.0
#HotIf WinActive("ahk_exe Dofus.exe")
#Include ./src/clients/use_zap.ahk
#Include ./src/clients/accounts.ahk
#Include ./src/clients/zap_coordinator.ahk
#Include ./src/clients/client_interface.ahk
#Include ./src/clients/travel.ahk

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
        search: {
            click: [1334, 515]
        }
    }
}

clientIF := ClientInterface(config)
acc := AccountManager(config.accountList, clientIF)
zapNav := ZapNavigator(config.sacoDeViagens, clientIF)
travelNav := TravelNavigator(clientIF)
coordinator := ZapCoordinator(zapNav, acc, clientIF)

$#1:: acc.focus('iop')
$#2:: acc.focus('eni')
$#3:: acc.focus('sac')

$+t:: travelNav.use()
$+h:: zapNav.use()
$^h:: coordinator.runAll()
$^Esc:: zapNav.stop()

$#c:: clientIF.copyWindowName()