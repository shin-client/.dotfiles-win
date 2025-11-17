#Requires AutoHotkey v2.0
#SingleInstance force

; #Include %A_ScriptDir%\MediaKeys.ahk
; #Include %A_ScriptDir%\TextExpansion.ahk

; Ctrl+Alt+T open Terminal
^!T::Run "wt.exe"

; Ctrl + Q to close
^q::Send "{Alt down}{F4}{Alt up}"

; Move to left Desktop Ctrl+Win+Left
!#Left::Send "^#{Left}"

; Move to right Desktop Ctrl+Win+Right
!#Right::Send "^#{Right}"

; Create new Desktop (Ctrl+Win+D)
!#d::Send "^#d"

; Close current Desktop (Ctrl+Win+F4)
!#q::Send "^#{F4}"
