Attribute VB_Name = "PCI7250"
Option Explicit

' =============================================================================
' Module:      PCI7250
' Purpose:     ADLINK PCI-7250 Digital I/O card vendor SDK declares and constants.
' Dependencies: None (uses Pci-Dask.dll)
' Depends On:  InputsOutputs.bas
' Translation Notes:
'   - DLL declares for Pci-Dask.dll.
'   - Replace with official ADLINK .NET / C++ SDK or appropriate driver libraries in the target language.
' =============================================================================

' ADLink PCI Card Type
Global Const PCI_7250 = 11

' DLL Declares
Declare Function Register_Card Lib "Pci-Dask.dll" (ByVal cardType As Integer, ByVal card_num As Integer) As Integer
Declare Function Release_Card Lib "Pci-Dask.dll" (ByVal CardNumber As Integer) As Integer
Declare Function DI_ReadPort Lib "Pci-Dask.dll" (ByVal CardNumber As Integer, ByVal Port As Integer, Value As Long) As Integer
