Attribute VB_Name = "Constants"
Option Explicit

' === Measurement Thresholds ===
Public Const STC_OVERFLOW_OHMS As Double = 40000000       ' STC overflow threshold
Public Const PACK_INSULATION_OHMS As Double = 100000000   ' Pack insulation threshold
Public Const LOAD_RESISTOR_OHMS As Double = 100000        ' Load resistor detection threshold
Public Const STC_PROBE_RESISTANCE As Double = 4.5         ' STC probe resistance offset (ohms)

' === Voltage Thresholds ===
Public Const SWITCH_LOW_VOLTAGE As Double = 0.2            ' Switch output low threshold (V)
Public Const SWITCH_HIGH_VOLTAGE As Double = 4#             ' Switch output high threshold (V)
Public Const OFFSET_ERROR_PERCENT_LIMIT As Double = 0.4    ' Offset error percent limit (ECR22-021)
Public Const VOUT2_ERROR_LIMIT As Double = 2#              ' Vout2 error percent limit

' === Cable Resistance ===
Public Const CABLE_RESISTANCE_FUDGE As Double = 0.005      ' Cable resistance compensation (V)

' === Unit Conversion ===
Public Const PSI_TO_BAR As Double = 14.5                   ' PSI to Bar conversion factor

' === Sentinel Values ===
Public Const UNSET_VALUE As Double = 100000                 ' Sentinel for "unset" numeric globals

' === Timing ===
Public Const POD_WAIT_MS As Long = 5000                    ' POD measurement wait time (ms)

' === Switch Target ===
Public Const SWITCH_ERROR_TOLERANCE As Double = 0.08        ' Switch target error tolerance (V)

' === Rig Batch Sizes ===
Public Const SCR_BATCH_SIZE As Long = 40                   ' Sensors per CSV batch on SCR rig
Public Const UCR_BATCH_SIZE As Long = 42                   ' Sensors per CSV batch on UCR rig
Public Const LOW_BATCH_SIZE As Long = 14                   ' Sensors per CSV batch on LOW rig
