Attribute VB_Name = "PCI7250"
Option Explicit

' ADLink PCI Card Type
Global Const PCI_7250 = 11

' DLL Declares
Declare Function Register_Card Lib "Pci-Dask.dll" (ByVal cardType As Integer, ByVal card_num As Integer) As Integer
Declare Function Release_Card Lib "Pci-Dask.dll" (ByVal CardNumber As Integer) As Integer
Declare Function DI_ReadPort Lib "Pci-Dask.dll" (ByVal CardNumber As Integer, ByVal Port As Integer, Value As Long) As Integer
