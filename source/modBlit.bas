Attribute VB_Name = "modBlit"
Option Explicit

Private Declare Function CreateCompatibleBitmap Lib "gdi32.dll" (ByVal hdc As Long, ByVal nWidth As Long, ByVal nHeight As Long) As Long
Private Declare Function DeleteObject Lib "gdi32.dll" (ByVal hObject As Long) As Long
Private Declare Function SelectObject Lib "gdi32.dll" (ByVal hdc As Long, ByVal hObject As Long) As Long
Private Declare Function BitBlt Lib "gdi32" (ByVal hDestDC As Long, ByVal x As Long, ByVal y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal hSrcDC As Long, ByVal xSrc As Long, ByVal ySrc As Long, ByVal dwRop As Long) As Long

Private m_hdc As Long
Private m_dc As Long
Private m_bmp As Long
Private m_width As Long
Private m_height As Long

Public Sub StartDraw(ByVal hdc As Long, ByVal w As Long, ByVal h As Long)
    m_hdc = hdc
    m_width = w
    m_height = h
    
    m_bmp = CreateCompatibleBitmap(m_hdc, m_width, m_height)
    'm_dc = CreateCompatibleDC(0)
    
End Sub

Public Sub SetPixelXXX(ByVal x As Long, ByVal y As Long, ByVal c As Long)
    If x < 0 Then Exit Sub
    If y < 0 Then Exit Sub
    If x > m_width - 1 Then Exit Sub
    If y > m_height - 1 Then Exit Sub
    
    'todo
End Sub

Public Sub EndDraw()
    SelectObject m_hdc, m_bmp
    
    'BitBlt m_hdc, 0, 0, m_width, m_height, m_src, 0, 0, vbSrcCopy
    
    DeleteObject m_bmp
    'DeleteDC m_dc
End Sub
