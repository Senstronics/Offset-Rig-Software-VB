Attribute VB_Name = "DigitalMultimeterControl"
Option Explicit

' =============================================================================
' Module:      DigitalMultimeterControl
' Purpose:     Controls the Keithley Digital Multimeter and Keithley 7001 Switch Matrix via GPIB.
' Dependencies: ieeeevb, Constants
' Depends On:  OffsetCheck.bas, MainForm.frm
' Translation Notes:
'   - Communicates using SCPI commands over IEEE-488.
'   - Replace with modern hardware control APIs (e.g. VISA API) and keep the SCPI strings.
' =============================================================================
Public Const PortNumber As Integer = 16
Public Sub SendDMMCommand(ByVal Command As String)
    If DevMode Then Exit Sub
    Dim Status As Integer

    send PortNumber, Command, Status
    
End Sub
Public Function ReceiveDMMReply() As String
  'Read DMM status and report IEEE status in stat%
    If DevMode Then
        ReceiveDMMReply = "0.0"
        Exit Function
    End If
    Dim Status As Integer
    Dim l As Integer
    Dim Reply As String

    enter Reply, 255, l, PortNumber, Status
 
    ReceiveDMMReply = Reply
End Function
' This subroutine initialises the DMM for general use by the program.
' It does not set it for any particular measurement type (current or voltage) since
' this can vary from one reading to the next as two different calibration
' types can be run at the same time with the measurments potentially interleaved
'
Public Sub InitialiseDMM()
    If DevMode Then Exit Sub
  
  Dim Reply As String
  
        'Reset and check device is present
        SendDMMCommand "*CLS"   ' clear status
        SendDMMCommand "*RST"   ' reset
        
        SendDMMCommand "*IDN?"
        
End Sub

Public Function MeasureDigitalMultimeterVolts() As Double
    MeasureDigitalMultimeterVolts = MeasureDMM("Volts")
End Function

Public Function MeasureDigitalMultimeterAmps() As Double
    MeasureDigitalMultimeterAmps = MeasureDMM("Amps")
End Function

Public Function MeasureDigitalMultimeterOhms() As Double
    MeasureDigitalMultimeterOhms = MeasureDMM("Ohms")
End Function

Public Function MeasureTemp() As Double
    MeasureTemp = MeasureDMM("Temp")
End Function

Public Sub RouteDMMByPath(ByVal Path As String)
    OpenAllSwitches
    Sleep Relay_Delay
    SendDMMCommand ":ROUT:MULT:CLOS (@" & Path & ")"
    Sleep Relay_Delay
End Sub

Public Sub RouteDMM(ByVal MeasType As String)
    Dim Suffix As String
    Suffix = ""
    
    If MeasType = "Vout2Sw" Then
        If PinOutSwitch = "T" Or PinOutSwitch = "A" Or PinOutSwitch = "L" Or PinOutSwitch = "R" Then
            Suffix = PinOutSwitch
        Else
            Exit Sub
        End If
    Else
        If PinOutSwitch = "F" And (ConnectorType = "C1" Or ConnectorType = "C2") Then
            Suffix = ""
        Else
            Select Case PinOutSwitch
                Case "T": Suffix = ""
                Case "Q": Suffix = "Q"
                Case "M": Suffix = "M"
                Case "Z": Suffix = "Z"
                Case "A": Suffix = "A"
                Case "W": Suffix = "W"
                Case "L": Suffix = "L"
                Case "N": Suffix = "N"
                Case "F": Suffix = "F"
                Case "X":
                    If MeasType = "STCGnd" Then Suffix = "L"
                Case "3":
                    If MeasType = "Vout2" Then Suffix = "Q"
            End Select
        End If
    End If
    
    Dim Path As String
    Path = GetDMMRoutePath(MeasType & Suffix)
    If Path <> "" Then
        RouteDMMByPath Path
    End If
End Sub

Private Function GetDMMRoutePath(ByVal Key As String) As String
    Select Case Key
        ' STCVs routes
        Case "STCVs":     GetDMMRoutePath = "115,113,127"
        Case "STCVsA":    GetDMMRoutePath = "115,113,127"
        Case "STCVsQ":    GetDMMRoutePath = "115,113,135"
        Case "STCVsM":    GetDMMRoutePath = "115,113,127"
        Case "STCVsZ":    GetDMMRoutePath = "115,113,127"
        Case "STCVsW":    GetDMMRoutePath = "115,113,135"
        Case "STCVsL":    GetDMMRoutePath = "115,113,119"
        Case "STCVsF":    GetDMMRoutePath = "115,113,127"
        Case "STCVsC":    GetDMMRoutePath = "115,113,127"
        Case "STCVs6":    GetDMMRoutePath = "115,113,135"
        Case "STCVsN":    GetDMMRoutePath = "115,113,143"
        Case "STCVsU":    GetDMMRoutePath = "115,113,119"
        
        ' STCGnd routes
        Case "STCGnd":    GetDMMRoutePath = "115,113,119"
        Case "STCGndA":   GetDMMRoutePath = "115,113,119"
        Case "STCGndQ":   GetDMMRoutePath = "115,113,127"
        Case "STCGndM":   GetDMMRoutePath = "115,113,135"
        Case "STCGndZ":   GetDMMRoutePath = "115,113,135"
        Case "STCGndW":   GetDMMRoutePath = "115,113,119"
        Case "STCGndL":   GetDMMRoutePath = "115,113,127"
        Case "STCGndF":   GetDMMRoutePath = "115,113,143"
        Case "STCGndC":   GetDMMRoutePath = "115,113,143"
        Case "STCGnd6":   GetDMMRoutePath = "115,113,127"
        Case "STCGndN":   GetDMMRoutePath = "115,113,127"
        Case "STCGndU":   GetDMMRoutePath = "115,113,135"
        
        ' STCVout1 routes
        Case "STCVout1":  GetDMMRoutePath = "115,113,135"
        Case "STCVout1A": GetDMMRoutePath = "115,113,143"
        Case "STCVout1Q": GetDMMRoutePath = "115,113,143"
        Case "STCVout1M": GetDMMRoutePath = "115,113,119"
        Case "STCVout1Z": GetDMMRoutePath = "115,113,119"
        Case "STCVout1W": GetDMMRoutePath = "115,113,127"
        Case "STCVout1L": GetDMMRoutePath = "115,113,135"
        Case "STCVout1F": GetDMMRoutePath = "115,113,135"
        Case "STCVout1C": GetDMMRoutePath = "115,113,119"
        Case "STCVout16": GetDMMRoutePath = "115,113,119"
        Case "STCVout1N": GetDMMRoutePath = "115,113,135"
        Case "STCVout1U": GetDMMRoutePath = "115,113,143"
        
        ' STCVout2 routes
        Case "STCVout2":  GetDMMRoutePath = "115,113,143"
        Case "STCVout2A": GetDMMRoutePath = "115,113,135"
        Case "STCVout2Q": GetDMMRoutePath = "115,113,119"
        Case "STCVout2M": GetDMMRoutePath = "115,113,143"
        Case "STCVout2Z": GetDMMRoutePath = "115,113,143"
        Case "STCVout2W": GetDMMRoutePath = "115,113,143"
        Case "STCVout2L": GetDMMRoutePath = "115,113,143"
        Case "STCVout2F": GetDMMRoutePath = "115,113,119"
        Case "STCVout2C": GetDMMRoutePath = "115,113,135"
        Case "STCVout26": GetDMMRoutePath = "115,113,143"
        Case "STCVout2N": GetDMMRoutePath = "115,113,119"
        
        ' Current routes
        Case "Current":   GetDMMRoutePath = "109,112,118,129"
        Case "CurrentA":  GetDMMRoutePath = "109,112,118,129"
        Case "CurrentQ":  GetDMMRoutePath = "109,112,126,137"
        Case "CurrentM":  GetDMMRoutePath = "109,112,134,129"
        Case "CurrentZ":  GetDMMRoutePath = "109,112,134,129"
        Case "CurrentW":  GetDMMRoutePath = "109,112,118,137"
        Case "CurrentL":  GetDMMRoutePath = "109,112,126,121"
        Case "CurrentF":  GetDMMRoutePath = "109,112,129,142"
        Case "CurrentC":  GetDMMRoutePath = "109,112,142,129"
        Case "Current6":  GetDMMRoutePath = "109,112,126,137"
        Case "CurrentN":  GetDMMRoutePath = "109,112,126,145"
        Case "CurrentU":  GetDMMRoutePath = "109,112,134,121"
        
        ' Vout1 routes
        Case "Vout1":     GetDMMRoutePath = "125,135,121,118"
        Case "Vout1A":    GetDMMRoutePath = "125,143,121,118"
        Case "Vout1Q":    GetDMMRoutePath = "133,143,129,126"
        Case "Vout1M":    GetDMMRoutePath = "125,119,137,134"
        Case "Vout1Z":    GetDMMRoutePath = "125,119,137,134"
        Case "Vout1W":    GetDMMRoutePath = "133,127,121,118"
        Case "Vout1L":    GetDMMRoutePath = "117,135,129,126"
        Case "Vout1F":    GetDMMRoutePath = "125,135,145,142"
        Case "Vout1C":    GetDMMRoutePath = "125,119,145,142"
        Case "Vout16":    GetDMMRoutePath = "133,119,129,126"
        Case "Vout1N":    GetDMMRoutePath = "141,135,129,126"
        
        ' Vout2 routes
        Case "Vout2":     GetDMMRoutePath = "125,143,121,118"
        Case "Vout2A":    GetDMMRoutePath = "125,135,121,118"
        Case "Vout2Q":    GetDMMRoutePath = "133,119,129,126"
        Case "Vout2M":    GetDMMRoutePath = "125,143,137,134"
        Case "Vout2Z":    GetDMMRoutePath = "125,143,137,134"
        Case "Vout2W":    GetDMMRoutePath = "133,143,121,118"
        Case "Vout2L":    GetDMMRoutePath = "117,143,129,126"
        Case "Vout2F":    GetDMMRoutePath = "125,119,145,142"
        Case "Vout2C":    GetDMMRoutePath = "125,135,145,142"
        Case "Vout26":    GetDMMRoutePath = "133,143,129,126"
        Case "Vout2N":    GetDMMRoutePath = "133,143,129,126"
        
        ' Switch measurement routes
        Case "Vout2SwT":  GetDMMRoutePath = "125,143,121,118,233"
        Case "Vout2SwA":  GetDMMRoutePath = "125,135,121,118,233"
        Case "Vout2SwL":  GetDMMRoutePath = "117,143,129,126,233"
        Case "Vout2SwR":  GetDMMRoutePath = "117,135,129,126,233"
        Case "Vout1SwA":  GetDMMRoutePath = "125,143,121,118,233"
        
        ' Named standalone switches
        Case "PSUCheck":             GetDMMRoutePath = "101,103,110,113"
        Case "SwitchToCheckPSUT":    GetDMMRoutePath = "135,118,121,233"
        Case "SwitchToCheckPSUL":    GetDMMRoutePath = "135,126,129,233"
        Case "SwitchToCheckPSUA":    GetDMMRoutePath = "143,118,121,233"
        Case "SwitchToCheckPSUR":    GetDMMRoutePath = "143,126,129,233"
        Case "SwitchPackOffsetMeas": GetDMMRoutePath = "125,118,137,143"
        Case "SwitchTempMeas":       GetDMMRoutePath = "105,106,111,116"
        Case "SwitchPackInsulation": GetDMMRoutePath = "115,113,143"
        Case "SwitchDualVout1Meas":  GetDMMRoutePath = "126,129,117,143"
        Case "SwitchDualVout2Meas":  GetDMMRoutePath = "126,129,117,135"
        
        Case Else: GetDMMRoutePath = ""
    End Select
End Function

Public Function MeasureDMM(ByVal Mode As String) As Double
    Dim Reply As String
    
    If DevMode Then
        Select Case Mode
            Case "Volts"
                Dim midVal As Double
                midVal = (Val(MainForm.LowerLimitDisplay) + Val(MainForm.UpperLimitDisplay)) / 2
                If midVal = 0 Then midVal = 5#
                MeasureDMM = midVal
            Case "Amps"
                MeasureDMM = 3.5
            Case "Ohms"
                MeasureDMM = 107.8
            Case "Temp"
                MeasureDMM = 20.0
            Case Else
                MeasureDMM = 0
        End Select
        Exit Function
    End If

    Select Case Mode
        Case "Volts"
            SendDMMCommand ":FUNC 'VOLTAGE:DC'"
            SendDMMCommand ":VOLTAGE:DC:RANGE:AUTO 1"
            SendDMMCommand "READ?"
            Reply = ReceiveDMMReply()
            MeasureDMM = Val(Reply)
        Case "Amps"
            SendDMMCommand ":FUNC 'CURRENT:DC'"
            SendDMMCommand ":CURRENT:DC:RANGE:AUTO 1"
            SendDMMCommand "READ?"
            Reply = ReceiveDMMReply()
            MeasureDMM = Val(Reply)
        Case "Ohms"
            SendDMMCommand ":FUNC 'RES'"
            SendDMMCommand ":SENS:RES:NPLC 1"
            SendDMMCommand ":SENS:RES:RANG:AUTO ON"
            SendDMMCommand "READ?"
            Reply = ReceiveDMMReply()
            MeasureDMM = Val(Reply)
        Case "Temp"
            Dim ohms As Double
            Sleep Relay_Delay
            SendDMMCommand ":FUNC 'RES'"
            SendDMMCommand ":SENS:RES:NPLC 0.1"
            SendDMMCommand ":SENS:RES:RANG 100"
            SendDMMCommand "READ?"
            Reply = ReceiveDMMReply()
            ohms = Val(Reply) - 1.5
            MeasureDMM = 20 + (ohms - 107.8) / 0.382
        Case Else
            MeasureDMM = 0
    End Select
End Function

Public Function CheckLoadOn() As Boolean
    If DevMode Then
        CheckLoadOn = False
        Exit Function
    End If

    Dim reading As Double
    CheckLoadOn = False
    
    ' check gnd to vout1
    RouteDMMByPath "102,105,135"
    reading = MeasureDMM("Ohms")
    If reading < LOAD_RESISTOR_OHMS Then
        CheckLoadOn = True
    End If
    
    ' check VS to vout1
    RouteDMMByPath "125,127,137"
    reading = MeasureDMM("Ohms")
    If reading < LOAD_RESISTOR_OHMS Then
        CheckLoadOn = True
    End If
End Function

Public Sub PSUCheck()
    RouteDMMByPath "101,103,110,113"
End Sub

Public Sub SwitchToCheckPSUT()
    RouteDMMByPath "135,118,121,233"
End Sub

Public Sub SwitchToCheckPSUL()
    RouteDMMByPath "135,126,129,233"
End Sub

Public Sub SwitchToCheckPSUA()
    RouteDMMByPath "143,118,121,233"
End Sub

Public Sub SwitchToCheckPSUR()
    RouteDMMByPath "143,126,129,233"
End Sub

Public Sub SwitchPackOffsetMeas()
    RouteDMMByPath "125,118,137,143"
End Sub

Public Sub SwitchTempMeas()
    RouteDMMByPath "105,106,111,116"
End Sub

Public Sub SwitchPackInsulation()
    RouteDMMByPath "115,113,143"
End Sub

Public Sub SwitchDualVout1Meas()
    RouteDMMByPath "126,129,117,143"
End Sub

Public Sub SwitchDualVout2Meas()
    RouteDMMByPath "126,129,117,135"
End Sub

Public Sub OpenAllSwitches()
    If DevMode Then Exit Sub
    SendDMMCommand ":ROUT:OPEN:ALL"
End Sub
