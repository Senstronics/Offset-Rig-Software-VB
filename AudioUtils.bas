Attribute VB_Name = "AudioUtils"
Option Explicit

' =============================================================================
' Module:      AudioUtils
' Purpose:     Win32 API wrapper for playing sound files (PlaySound).
' Dependencies: None (uses winmm.dll)
' Depends On:  OffsetCheck.bas
' Translation Notes:
'   - Replace this Win32 P/Invoke with the standard audio playback library of the target platform.
' =============================================================================

'Play a wave file.
Public Declare Function PlaySound Lib "winmm.dll" _
    Alias "PlaySoundA" (ByVal lpszName As String, _
    ByVal hModule As Long, ByVal dwFlags As Long) As Long


