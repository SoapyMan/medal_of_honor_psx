Attribute VB_Name = "modTIM"
Option Explicit

Private Type timhead   'file header
    id As Integer      '16
    ver As Integer     '0
End Type

Private Type timhead16 '16bit header
    size As Long       'filesize - 8
    posx As Integer    '0
    posy As Integer    '0
    sizex As Integer   '512
    sizey As Integer   '256
End Type

Private Type timhead8p '8bit palette header
    size As Long
    posx As Integer
    posy As Integer
    colors As Integer
    frames As Integer
End Type

Private Type timhead8i '8bit image header
    size As Long
    posx As Integer
    posy As Integer
    sizex As Integer
    sizey As Integer
End Type

Private Type timfile   'file structure
    head As timhead
    bpp As Long        '2/9/8
    
    head16 As timhead16
    head8p As timhead8p
    head8i As timhead8i
    
    palette() As Integer
    data16() As Integer
    data8() As Byte
End Type


Public tim As timfile


'loads TIM file
Public Function LoadTim(ByVal filename As String) As Boolean
    On Error GoTo errorhandler
    
    If Dir$(filename) = "" Then
        MsgBox "File " & Chr(34) & filename & Chr(34) & " inacessable.", vbExclamation
        Exit Function
    End If
    
    'unload
    UnloadTim
    
    Dim ff As Integer
    ff = FreeFile
    Open filename For Binary Access Read Lock Write As ff
    
    'file info
    Echo "File Info"
    Echo " filename:   " & filename
    Echo " filesize:   " & LOF(ff)
    
    'read tim
    ReadTimHeader ff, -1
    ReadTimData ff, -1
    
    'close file
    Close ff
    
    On Error GoTo 0
    
    frmMain.picMain.Cls
    DrawTim frmMain.picMain.hdc, 2, 2
    frmMain.picMain.Refresh
    
    LoadTim = True
    Exit Function
errorhandler:
    MsgBox "LoadTim" & vbLf & Err.Description, vbCritical
End Function


'unloads TIM data
Public Sub UnloadTim()
    Erase tim.palette
    Erase tim.data16
    Erase tim.data8
End Sub


'reads TIM header
Public Function ReadTimHeader(ByVal ff As Integer, ByVal offset As Long) As Boolean
    
    'get file header
    If offset < 0 Then
        Get ff, , tim.head
    Else
        Get ff, 1 + offset, tim.head
    End If
    
    'validate
    If tim.head.id <> 16 Then
        Exit Function
    End If
    
    If printdebug Then
        Echo " TIM Header"
        Echo "  id:        " & tim.head.id
        Echo "  ver:       " & tim.head.ver
    End If
    
    ReadTimHeader = True
End Function


'reads TIM data
Public Function ReadTimData(ByVal ff As Integer, ByVal offset As Long) As Boolean
    On Error GoTo errorhandler
    
    'get bpp
    If offset < 0 Then
        Get ff, , tim.bpp
    Else
        Get ff, 1 + offset, tim.bpp
    End If
    If printdebug Then
        Echo "  bpp:       " & tim.bpp
    End If
    
    'read data
    Dim size As Long
    Select Case tim.bpp
    Case 8: '4bit
        
        'get palette header
        Get ff, , tim.head8p
        
        If printdebug Then
            Echo "  Palette Header"
            Echo "   size:     " & tim.head8p.size
            Echo "   posx:     " & tim.head8p.posx
            Echo "   posy:     " & tim.head8p.posy
            Echo "   colors:   " & tim.head8p.colors
            Echo "   frames:   " & tim.head8p.frames
        End If
        
        'get palette data
        size = CLng(tim.head8p.colors) * CLng(tim.head8p.frames)
        ReDim tim.palette(0 To size - 1)
        Get ff, , tim.palette()
        
        'get image header
        Get ff, , tim.head8i
        
        If printdebug Then
            Echo "  Image Header"
            Echo "   size:     " & tim.head8i.size
            Echo "   posx:     " & tim.head8i.posx
            Echo "   posy:     " & tim.head8i.posy
            Echo "   sizex:    " & tim.head8i.sizex
            Echo "   sizey:    " & tim.head8i.sizey
        End If
        
        'get image data
        size = tim.head8i.size - 12
        ReDim tim.data8(0 To size - 1)
        Get ff, , tim.data8()
    
    Case 9: '8bit
        
        'get palette header
        Get ff, , tim.head8p
        
        If printdebug Then
            Echo "  Palette Header"
            Echo "   size:     " & tim.head8p.size
            Echo "   posx:     " & tim.head8p.posx
            Echo "   posy:     " & tim.head8p.posy
            Echo "   colors:   " & tim.head8p.colors
            Echo "   frames:   " & tim.head8p.frames
        End If
        
        'get palette data
        size = CLng(tim.head8p.colors) * CLng(tim.head8p.frames)
        ReDim tim.palette(0 To size - 1)
        Get ff, , tim.palette()
        
        'get image header
        Get ff, , tim.head8i
        
        If printdebug Then
            Echo "  Image Header"
            Echo "   size:     " & tim.head8i.size
            Echo "   posx:     " & tim.head8i.posx
            Echo "   posy:     " & tim.head8i.posy
            Echo "   sizex:    " & tim.head8i.sizex
            Echo "   sizey:    " & tim.head8i.sizey
        End If
        
        'get image data
        size = tim.head8i.size - 12
        ReDim tim.data8(0 To size - 1)
        Get ff, , tim.data8()
    
    Case 2: '16bit
        
        'get image header
        Get ff, , tim.head16
        
        If printdebug Then
            Echo "  Image Header"
            Echo "   size:     " & tim.head16.size
            Echo "   posx:     " & tim.head16.posx
            Echo "   posy:     " & tim.head16.posy
            Echo "   sizex:    " & tim.head16.sizex
            Echo "   sizey:    " & tim.head16.sizey
        End If
        
        'get image data
        size = tim.head16.size - 8
        ReDim tim.data16(0 To size - 1)
        Get ff, , tim.data16()
        
    End Select
    
    ReadTimData = True
    Exit Function
errorhandler:
    MsgBox "ReadTimData" & vbLf & Err.Description, vbCritical
End Function


'draws TIM to hdc
Public Sub DrawTim(ByRef hdc As Long, ByVal ox As Long, ByVal oy As Long)
Dim w As Long
Dim h As Long
Dim x As Long
Dim y As Long

Dim i As Long
Dim i1 As Integer
Dim i2 As Integer
Dim c As Long
    
    Select Case tim.bpp
    Case 8: '4bit
        
        ''draw palette
        'For x = 0 To tim.head8p.colors - 1
        '    For y = 0 To 7
        '        c = tim.palette(x)
        '
        '        SetPixelV hdc, ox + x, oy + y, ShortToRGBA(c)
        '    Next y
        'Next x
        'oy = oy + 10
        
        'draw image
        w = tim.head8i.sizex * 2
        h = tim.head8i.sizey
        For x = 0 To w - 1
            For y = 0 To h - 1
                
                i = tim.data8(x + (y * w))
                i1 = (i And 15)
                i2 = Fix(i / 16) And 15
                
                'set pixel 1
                c = tim.palette(i1)
                SetPixelV hdc, ox + (x * 2) + 0, oy + y, ShortToRGBA(c)
                
                'set pixel 2
                c = tim.palette(i2)
                SetPixelV hdc, ox + (x * 2) + 1, oy + y, ShortToRGBA(c)
            Next y
        Next x
        
    Case 9: '8bit
        
        w = tim.head8i.sizex * 2
        h = tim.head8i.sizey
        For x = 0 To w - 1
            For y = 0 To h - 1
            
                i = tim.data8(x + (y * w))
                c = tim.palette(i)
                
                SetPixelV hdc, ox + x, oy + y, ShortToRGB(c)
            Next y
        Next x
    
    Case 2: '16bit
        
        w = tim.head16.sizex
        h = tim.head16.sizey
        For x = 0 To w - 1
            For y = 0 To h - 1
                
                c = tim.data16(x + (y * w))
                
                SetPixelV hdc, ox + x, oy + y, ShortToRGB(c)
            Next y
        Next x
        
    End Select
End Sub


'...
Public Function ShortToRGB(ByVal c As Long) As Long
Static t As byte4
    t = RGB565ToRGB(c)
    ShortToRGB = RGB(t.r, t.g, t.b)
End Function


'...
Public Function ShortToRGBA(ByVal c As Long) As Long
Static t As byte4
    t = RGBA5551ToRGBA(c)
    ShortToRGBA = RGB(t.r, t.g, t.b)
End Function
