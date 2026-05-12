#SingleInstance Force
#Requires AutoHotkey v2.0
#HotIf WinActive("ahk_exe Dofus.exe")
#Include ./src/clients/travel_history.ahk
#Include ./src/clients/zap.ahk
#Include ./src/clients/accounts.ahk
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
        'cra', 'Arqueira-no-sigilo - Cra - 3.5.14.18 - Release',
        'sac', 'Berserker-no-sigilo - Sacrier - 3.5.14.18 - Release',
    ),
    sacoDeViagens: Map(
        'zap', Map(
            'click', [1165, 554],
            'detect', Map(
                'pos', [1445, 429],
                'color', 0xA75F20
            )
        ),
        'interfaceZap', Map(
            'detect', Map(
                'pos', [1595, 410],
                'color', 0x173238
            )
        ),
        'search', Map(
            'click', [1334, 515]
        )
    )
}

client := ClientInterface(config)
acc := AccountManager(config.accountList, client)
travel := TravelHistory()
zap := ZapNavigator(config.sacoDeViagens, client, travel, acc)
travel := TravelNavigator(client)

$#1:: acc.focus('iop')
$#2:: acc.focus('eni')
$#3:: acc.focus('cra')
$#4:: acc.focus('sac')

$^t:: travel.use()
$+h:: zap.use()
$^h:: zap.useAll()
$^Esc:: zap.stop()

$#c:: client.copyWindowName()