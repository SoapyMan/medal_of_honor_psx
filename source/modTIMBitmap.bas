Attribute VB_Name = "modTIMBitmap"
Option Explicit

Public Type byte4
    r As Byte
    g As Byte
    b As Byte
    a As Byte
End Type

Public Type timbitmap
    posx As Long
    posy As Long
    width As Long
    height As Long
    frags As Long
    data() As Byte
    
    realwidth As Long
End Type

Public timbmp As timbitmap


'sets tim bitmap pixel
Public Sub TimSetPixel(ByVal x As Long, ByVal y As Long, ByRef c As byte4)
Dim i As Long
    i = (x + (y * timbmp.width)) * timbmp.frags
    timbmp.data(i + 0) = c.r
    timbmp.data(i + 1) = c.g
    timbmp.data(i + 2) = c.b
    If timbmp.frags = 4 Then
        timbmp.data(i + 3) = c.a
    End If
End Sub


'resizes tim bitmap
Public Sub TimResizeBitmap(ByVal w As Long, ByVal h As Long, ByVal f As Long)
    Erase timbmp.data()
    timbmp.width = w
    timbmp.height = h
    timbmp.frags = f
    ReDim timbmp.data(0 To (w * h * f) - 1)
End Sub


'create tim bitmap from raw TIM
Public Sub TimCreateBitmap()
Dim w As Long
Dim h As Long
Dim x As Long
Dim y As Long
Dim i As Long
Dim i1 As Long
Dim i2 As Long
Dim c As Long
    
    Select Case tim.bpp
    Case 8: '4bit
        w = tim.head8i.sizex * 2
        h = tim.head8i.sizey
        TimResizeBitmap w * 2, h, 4
        timbmp.posx = tim.head8i.posx
        timbmp.posy = tim.head8i.posy
        timbmp.realwidth = tim.head8i.sizex
        For x = 0 To w - 1
            For y = 0 To h - 1
                i = tim.data8(x + (y * w))
                i1 = (i And 15)
                i2 = Fix(i / 16) And 15
                
                'set pixel 1
                c = tim.palette(i1)
                TimSetPixel (x * 2) + 0, y, RGBA5551ToRGBA(c)
                
                'set pixel 2
                c = tim.palette(i2)
                TimSetPixel (x * 2) + 1, y, RGBA5551ToRGBA(c)
            Next y
        Next x
        
    Case 9: '8bit
        w = tim.head8i.sizex * 2
        h = tim.head8i.sizey
        TimResizeBitmap w, h, 3
        timbmp.posx = tim.head8i.posx
        timbmp.posy = tim.head8i.posy
        timbmp.realwidth = tim.head8i.sizex
        For x = 0 To w - 1
            For y = 0 To h - 1
                i = tim.data8(x + (y * w))
                c = tim.palette(i)
                TimSetPixel x, y, RGB565ToRGB(c)
            Next y
        Next x
        
    Case 2: '16bit
        w = tim.head16.sizex
        h = tim.head16.sizey
        TimResizeBitmap w, h, 3
        timbmp.posx = tim.head16.posx
        timbmp.posy = tim.head16.posy
        timbmp.realwidth = tim.head8i.sizex
        For x = 0 To w - 1
            For y = 0 To h - 1
                c = tim.data16(x + (y * w))
                TimSetPixel x, y, RGB565ToRGB(c)
            Next y
        Next x
        
    End Select
End Sub


'converts uint16 to RGB
Public Function RGB565ToRGB(ByVal c As Long) As byte4
Static r As Long
Static g As Long
Static b As Long
    
    '16bit = R5 G6 B5 = BBBBB GGGGGG RRRRR
    'or perhaps R5 G5 B5 (1 bit unused)???
    
    If c = -1 Then
        'c = 65535 'bugfix for sign bit
        RGB565ToRGB.r = 0
        RGB565ToRGB.g = 0
        RGB565ToRGB.b = 255
        RGB565ToRGB.a = 255
        Exit Function
    End If
    
    'todo: try extra bit for green
    r = (c And 31)
    g = (c And 992) / (2 ^ 5)
    b = (c And 31744) / (2 ^ 10)
    
    RGB565ToRGB.r = r * 8 'm
    RGB565ToRGB.g = g * 8 'm
    RGB565ToRGB.b = b * 8 'm
    If r + g + b = 0 Then
        RGB565ToRGB.a = 0
    Else
        RGB565ToRGB.a = 255
    End If
End Function

'         texpage = (.face(i).tsb And 31)        'shift 0 bits
'           blend = (.face(i).tsb And 96) / 32   'shift 5 bits (2^5)=32
'            bits = (.face(i).tsb And 448) / 128 'shift 7 bits (2^7)=128

'converts uint16 to RGBA
Public Function RGBA5551ToRGBA(ByVal c As Long) As byte4
Const m As Single = 255 / 32
Static r As Long
Static g As Long
Static b As Long
Static a As Long
    
    If c = 0 Then 'bugfix/alpha mask
        RGBA5551ToRGBA.r = 0
        RGBA5551ToRGBA.g = 0
        RGBA5551ToRGBA.b = 0
        RGBA5551ToRGBA.a = 0
        Exit Function
    End If
    
    'A BBBBB GGGGG RRRRR
    r = (c And 31)
    g = (c And 992) / (2 ^ 5)
    b = (c And 31744) / (2 ^ 10)
    a = (c And 32768) / (2 ^ 15)
    
    RGBA5551ToRGBA.r = r * 8 'm
    RGBA5551ToRGBA.g = g * 8 'm
    RGBA5551ToRGBA.b = b * 8 'm
    RGBA5551ToRGBA.a = a * 255
End Function

