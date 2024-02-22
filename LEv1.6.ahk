#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#IfWinActive Last Epoch

;SetTimer CheckScriptUpdate, 100, 0x7FFFFFFF ; 100 ms, highest priority

multiplier := 1 
warp_position := 0
; duration HOLDING DOWN keys
global keyhold_dur = 30
; duration IN BETWEEN different keys
global sleep_dur = 20


; Key documentation: https://documentation.help/AutoHotkey-en/KeyList.htm
; Hotkey declaration NOTE: each declaration needs to be encapsulated with quotes ex := "x"
; CHANGE THE BELOW KEYS TO THE KEYS YOU WANT TO USE
runebolt_key := "q" 
runicinvocation_key := "w"
icerune_key := "r"
firerune_key := "RButton"
potion_key := "1"


; Cast plasma orb
XButton2::
While (GetKeyState("XButton2", "P"))
{
   skey(runebolt_key)
   sleep (280 * 1/multiplier)
   skey(runebolt_key)
   sleep (280 * 1/multiplier)
   skey(runebolt_key)
   sleep (300 * 1/multiplier)
   skey(runicinvocation_key)
   sleep (500 * 1/multiplier)
}
Return


; Cast aegis shield (Reowyn's Frostguard)
MButton::
{
   skey(icerune_key)
   ;Send {%icerune_key%}
   sleep (350 * 1/multiplier)
   skey(firerune_key)
   ;Send {%firerune_key%}
   sleep (300 * 1/multiplier)
   skey(icerune_key)
   ;Send {%icerune_key%}
   sleep (350 * 1/multiplier)
   skey(runicinvocation_key)
   ;Send {%runicinvocation_key%}
   sleep (300 * 1/multiplier)
}
Return


; Warp to positions 1-4
F1::
{
   warp(59, 103 + warp_position * 113)
}
Return


; Use potion when teleporting (experimental belt mod: X Seconds of Traversel CDR)
;~e:: 
;{
;   Sleep, 50
;   Send {%potion_key%}
;   Sleep, 200
;} 
;Return



; Hotkeys for fine tuning the cast speed multiplier
Left:: 
{
   multiplier:= multiplier - .05 

   roundedmulti := Round(multiplier, 2)
   ToolTip, Cast Speed: %roundedmulti%
   SetTimer, RemoveToolTip, 1000
}
Return


; Hotkeys for fine tuning the cast speed multiplier
Right:: 
{
   multiplier:= multiplier + .05 

   roundedmulti := Round(multiplier, 2)
   ToolTip, Cast Speed: %roundedmulti%
   SetTimer, RemoveToolTip, 1000
}
Return


; decrement the position of warping
Down::
{
   warp_position := Mod(warp_position - 1, 4)

   warp_pos := warp_position + 1
   ToolTip, Warp Pos: %warp_pos%
   SetTimer, RemoveToolTip, 1000
}
Return


; increment the position of warping
Up::
{
   warp_position := Mod(warp_position + 1, 4)

   warp_pos := warp_position + 1
   ToolTip, Warp Pos: %warp_pos%
   SetTimer, RemoveToolTip, 1000
}
Return


; Rebind walk
;~Rbutton::f13


; Remove visible tooltip
RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
Return


skey(key) 
{
   if (key == "RButton")
   {
      Send, {Click, Right}
      Sleep, keyhold_dur
   }
   else
   {
      Send, {%key% down}
      Sleep, keyhold_dur
      Send, {%key% up}
      ;Sleep, sleep_dur
   }
}


; Function to store original position of mouse
warp(x, y)
{
   BlockInput On
   ; Get the current mouse position
   MouseGetPos, OriginalMouseX, OriginalMouseY

   ; Click at the specified position
   Click, %x%, %y%
   Sleep, 10
   Click, %x%, %y%   ; Second click to (hopefully) ensure the click goes through

   ; Return the mouse to its original position
   MouseMove, %OriginalMouseX%, %OriginalMouseY%, 0
   BlockInput Off
}


Mod(x, y) 
{
   return x - y * Floor(x / y)
}


/************************
*  Ignore this section  *
************************/
; Reload script everytime there's a change
; Used for debugging and creation, ignore this
/*
CheckScriptUpdate() {
   global ScriptStartModTime
   FileGetTime curModTime, %A_ScriptFullPath%
   If (curModTime == ScriptStartModTime)
       return
   SetTimer CheckScriptUpdate, Off
   Loop
   {
       reload
       Sleep 300 ; ms
       MsgBox 0x2, %A_ScriptName%, Reload failed. ; 0x2 = Abort/Retry/Ignore
       IfMsgBox Abort
           ExitApp
       IfMsgBox Ignore
           break
   } ; loops reload on "Retry"
}
*/