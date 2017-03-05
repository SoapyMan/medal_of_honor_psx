Attribute VB_Name = "modXXX"
Option Explicit

Public xxx_base As Long
Public xxx_stride As Long
Public xxx_offsetx As Long
Public xxx_offsety As Long
Public xxx_offsetz As Long
Public xxx_selstart As Long
Public xxx_selend As Long
Public xxx_3d As Boolean

Private Type xxxfile
    size As Long
    data() As Integer
End Type


Private xxx As xxxfile


'loads XXX file
Public Function LoadXXX(ByVal filename As String) As Boolean
    On Error GoTo errorhandler
    
    'open file
    Dim ff As Integer
    ff = FreeFile
    Open filename For Binary Access Read Lock Write As ff
    
    'info
    Echo "File Info"
    Echo " filename: " & filename
    Echo " filesize: " & LOF(ff)
    
    'byte offset
    Dim offset As Long
    Dim str As String
    str = InputBox("Byte offset:", "Byte offset", 0)
    If Len(str) Then
        offset = Val(str)
    End If
    
    'read data
    xxx.size = LOF(ff) / 2
    ReDim xxx.data((xxx.size - 1) + 16) 'note: 16 is safety buffer
    Get ff, 1 + offset, xxx.data()
    
    'close file
    Close ff
    
    LoadXXX = True
    Exit Function
errorhandler:
    MsgBox "LoadXXX" & vbLf & Err.Description, vbCritical
End Function


'draws XXX data
Public Sub DrawXXX()
    On Error GoTo errorhandler
    
Dim i As Long
Dim ox As Long
Dim oy As Long
Dim oz As Long
    
    If xxx_stride = 0 Then xxx_stride = 1
    
    If xxx.size Then
        
        glPointSize view_pointsize
        
        'temp: aabb
        'Dim min As tsppos
        'Dim max As tsppos
        'glColor3f 0, 1, 0
        'min.x = xxx.data(xxx_selstart)
        'min.y = xxx.data(xxx_selstart + 1)
        'min.z = xxx.data(xxx_selstart + 2)
        'max.x = xxx.data(xxx_selstart + 3)
        'max.y = xxx.data(xxx_selstart + 4)
        'max.z = xxx.data(xxx_selstart + 5)
        'DrawBox min, max
        'temp
        
        glBegin GL_POINTS
            i = xxx_base
            Do While i < xxx.size
                
                If i >= xxx_selstart And i <= xxx_selend Then
                    glColor3f 1, 0, 0
                Else
                    glColor3f 1, 1, 1
                End If
                
                ox = i + xxx_offsetx
                oy = i + xxx_offsety
                oz = i + xxx_offsetz
                
                If xxx_3d Then
                    glVertex3s xxx.data(ox), _
                               xxx.data(oy), _
                               xxx.data(oz)
                Else
                    glVertex3s xxx.data(ox), _
                               0, _
                               xxx.data(oy)
                End If
                
                i = i + xxx_stride
            Loop
        glEnd
        
    End If
    
    Exit Sub
errorhandler:
    frmScene.stsMain.SimpleText = Err.Description
End Sub

