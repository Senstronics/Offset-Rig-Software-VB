Attribute VB_Name = "Database"
Option Explicit

' =============================================================================
' Module:      Database
' Purpose:     Accesses the SQLite setup database for retrieving and checking limits.
' Dependencies: None (defines custom dll declares / ADODB connection)
' Depends On:  OffsetCheck.bas, MainForm.frm, LogFile.bas, PWord.frm
' Translation Notes:
'   - Uses ADODB and sqlite3.dll custom declares.
'   - Replace with standard ADO.NET SQLite libraries or standard SQLite bindings in the target language.
' =============================================================================

#If twinBASIC Then
    Private Declare PtrSafe Function sqlite3_open16 CDecl Lib "sqlite3.dll" (ByVal filename As LongPtr, ByRef ppDb As LongPtr) As Long
    Private Declare PtrSafe Function sqlite3_close CDecl Lib "sqlite3.dll" (ByVal db As LongPtr) As Long
    Private Declare PtrSafe Function sqlite3_prepare16_v2 CDecl Lib "sqlite3.dll" (ByVal db As LongPtr, ByVal zSql As LongPtr, ByVal nByte As Long, ByRef ppStmt As LongPtr, ByVal pzTail As LongPtr) As Long
    Private Declare PtrSafe Function sqlite3_step CDecl Lib "sqlite3.dll" (ByVal stmt As LongPtr) As Long
    Private Declare PtrSafe Function sqlite3_finalize CDecl Lib "sqlite3.dll" (ByVal stmt As LongPtr) As Long
    Private Declare PtrSafe Function sqlite3_column_text16 CDecl Lib "sqlite3.dll" (ByVal stmt As LongPtr, ByVal iCol As Long) As LongPtr
    Private Declare PtrSafe Function sqlite3_column_int CDecl Lib "sqlite3.dll" (ByVal stmt As LongPtr, ByVal iCol As Long) As Long
    Private Declare PtrSafe Function sqlite3_column_double CDecl Lib "sqlite3.dll" (ByVal stmt As LongPtr, ByVal iCol As Long) As Double
    Private Declare PtrSafe Function sqlite3_column_type CDecl Lib "sqlite3.dll" (ByVal stmt As LongPtr, ByVal iCol As Long) As Long
#Else
    ' Standard VB6 fallback if needed, but not used since we compile in twinBASIC
#End If

#If VB7 Then
    Private Declare PtrSafe Function SysAllocString Lib "oleaut32.dll" (ByVal pOlechar As LongPtr) As LongPtr
    Private Declare PtrSafe Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As LongPtr)
#Else
    Private Declare Function SysAllocString Lib "oleaut32.dll" (ByVal pOlechar As Long) As Long
    Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As Long)
#End If

#If VB7 Then
Private Function PointerToString(ByVal ptr As LongPtr) As String
    If ptr = 0 Then Exit Function
    Dim bstrPtr As LongPtr
    bstrPtr = SysAllocString(ptr)
    If bstrPtr <> 0 Then
        CopyMemory ByVal VarPtr(PointerToString), bstrPtr, 8
    End If
    PointerToString = Trim$(PointerToString)
End Function
#Else
Private Function PointerToString(ByVal ptr As Long) As String
    If ptr = 0 Then Exit Function
    Dim bstrPtr As Long
    bstrPtr = SysAllocString(ptr)
    If bstrPtr <> 0 Then
        CopyMemory ByVal VarPtr(PointerToString), bstrPtr, 4
    End If
    PointerToString = Trim$(PointerToString)
End Function
#End If

Private Const SQLITE_OK As Long = 0
Private Const SQLITE_ROW As Long = 100
Private Const SQLITE_DONE As Long = 101
Private Const SQLITE_NULL As Long = 5

#If VB7 Then
    Private Declare PtrSafe Function LoadLibraryW Lib "kernel32" (ByVal lpLibFileName As LongPtr) As LongPtr
#Else
    Private Declare Function LoadLibraryW Lib "kernel32" (ByVal lpLibFileName As Long) As Long
#End If

Private hDB As LongPtr

Public Function DB_Open(ByVal DBPath As String) As Boolean
    Static hLib As LongPtr
    If hLib = 0 Then
        hLib = LoadLibraryW(StrPtr(App.Path & "\sqlite3.dll"))
        If hLib = 0 Then
            hLib = LoadLibraryW(StrPtr("sqlite3.dll"))
        End If
    End If

    If hDB <> 0 Then
        DB_Open = True
        Exit Function
    End If
    
    Dim res As Long
    res = sqlite3_open16(StrPtr(DBPath), hDB)
    If res = SQLITE_OK Then
        DB_Open = True
    Else
        hDB = 0
        DB_Open = False
    End If
End Function

Public Sub DB_Close()
    If hDB <> 0 Then
        sqlite3_close hDB
        hDB = 0
    End If
End Sub

Public Function DB_Execute(ByVal SQL As String) As Boolean
    If hDB = 0 Then Exit Function
    
    Dim hStmt As LongPtr
    Dim res As Long
    
    res = sqlite3_prepare16_v2(hDB, StrPtr(SQL), -1, hStmt, 0)
    If res = SQLITE_OK Then
        res = sqlite3_step(hStmt)
        sqlite3_finalize hStmt
        DB_Execute = (res = SQLITE_DONE Or res = SQLITE_ROW)
    Else
        DB_Execute = False
    End If
End Function

Public Function DB_GetProductRange(ByVal WorksOrder As String, ByRef OutRoute As NonStandardProcessRoute) As Boolean
    If hDB = 0 Then Exit Function
    
    Dim hStmt As LongPtr
    Dim res As Long
    Dim SQL As String
    
    ' Lookup matching prefix based on longest match (exact match or prefix match)
    SQL = "SELECT prefix, process_name, limit_voltage, require_verification, current_draw_lower, current_draw_upper "
    SQL = SQL & "FROM product_ranges WHERE '" & Replace(WorksOrder, "'", "''") & "' LIKE prefix || '%' ORDER BY LENGTH(prefix) DESC LIMIT 1"
          
    res = sqlite3_prepare16_v2(hDB, StrPtr(SQL), -1, hStmt, 0)
    If res = SQLITE_OK Then
        res = sqlite3_step(hStmt)
        If res = SQLITE_ROW Then
            Dim ptr As LongPtr
            ptr = sqlite3_column_text16(hStmt, 0)
            If ptr <> 0 Then OutRoute.Prefix = PointerToString(ptr)
            
            ptr = sqlite3_column_text16(hStmt, 1)
            If ptr <> 0 Then OutRoute.ProcessName = PointerToString(ptr)
            
            OutRoute.LimitVoltage = sqlite3_column_double(hStmt, 2)
            OutRoute.RequireVerification = (sqlite3_column_int(hStmt, 3) <> 0)
            
            ' Check for database NULL values and map to -1 for lower/upper current limits
            If sqlite3_column_type(hStmt, 4) = SQLITE_NULL Then
                OutRoute.CurrentDrawLower = -1#
            Else
                OutRoute.CurrentDrawLower = sqlite3_column_double(hStmt, 4)
            End If
            
            If sqlite3_column_type(hStmt, 5) = SQLITE_NULL Then
                OutRoute.CurrentDrawUpper = -1#
            Else
                OutRoute.CurrentDrawUpper = sqlite3_column_double(hStmt, 5)
            End If
            
            DB_GetProductRange = True
        Else
            DB_GetProductRange = False
        End If
        sqlite3_finalize hStmt
    Else
        DB_GetProductRange = False
    End If
End Function

Public Function DB_GetBoardType(ByVal Code As String, ByRef OutSymbol As String, ByRef OutRequireSTC As Boolean) As Boolean
    If hDB = 0 Then Exit Function
    
    Dim hStmt As LongPtr
    Dim res As Long
    Dim SQL As String
    
    SQL = "SELECT board_symbol, require_stc FROM board_types WHERE board_code = '" & Replace(Code, "'", "''") & "' LIMIT 1"
    res = sqlite3_prepare16_v2(hDB, StrPtr(SQL), -1, hStmt, 0)
    If res = SQLITE_OK Then
        res = sqlite3_step(hStmt)
        If res = SQLITE_ROW Then
            Dim ptr As LongPtr
            ptr = sqlite3_column_text16(hStmt, 0)
            If ptr <> 0 Then OutSymbol = PointerToString(ptr)
            OutRequireSTC = (sqlite3_column_int(hStmt, 1) <> 0)
            DB_GetBoardType = True
        Else
            DB_GetBoardType = False
        End If
        sqlite3_finalize hStmt
    Else
        DB_GetBoardType = False
    End If
End Function

Public Function DB_GetConnector(ByVal Code As String, ByRef OutName As String, ByRef OutIsFourPin As Boolean) As Boolean
    If hDB = 0 Then Exit Function
    
    Dim hStmt As LongPtr
    Dim res As Long
    Dim SQL As String
    
    SQL = "SELECT connector_name, is_four_pin FROM connector_types WHERE connector_code = '" & Replace(Code, "'", "''") & "' LIMIT 1"
    res = sqlite3_prepare16_v2(hDB, StrPtr(SQL), -1, hStmt, 0)
    If res = SQLITE_OK Then
        res = sqlite3_step(hStmt)
        If res = SQLITE_ROW Then
            Dim ptr As LongPtr
            ptr = sqlite3_column_text16(hStmt, 0)
            If ptr <> 0 Then OutName = PointerToString(ptr)
            OutIsFourPin = (sqlite3_column_int(hStmt, 1) <> 0)
            DB_GetConnector = True
        Else
            DB_GetConnector = False
        End If
        sqlite3_finalize hStmt
    Else
        DB_GetConnector = False
    End If
End Function

Public Function DB_GetUnionFittingID(ByVal Code As String) As Long
    If hDB = 0 Then Exit Function
    
    Dim hStmt As LongPtr
    Dim res As Long
    Dim SQL As String
    Dim Val As Long
    
    SQL = "SELECT fitting_id FROM unions WHERE union_code = '" & Replace(Code, "'", "''") & "' LIMIT 1"
    res = sqlite3_prepare16_v2(hDB, StrPtr(SQL), -1, hStmt, 0)
    If res = SQLITE_OK Then
        res = sqlite3_step(hStmt)
        If res = SQLITE_ROW Then
            Val = sqlite3_column_int(hStmt, 0)
        Else
            Val = 0
        End If
        sqlite3_finalize hStmt
    Else
        Val = 0
    End If
    DB_GetUnionFittingID = Val
End Function

Public Function DB_GetColourName(ByVal Code As String) As String
    If hDB = 0 Then Exit Function
    
    Dim hStmt As LongPtr
    Dim res As Long
    Dim SQL As String
    Dim Val As String
    
    SQL = "SELECT colour_name FROM wire_colours WHERE colour_code = '" & Replace(Code, "'", "''") & "' LIMIT 1"
    res = sqlite3_prepare16_v2(hDB, StrPtr(SQL), -1, hStmt, 0)
    If res = SQLITE_OK Then
        res = sqlite3_step(hStmt)
        If res = SQLITE_ROW Then
            Dim ptr As LongPtr
            ptr = sqlite3_column_text16(hStmt, 0)
            If ptr <> 0 Then Val = PointerToString(ptr)
        Else
            Val = ""
        End If
        sqlite3_finalize hStmt
    Else
        Val = ""
    End If
    DB_GetColourName = Val
End Function

Public Function DB_GetCableChannel(ByVal Code As String) As Long
    If hDB = 0 Then Exit Function
    
    Dim hStmt As LongPtr
    Dim res As Long
    Dim SQL As String
    Dim Val As Long
    
    SQL = "SELECT channel_number FROM cable_mappings WHERE cable_code = '" & Replace(Code, "'", "''") & "' LIMIT 1"
    res = sqlite3_prepare16_v2(hDB, StrPtr(SQL), -1, hStmt, 0)
    If res = SQLITE_OK Then
        res = sqlite3_step(hStmt)
        If res = SQLITE_ROW Then
            Val = sqlite3_column_int(hStmt, 0)
        Else
            Val = 0
        End If
        sqlite3_finalize hStmt
    Else
        Val = 0
    End If
    DB_GetCableChannel = Val
End Function

Public Function DB_GetCableWear(ByVal Channel As Long, ByRef OutUsage As Long, ByRef OutLimit As Long) As Boolean
    If hDB = 0 Then Exit Function
    
    Dim hStmt As LongPtr
    Dim res As Long
    Dim SQL As String
    
    SQL = "SELECT current_usage, usage_limit FROM cable_harness WHERE channel_number = " & Channel & " LIMIT 1"
    res = sqlite3_prepare16_v2(hDB, StrPtr(SQL), -1, hStmt, 0)
    If res = SQLITE_OK Then
        res = sqlite3_step(hStmt)
        If res = SQLITE_ROW Then
            OutUsage = sqlite3_column_int(hStmt, 0)
            OutLimit = sqlite3_column_int(hStmt, 1)
            DB_GetCableWear = True
        Else
            DB_GetCableWear = False
        End If
        sqlite3_finalize hStmt
    Else
        DB_GetCableWear = False
    End If
End Function

Public Function DB_IncrementCableUsage(ByVal Channel As Long) As Boolean
    If hDB = 0 Then Exit Function
    
    Dim SQL As String
    SQL = "UPDATE cable_harness SET current_usage = current_usage + 1 WHERE channel_number = " & Channel
    DB_IncrementCableUsage = DB_Execute(SQL)
End Function
