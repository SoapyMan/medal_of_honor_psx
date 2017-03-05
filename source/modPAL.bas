Attribute VB_Name = "modPAL"
Option Explicit

Private Type rgba
    r As Byte
    g As Byte
    b As Byte
    a As Byte
End Type

Private Type palfile
    size As Long
    data() As rgba
End Type

Private pal As palfile


'loads PAL file
Public Function LoadPal(ByVal filename As String) As Boolean
    On Error GoTo errorhandler
    
    'open file
    Dim ff As Integer
    ff = FreeFile
    Open filename For Binary Access Read Lock Write As ff
    
    'info
    Echo "File Info"
    Echo " filename: " & filename
    Echo " filesize: " & LOF(ff)
    
    'read data
    pal.size = LOF(ff) / 4
    ReDim pal.data(0 To pal.size - 1)
    Get ff, , pal.data()
    
    'close file
    Close ff
    
    DrawPal
    
    LoadPal = True
    Exit Function
errorhandler:
    MsgBox "LoadPal" & vbLf & Err.Description, vbCritical
End Function


'draws PAL data
Public Sub DrawPal()
Dim x As Long
Dim y As Long
Dim c As Long
    
    frmMain.picMain.Cls
    
    For x = 0 To pal.size - 1
        c = RGB(pal.data(x).r, pal.data(x).g, pal.data(x).b)
        For y = 0 To 8
            SetPixelV frmMain.picMain.hdc, 2 + x, 2 + y, c
        Next y
        
        'c = ShortToRGB(pal.data(x))
        'For y = 0 To 8
        '    SetPixelV frmMain.picMain.hdc, 2 + x, 2 + y, c
        'Next y
        
        'c = ShortToRGBA(pal.data(x))
        'For y = 0 To 8
        '    SetPixelV frmMain.picMain.hdc, 2 + x, 2 + 10 + y, c
        'Next y
    Next x
    
End Sub

