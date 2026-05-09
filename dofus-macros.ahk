SetTitleMatchMode 3

$#1:: activateWindow("Bate-no-sigilo - Iop - 3.5.14.18 - Release")
$#2:: activateWindow("Cura-no-sigilo - Eniripsa - 3.5.14.18 - Release")
$#3:: activateWindow("Berserker-no-sigilo - Sacrier - 3.5.14.18 - Release")
$#4:: activateWindow("Arqueiro-no-sigilo")

$#c:: copyWindowName()

; Functions
copyWindowName() {
    activeTitle := WinGetTitle("A")
    A_Clipboard := activeTitle
}

activateWindow(windowName) {
    WinWait windowName
    WinActivate windowName
}
