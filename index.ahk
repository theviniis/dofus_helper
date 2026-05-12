#Requires AutoHotkey v2.0
#Include ./src/utils/header.ahk
#Include ./src/utils/JSON.ahk
#Include ./src/clients/travel_history.ahk
#Include ./src/clients/zap.ahk
#Include ./src/clients/accounts.ahk
#Include ./src/clients/client.ahk
#Include ./src/clients/travel.ahk

config := Jxon_Load_File("config.json")

client := ClientInterface(config)
account := AccountManager(config["accounts"], client)
travelHist := TravelHistory()
zap := ZapNavigator(config["travelersBag"], client, travelHist, account)
travel := TravelNavigator(client)

$#1:: account.focus('iop')
$#2:: account.focus('eni')
$#3:: account.focus('cra')
$#4:: account.focus('sac')

$^t:: travel.use()
$+h:: zap.use()
$^h:: zap.useAll()
$^Esc:: zap.stop()

$#c:: client.copyWindowName()

$F1:: {

    data := Jxon_Load_File("config.json")
    MsgBox(data["accounts"]["iop"])
}
