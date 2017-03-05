Attribute VB_Name = "modTGA"
Option Explicit


'loads TGA texture
Public Function LoadTGA(ByVal filename As String) As GLuint
    On Error GoTo errorhandler
    
    'check if file exists
    If Dir$(filename) = "" Then
        MsgBox "File " & Chr(34) & filename & Chr(34) & " not found.", vbExclamation
        Exit Function
    End If
    
    'open file
    Dim ff As Integer
    ff = FreeFile
    Open filename For Binary Access Read Lock Write As ff
    
    Dim id As Integer
    Dim imgtype As Integer
    Dim u1 As Integer
    Dim u2 As Integer
    Dim u3 As Integer
    Dim u4 As Integer
    Dim width As Integer
    Dim height As Integer
    Dim bpp As Integer
    Dim size As Long
    Dim data() As Byte
    
    'read header
    Get ff, , id
    Get ff, , imgtype
    Get ff, , u1
    Get ff, , u2
    Get ff, , u3
    Get ff, , u4
    Get ff, , width
    Get ff, , height
    Get ff, , bpp
    
    'validate
    If Not imgtype = 2 Then
        MsgBox "TGA format not supported.", vbExclamation
        Close ff
        Exit Function
    End If
    
    'select format
    Dim format As GLenum
    Dim intformat As GLint
    Select Case bpp
    Case 24:
        format = GL_BGR
        intformat = GL_RGB8
    Case 32:
        format = GL_BGRA
        intformat = GL_RGBA8
    Case Else
        MsgBox "TGA format not supported.", vbExclamation
        Close ff
        Exit Function
    End Select
    
    'read data
    size = CLng(width) * CLng(height) * CLng(bpp / 8)
    ReDim data(0 To size - 1)
    Get ff, , data()
    
    'close file
    Close ff
    
    'create texture
    Dim tex As GLuint
    glGenTextures 1, tex
    glBindTexture GL_TEXTURE_2D, tex
    glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT 'GL_CLAMP_TO_EDGE
    glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT 'GL_CLAMP_TO_EDGE
    'glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR
    'glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
    SetTexFilter tex, view_filtering 'temp: neater way to do this?
    'glTexImage2D GL_TEXTURE_2D, 0, intformat, width, height, 0, format, GL_UNSIGNED_BYTE, data(0)
    gluBuild2DMipmaps GL_TEXTURE_2D, intformat, width, height, format, GL_UNSIGNED_BYTE, VarPtr(data(0))
    
    LoadTGA = tex
    Exit Function
errorhandler:
    MsgBox "LoadTGA" & vbLf & Err.Description, vbCritical
End Function

