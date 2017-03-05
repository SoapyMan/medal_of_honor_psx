Attribute VB_Name = "modMisc"
Option Explicit

Public app_exit As Boolean
Public app_path As String
Public app_idemode As Boolean
Public printdebug As Boolean


'api
Public Declare Sub SetPixelV Lib "gdi32" (ByVal hdc As Long, ByVal x As Long, ByVal y As Long, ByVal color As Long)
Private Declare Function lstrlen Lib "kernel32" Alias "lstrlenA" (ByVal lpString As Long) As Long
Private Declare Function lstrcpyn Lib "kernel32" Alias "lstrcpynA" (ByVal Recipient As String, _
                                                                    ByVal pSourceString As Long, _
                                                                    ByVal iMaxLength As Long) As Long


'prints text to log
Public Sub Echo(ByVal str As String)
    frmMain.txtLog.Text = frmMain.txtLog.Text & str & vbCrLf
End Sub


'converts byte array into string
Public Function SafeStr(ByRef src As String) As String
Dim p As Long
    p = InStr(1, src, Chr(0)) - 1
    SafeStr = Left(src, p)
End Function


'converts character array to string
Public Function CharToString(ByVal address As Long) As String
Dim r As Long
    r = lstrlen(address)
    CharToString = String(r, Chr(32))
    r = lstrcpyn(CharToString, address, r + 1)
End Function


'returns filename from file path
Public Function FileFromFilePath(ByVal path As String) As String
    FileFromFilePath = Right$(path, Len(path) - InStrRev(path, "\"))
End Function


'returns path from filename
Public Function PathFromFilename(ByVal fname As String) As String
    PathFromFilename = Left$(fname, InStrRev(fname, "\"))
End Function


'returns extension from filename
Public Function FileExtension(ByVal fname As String) As String
    'FileExtension = LCase(Right$(filename, 3))
    FileExtension = Right$(fname, Len(fname) - InStrRev(fname, "."))
End Function


'returns whether app is running in IDE
Public Function IsIdeMode() As Boolean
    On Error GoTo errorhandler
    IsIdeMode = False
    Debug.Print 1 / 0 'division by zero to trigger error
    Exit Function
errorhandler:
    IsIdeMode = True
End Function


'sets texture filtering
Public Sub SetTexFilter(ByRef tex As GLuint, ByVal filter As Boolean)
    glBindTexture GL_TEXTURE_2D, tex
    If filter Then
        glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR
        glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
    Else
        glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST
        glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST
    End If
End Sub

