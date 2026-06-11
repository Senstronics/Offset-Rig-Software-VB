Attribute VB_Name = "InputsOutputs"
Option Explicit

Global card As Integer
Public IsInterlockClosed As Boolean
Public PartPresent As Boolean
Public OringPresent As Boolean
Public RestrictorPresent As Boolean
Public OutputSum As Double
Public Sub Initialise7250()
    If DevMode Then Exit Sub
  Register_Card PCI_7250, 0

End Sub
Public Sub CheckInputs()
    If DevMode Then Exit Sub
' modified by DW for toggle switch operation

  Dim Result As Integer
  Dim di_data As Long
  Dim p As Integer
  Dim Port As Integer
  
    Port = 0
    card = 0
        
    If IOCard = False Then
        Exit Sub
    Else
        
        Result = DI_ReadPort(card, Port, di_data)
        
        ' Decode the lowest bit (Bit 0) representing Interlock Status.
        ' Historically, this was written as a loop "For i = 0 To 7" with nested
        ' conditionals that rendered the check on bit 1+ unreachable.
        ' To safely clean this without altering runtime behavior, we extract
        ' the Bit 0 check directly and remove the dead loop structure.
        p = di_data Mod 2
        
        If p = 0 Then
            IsInterlockClosed = False
            ReadyFlag = True
        Else 'p = 1
            IsInterlockClosed = True
            If ReadyFlag = True And DetailChecked = True Then
                ReadyFlag = False
                START
            End If
        End If
        
    End If

End Sub
