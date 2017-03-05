Attribute VB_Name = "modOpenGL"
Option Explicit

Private glhdc As Long
Private glrc As Long


'loads opengl
Public Function InitGL(ByVal hdc As Long) As Boolean
    
    'copy handle
    glhdc = hdc
    
    'fill pixel format descripor
    Dim pfd As PIXELFORMATDESCRIPTOR
    pfd.nSize = Len(pfd)
    pfd.nVersion = 1
    pfd.dwFlags = PFD_SUPPORT_OPENGL Or PFD_DRAW_TO_WINDOW Or PFD_DOUBLEBUFFER Or PFD_TYPE_RGBA
    pfd.iPixelType = PFD_TYPE_RGBA
    pfd.cColorBits = 24
    pfd.cDepthBits = 16
    pfd.iLayerType = PFD_MAIN_PLANE
    
    'find pixelformat
    Dim r As Long
    r = ChoosePixelFormat(glhdc, pfd)
    If r = 0 Then
        MsgBox "ChoosePixelFormat failed.", vbCritical
        Exit Function
    End If
    
    'set pixel format
    r = SetPixelFormat(glhdc, r, pfd)
    If r = 0 Then
        MsgBox "SetPixelFormat failed.", vbCritical
        Exit Function
    End If
    
    'create rendering context
    glrc = wglCreateContext(glhdc)
    
    'select rendering context
    wglMakeCurrent glhdc, glrc
    
    'success
    InitGL = True
End Function


'resizes viewport
Public Sub ResizeGL(ByVal width As Long, ByVal height As Long)
    If width < 1 Then width = 1
    If height < 1 Then height = 1
    
    glViewport 0, 0, width, height
End Sub


'draws scene
Public Sub DrawGL()
        
    'draw the content
    DrawScene
    
    'swap buffers
    glFinish
    SwapBuffers glhdc
End Sub


'unloads opengl
Public Sub KillGL()
    If glrc <> 0 Then
        wglMakeCurrent 0, 0
        wglDeleteContext glrc
    End If
End Sub

