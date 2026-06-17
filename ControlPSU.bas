Attribute VB_Name = "ControlPSU"
Option Explicit

' =============================================================================
' Module:      ControlPSU
' Purpose:     Controls the DC Power Supply (PSU) using IVI COM drivers.
' Dependencies: ieeeevb (for Sleep)
' Depends On:  OffsetCheck.bas, DigitalMultimeterControl.bas
' Translation Notes:
'   - Employs COM automation to interact with Keithley2230 IVI Driver DLL.
'   - Migrate to standard VISA / SCPI commands or newer .NET IVI drivers.
' =============================================================================
Dim Driver As New Keithley2230
Public Sub InitialisePSU()
    If DevMode Then Exit Sub
  'Initialise Power Supply Unit And Check With A Read-Back
    
    Driver.initialize "USB0::0x05E6::0x2230::" & PSU_Visa_ID & "::INSTR", False, False, ""
    Driver.System.ControlMode = Keithley2230ControlModeRemote
    SetPSU1 24

End Sub
Public Function ReceivePSUVoltage() As String
  'Read PSU voltage
    If DevMode Then
        ReceivePSUVoltage = "24.0"
        Exit Function
    End If

    Dim Reply As String

    Reply = CStr(Driver.OutputChannels.item("OutputChannel1").Measure(Keithley2230MeasurementTypeVoltage))
    ReceivePSUVoltage = Reply
    
End Function
Public Sub SetPSU1(Supply)
'24v for vision and push button
    If DevMode Then Exit Sub
    Driver.OutputChannels.item("OutputChannel1").VoltageLevel = Supply
    Driver.OutputChannels.item("OutputChannel1").State = True
         
End Sub
Public Sub SetPSU2(Supply)
'Transducer supply
    If DevMode Then Exit Sub
    Driver.OutputChannels.item("OutputChannel2").CurrentLimit = 0.01
    Driver.OutputChannels.item("OutputChannel2").VoltageLevel = Supply * PSU_Ch2_Factor
    Driver.OutputChannels.item("OutputChannel2").State = True
    Sleep 100
        
End Sub
Public Sub SetPSU3(Supply)
'Switch Input

'set current to 3mA
    If DevMode Then Exit Sub
    Driver.OutputChannels.item("OutputChannel3").CurrentLimit = 0.005
    Driver.OutputChannels.item("OutputChannel3").VoltageLevel = Supply * PSU_Ch3_Factor
    Driver.OutputChannels.item("OutputChannel3").State = True
    Sleep 200
        
End Sub
Public Function ReadCurrent() As Double
    If DevMode Then
        ReadCurrent = 0.0035 ' 3.5mA
        Exit Function
    End If

    Dim Reply As String

    Reply = CStr(Driver.OutputChannels.item("OutputChannel2").Measure(Keithley2230MeasurementTypeCurrent))
    ReadCurrent = Val(Reply)

End Function



  

