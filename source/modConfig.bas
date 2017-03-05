Attribute VB_Name = "modConfig"
Option Explicit


Public current_file As String
Public current_path As String
Public current_filter As Long
Public recent_file(1 To 4) As String


'loads config from file
Public Sub LoadConfig(ByRef filename As String)
Dim ff As Integer
Dim ln As String
Dim str() As String
    
    'check if file exists
    If Dir$(filename) = "" Then Exit Sub
    
    'open file
    ff = FreeFile
    Open filename For Input As ff
    Do Until EOF(ff)
        Line Input #ff, ln
        ln = Trim$(ln)
        
        If Left$(ln, 1) <> ";" Then
            
            str = Split(ln, "=")
            Select Case str(0)
            Case "path": current_path = str(1)
            Case "filter": current_filter = Val(str(1))
            Case "recent1": recent_file(1) = str(1)
            Case "recent2": recent_file(2) = str(1)
            Case "recent3": recent_file(3) = str(1)
            Case "recent4": recent_file(4) = str(1)
            End Select
            
        End If
    
    Loop
    Close ff

End Sub


'writes config to file
Public Sub SaveConfig(ByRef filename As String)
Dim ff As Integer
    
    ff = FreeFile
    Open filename For Output As ff
    
    Print #ff, "[Misc]"
    Print #ff, "path=" & PathFromFileName(current_path)
    Print #ff, "filter=" & current_filter
    Print #ff, "recent1=" & recent_file(1)
    Print #ff, "recent2=" & recent_file(2)
    Print #ff, "recent3=" & recent_file(3)
    Print #ff, "recent4=" & recent_file(4)
    
    Close ff
End Sub
