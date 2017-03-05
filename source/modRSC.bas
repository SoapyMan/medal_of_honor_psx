Attribute VB_Name = "modRSC"
Option Explicit

Private Type rscroot
    filename As String * 64
    num As Long
    unknown As Long
End Type

Private Type rscnode
    filename As String * 64
    id As Long
    size As Long
    offset As Long
    unknown As Long
End Type

Private Type rscfile
    root As rscroot
    node() As rscnode
End Type

Public rsc As rscfile


'loads RSC file
Public Function LoadRsc(ByVal filename As String) As Boolean
    On Error GoTo errorhandler
    
    Dim ff As Integer
    ff = FreeFile
    Open filename For Binary Access Read Lock Write As ff
    
    'info
    Echo "File Info"
    Echo " filename:   " & filename
    Echo " filesize:   " & LOF(ff)
    
    'determine string length
    'todo: read warpath RSC files (128 byte strings)
    
    'get root
    Get ff, , rsc.root
    Echo " RSC Header"
    Echo "  name:     " & SafeStr(rsc.root.filename)
    Echo "  chunks:   " & rsc.root.num
    Echo "  unknown:  " & rsc.root.unknown
    
    'get file list
    If rsc.root.num > 0 Then
        ReDim rsc.node(1 To rsc.root.num)
        Dim i As Long
        Dim k As String
        For i = 1 To rsc.root.num
            Get ff, , rsc.node(i)
            
            k = i & "@"
            frmMain.lsvMain.ListItems.Add , k, rsc.node(i).filename
            frmMain.lsvMain.ListItems(k).SubItems(1) = rsc.node(i).size
            frmMain.lsvMain.ListItems(k).SubItems(2) = rsc.node(i).offset
            frmMain.lsvMain.ListItems(k).SubItems(3) = rsc.node(i).unknown
        Next i
    End If
    
    'close file
    Close ff
    
    LoadRsc = True
    Exit Function
errorhandler:
    MsgBox "LoadRsc" & vbLf & Err.Description, vbCritical
End Function


'view TIM chunk
Public Sub ViewTim(ByVal rsc As String, ByVal offset As Long)
Dim ff As Integer
    
    'open resource
    ff = FreeFile
    Open rsc For Binary Access Read Lock Write As ff
    ReadTimHeader ff, offset
    ReadTimData ff, -1
    Close ff
    
    frmMain.picMain.Cls
    DrawTim frmMain.picMain.hdc, 2, 2
    frmMain.picMain.Refresh
    
End Sub


'extracts file from RSC file
Public Function ExtractFile(ByVal rsc As String, ByVal out As String, _
                            ByVal offset As Long, ByVal size As Long) As Boolean
    On Error GoTo errorhandler
    
    'allocate buffer
    Dim data() As Byte
    ReDim data(size - 1)
    
    'open resource
    Dim ff As Integer
    ff = FreeFile
    Open rsc For Binary Access Read Lock Write As ff
    Get ff, 1 + offset, data()
    Close ff
    
    'write output
    ff = FreeFile
    Open out For Binary Access Write As ff
    Put ff, , data()
    Close ff
    
    ExtractFile = True
    Exit Function
errorhandler:
    MsgBox "ExtractFile" & vbLf & Err.Description, vbCritical
End Function
