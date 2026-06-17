Attribute VB_Name = "AudioUtils"
Option Explicit

'Play a wave file.
Public Declare Function PlaySound Lib "winmm.dll" _
    Alias "PlaySoundA" (ByVal lpszName As String, _
    ByVal hModule As Long, ByVal dwFlags As Long) As Long


