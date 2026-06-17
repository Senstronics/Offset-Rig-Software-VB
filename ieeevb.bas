Attribute VB_Name = "ieeeevb"
Option Explicit

'****************************************************************************************************
'Module1  (ieeevb.bas)          Visual Basic 6.0 Module
'CEC IEEE-488 subroutines for use with CEC interface cards
'Copyright (C) 1995, Capital Equipment Corporation
'****************************************************************************************************

Global Const IEEEListener = 0, IEEE488SD = 1, IEEEDMA = 2, IEEEIOBASE = 100, IEEETIMEOUT = 200, IEEEINPUTEOS = 201, IEEEOUTPUTEOS1 = 202, IEEEOUTPUTEOS2 = 203, IEEEBOARDSELECT = 204, IEEEDMACHANNEL = 205
Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

'----------------------------------------------------------------------------
' 32-bit versions of IEEE488 routines
'----------------------------------------------------------------------------
Declare Sub initialize Lib "IEEE_32M.DLL" Alias "_ieee_initialize@8" (ByVal addr As Long, ByVal level As Long)
Declare Sub IEtrans Lib "IEEE_32M.DLL" Alias "_ieee_transmit@12" (ByVal cmd As String, ByVal l As Long, Status As Long)
Declare Sub IEreceive Lib "IEEE_32M.DLL" Alias "_ieee_receive@16" (ByVal r As String, ByVal maxlen As Long, l As Long, Status As Long)
Declare Sub IEsend Lib "IEEE_32M.DLL" Alias "_ieee_send@16" (ByVal addr As Long, ByVal s As String, ByVal l As Long, Status As Long)
Declare Sub IEenter Lib "IEEE_32M.DLL" Alias "_ieee_enter@20" (ByVal r As String, ByVal maxlen As Long, l As Long, ByVal addr As Long, Status As Long)
Declare Sub IEspoll Lib "IEEE_32M.DLL" Alias "_ieee_spoll@12" (ByVal addr As Long, poll As Long, Status As Long)
Declare Sub IEppoll Lib "IEEE_32M.DLL" Alias "_ieee_ppoll@4" (poll As Long)
Declare Sub IEtarray Lib "IEEE_32M.DLL" Alias "_ieee_tarray@16" (d As Any, ByVal Count As Long, ByVal eoi As Long, Status As Long)
Declare Sub IErarray Lib "IEEE_32M.DLL" Alias "_ieee_rarray@16" (d As Any, ByVal Count As Long, l As Long, Status As Long)
Declare Function srq Lib "IEEE_32M.DLL" Alias "_ieee_srq@0" () As Long
Declare Sub setport Lib "IEEE_32M.DLL" Alias "_ieee_setport@8" (ByVal board As Long, ByVal Port As Long)
Declare Sub boardselect Lib "IEEE_32M.DLL" Alias "_ieee_boardselect@4" (ByVal board As Long)
Declare Sub dmachannel Lib "IEEE_32M.DLL" Alias "_ieee_dmachannel@4" (ByVal chan As Long)
Declare Sub settimeout Lib "IEEE_32M.DLL" Alias "_ieee_settimeout@4" (ByVal msec As Long)
Declare Sub setoutputEOS Lib "IEEE_32M.DLL" Alias "_ieee_setoutputEOS@8" (ByVal c1 As Long, ByVal c2 As Long)
Declare Sub setinputEOS Lib "IEEE_32M.DLL" Alias "_ieee_setinputEOS@4" (ByVal c As Long)
Declare Sub Enable488EX Lib "IEEE_32M.DLL" Alias "_ieee_enable_488ex@4" (ByVal e As Long)
Declare Sub Enable488SD Lib "IEEE_32M.DLL" Alias "_ieee_enable_488sd@8" (ByVal e As Long, ByVal t As Long)
Declare Function ListenerPresent Lib "IEEE_32M.DLL" Alias "_ieee_listener_present@4" (ByVal a As Long) As Long
Declare Function GpibBoardPresent Lib "IEEE_32M.DLL" Alias "_ieee_board_present@0" () As Long
Declare Function GPIBFeature Lib "IEEE_32M.DLL" Alias "_ieee_feature@4" (ByVal f As Long) As Long

'----------------------------------------------------------------------------
' Wrapper functions actually used
'----------------------------------------------------------------------------
Sub enter(r As String, maxlen As Integer, l As Integer, addr As Integer, Status As Integer)
    Dim stl As Long
    Dim ll As Long
    r = Space$(maxlen)
    Call IEenter(r, maxlen, ll, addr, stl)
    l = ll
    r = Left$(r, l)
    Status = stl
End Sub

Public Sub send(addr As Integer, s As String, Status As Integer)
    Dim stl As Long
    Call IEsend(addr, s, -1, stl)
    Status = stl
End Sub
