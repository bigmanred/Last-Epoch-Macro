#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetKeyDelay, -1
SetMouseDelay, -1

; Increased Cast Speed Stat (86% = 0.86 | 195% = 1.95)
castSpeed := 0.86

; Passives
runeOfDilationLevel := 3
arcaneMomentumLevel := 4

; Runic Invocation Specialization
runeSlingerLevel := 3
transcriberOfPowerLevel := 2

; Runebolt Specialization
arcanistLevel := 1

; Key documentation: https://documentation.help/AutoHotkey-en/KeyList.htm
; Hotkey declaration NOTE: each declaration needs to be encapsulated with quotes ex := "x"
; CHANGE THE BELOW KEYS TO THE KEYS YOU WANT TO USE
runebolt_key := "q" 
runicinvocation_key := "r"
icerune_key := "e" ; Frost Wall
firerune_key := "g" ; Flame Ward
teleport_hotkey := "w"
potion_key := "1"

; Educated Guesses based on testing
runeBoltAnimationSpeed := 690
runicInvocationAnimationSpeed := 810

; State Variables
warpBuff := 0
arcaneMomentumStacks := 0
transcriberOfPower := 0
warp_position := 0
castSpeedShrine := 0
runicInvocationSpecificCastSpeed := runeSlingerLevel*0.05
runeboltSpecificCastSpeed := runeSlingerLevel*0.04
stunImmune := false
castSpeed -= 0.01 ; Rounding Sanity

; Hotkeys
Hotkey, IfWinActive, Last Epoch
Hotkey, *~%teleport_hotkey%, TeleportHandling
Hotkey, IfWinActive

NumpadMult::Reload

#IfWinActive Last Epoch

; Cast plasma orb
*XButton2::
While (GetKeyState("XButton2", "P"))
{
   if (!stunImmune)
   {
      ; MouseGetPos, curX, curY
      ; MouseMove, 1717, 707
      ; Sleep, 10
      skey(teleport_hotkey)
      CastSpeedSleep(750)
   }
   skey(runebolt_key)
   CastSpeedSleep(runeBoltAnimationSpeed, runeboltSpecificCastSpeed)
   skey(runebolt_key)
   CastSpeedSleep(runeBoltAnimationSpeed, runeboltSpecificCastSpeed)
   skey(runebolt_key)
   CastSpeedSleep(runeBoltAnimationSpeed, runeboltSpecificCastSpeed)
   skey(runicinvocation_key)
   CastSpeedSleep(runicInvocationAnimationSpeed, runicInvocationSpecificCastSpeed)
}
Return

; Cast aegis shield (Reowyn's Frostguard)
*MButton::
{
   skey(icerune_key)
   ;Send {%icerune_key%}
   sleep (350 * 1/castSpeed)
   skey(firerune_key)
   ;Send {%firerune_key%}
   sleep (300 * 1/castSpeed)
   skey(icerune_key)
   ;Send {%icerune_key%}
   sleep (350 * 1/castSpeed)
   skey(runicinvocation_key)
   ;Send {%runicinvocation_key%}
   sleep (300 * 1/castSpeed)
}
Return

; Warp to positions 1-4
*F1::
{
   warp(59, 103 + warp_position * 113)
}
Return

; Cast Speed Shrine
Up::
   castSpeedShrine := 0.3
   SetTimer, DisableCastSpeedShrine, 55000
Return

; Cooldown Shrine?

; Trades
*F5::
{
   BlockInput, MouseMove
   temp := Clipboard
   Clipboard := 49494
   MouseGetPos, curX, curY
   Send, {LShift Down}
   Sleep, 10
   Click, right
   Sleep, 100
   Send, {LShift Up}
   Sleep, 10
   Click, 1566, 730
   Sleep, 50
   Send, ^a
   Sleep, 50
   Send, ^v
   Sleep, 50
   Click, 1533, 807
   Sleep, 200
   Click, 1533, 807
   Sleep, 300
   Click, 2617, 752
   Sleep, 20
   MouseMove, %curX%, %curY%
   BlockInput, MouseMoveOff
}
Return

; decrement the position of warping
*Down::
{
   warp_position := Mod(warp_position - 1, 4)

   warp_pos := warp_position + 1
   ToolTip, Warp Pos: %warp_pos%
   SetTimer, RemoveToolTip, 1000
}
Return
; increment the position of warping
*Up::
{
   warp_position := Mod(warp_position + 1, 4)

   warp_pos := warp_position + 1
   ToolTip, Warp Pos: %warp_pos%
   SetTimer, RemoveToolTip, 1000
}
Return

; Remove visible tooltip
RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
Return

#IfWinActive

skey(key)
{
   global
   if (key == "RButton")
   {
      Send, {Click, Right}
   }
   else
   {
      Send, {%key% down}
      Sleep, 10
      Send, {%key% up}
   }
}

; Use potion when teleporting (experimental belt mod: X Seconds of Traversel CDR)
TeleportHandling()
{
   global
   stunImmune := true
   warpBuff := 0.1
   SetTimer, DisableStunImmune, 5000
   SetTimer, DisableWarpBuff, % runeOfDilationLevel * 950
   SetTimer, DrinkPotion, 100
   Return
}

DisableWarpBuff()
{
   global
   SetTimer, DisableWarpBuff, Off
   warpBuff := 0
}

DisableStunImmune()
{
   global
   SetTimer, DisableStunImmune, Off
   stunImmune := false
   
}
DisableCastSpeedShrine()
{
   global
   SetTimer, DisableCastSpeedShrine, Off
   castSpeedShrine := 0
}

DrinkPotion()
{
   global
   SetTimer, DrinkPotion, Off
   skey(potion_key)
}

ResetArcaneMomentum()
{
   global
   SetTimer, ResetArcaneMomentum, Off
   arcaneMomentumStacks := 0
}

ResetTranscriberOfPower()
{
   global
   SetTimer, ResetTranscriberOfPower, Off
   transcriberOfPower := 0
}

CastSpeedSleep(baseSpeed, specificSkillCastSpeed = 0)
{
   global
   SetTimer, ResetArcaneMomentum, 1900
   
   Sleep, Ceil((baseSpeed / (1 + castSpeed + warpBuff + (arcaneMomentumStacks*0.05) + transcriberOfPower + specificSkillCastSpeed + castSpeedShrine)) - 10)
   if(arcaneMomentumStacks < arcaneMomentumLevel)
   {
      arcaneMomentumStacks += 1
   }
}
; Function to store original position of mouse
warp(x, y)
{
   BlockInput, MouseMove
   ; Get the current mouse position
   MouseGetPos, OriginalMouseX, OriginalMouseY

   ; Click at the specified position
   Click, %x%, %y%
   Sleep, 10
   Click, %x%, %y%   ; Second click to (hopefully) ensure the click goes through

   ; Return the mouse to its original position
   MouseMove, %OriginalMouseX%, %OriginalMouseY%, 0
   BlockInput, MouseMoveOff
}


Mod(x, y) 
{
   return x - y * Floor(x / y)
}