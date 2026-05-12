#Requires AutoHotkey v2.0

#SingleInstance Force
SetTitleMatchMode 3
SendMode "Input"
CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")

DOFUS_CLIENT := "ahk_exe Dofus.exe"
SLEEP_TIME := 250

#HotIf WinActive(DOFUS_CLIENT)