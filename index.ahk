#Requires AutoHotkey v2.0
#HotIf WinActive("ahk_exe Dofus.exe")
#Include ./src/utils/activate_window.ahk
#Include ./src/utils/use_zap.ahk
#Include ./src/utils/copy_window_name.ahk

SetTitleMatchMode 3
SendMode "Input"
CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")

$#1:: activateWindow("Bate-no-sigilo - Iop - 3.5.14.18 - Release")
$#2:: activateWindow("Cura-no-sigilo - Eniripsa - 3.5.14.18 - Release")
$#3:: activateWindow("Berserker-no-sigilo - Sacrier - 3.5.14.18 - Release")
$#4:: activateWindow("Arqueiro-no-sigilo")

$h:: useZap()

$#c:: copyWindowName()