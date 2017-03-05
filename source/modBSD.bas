Attribute VB_Name = "modBSD"
Option Explicit

'--- mesh ---------------------------------------------------------

'mesh vert
Private Type bsdmeshvert '16 bytes
    x As Integer
    y As Integer
    z As Integer
    w As Integer
End Type

'mesh face
Private Type bsdmeshface '16 bytes
    u1 As Integer   '?
    u2 As Integer   '?
    u3 As Integer   '?
    u4 As Integer   'always 24
    u5 As Integer   '?
    u6 As Integer   'always CDCD
    u7 As Integer   '?
    u8 As Byte      '?
    u9 As Byte      'always 192
End Type

'mesh unknown
Private Type bsdmeshunkn '4 bytes
    u1 As Integer
    u2 As Integer
End Type

'mesh
Private Type bsdmesh
    vert() As bsdmeshvert   '
    un(0 To 104) As Byte    '
    facenum As Long         '16  (  4 bytes)
    face() As bsdmeshface   '    (256 bytes)
    unkn(0 To 72) As Byte   '    ( 72 bytes)
End Type

'--- P block ---------------------------------------------------------

'P block offset table
Private Type bsdPtable '20 bytes
    size As Long        'real size = size * 4 (RGBA)
    offset As Long      'real offset = 2048 + offset
    u1 As Long          '0
    u2 As Long          '0
    u3 As Long          '0
End Type

'P block data (RGBA?)
Private Type bsdPdata '4 bytes
    u1 As Byte
    u2 As Byte
    u3 As Byte
    u4 As Byte
End Type

'--- nodes --------------------------------------------------------------

'node table
Private Type bsdnodetable '8 bytes
    ptr As Long             '0
    offset As Long          'offset
End Type

'point
Private Type bsdpos '16 bytes
    x As Integer
    y As Integer
    z As Integer
    w As Integer
End Type

'node
'13B9 1130 ( 52 bytes) ladder point         (blue)
'46B6 7788 (108 bytes) default player spawn (yellow)
'3321 09FD ( 56 bytes) multi player spawn   (pink)
'7E92 12BD (104 bytes) item spawn           (green)
Public Type bsdnode '28? byte header
    id As Integer   '2 bytes
    u1 As Integer   '2 bytes
    size As Long    '4 bytes
    u2 As Long      '4 bytes
    u3 As Long      '4 bytes
    pos As bsdpos   '12 bytes
End Type

'--- file -----------------------------------------------------------------------

'file structure
Private Type bsdfile
    'offset lookup table
    Wnum As Long                    '@0    (4 bytes)
    Wdata(0 To 511 - 1) As Long     '@4    (2044 bytes)
    
    'TSP info header
    tsppath As String * 128         '@2048 (128 bytes)
    tspnum As Long
    u1 As Long
    u2 As Long
    u3 As Long
    
    'P data
    Pnum As Long
    Ptable(0 To 40 - 1) As bsdPtable
    Pdata() As bsdPdata
    
    'U data
    Unum As Long                    '@3496 (value = Wdata(0)+1 )
    'Udata() As bsdUblock           'totalsize=Unum*256
    
    'Y data
    nodenum As Long                 'number
    Yunknown As Long                '7308
    Ymask1 As Integer               'CCCC
    Ymask2 As Integer               'CCCC
    Ymask3 As Integer               'CCCC
    Ymask4 As Integer               'CCCC
    nodetable() As bsdnodetable     '...
    node() As bsdnode
    
End Type


Public bsd As bsdfile


'loads BSD file
Public Function LoadBsd(ByVal filename As String) As Boolean
Dim i As Long
Dim size As Long
Dim dummy() As Byte
    On Error GoTo errorhandler
    
    'open file
    Dim ff As Integer
    ff = FreeFile
    Open filename For Binary Access Read Lock Write As ff
    
    'info
    Echo "File Info"
    Echo " filename: " & filename
    Echo " filesize: " & LOF(ff)
    Echo ""
    
    'read W data @0 (2048 bytes)
    Echo " W block start at " & Loc(ff)
    Get ff, , bsd.Wnum    'number of entries in Wdata
    Get ff, , bsd.Wdata() 'seems to be valid offset table on SP levels
    Echo "  Wnum:       " & bsd.Wnum
    Echo " W block end at " & Loc(ff)
    Echo ""
    
    'read TSP path @2048 (128 bytes)
    Echo " TSP info header start at " & Loc(ff)
    Get ff, , bsd.tsppath
    Get ff, , bsd.tspnum    '9
    Get ff, , bsd.u1        '4
    Get ff, , bsd.u2        '1
    Get ff, , bsd.u3        '0
    Echo "  tsppath:    " & SafeStr(bsd.tsppath)
    Echo "  tspnum:     " & bsd.tspnum
    Echo "  u1:         " & bsd.u1
    Echo "  u2:         " & bsd.u2
    Echo "  u3:         " & bsd.u3
    Echo " TSP info header end at " & Loc(ff)
    Echo ""
    
    'read unknown @2192 (looks like 36 integers)
    Echo " unknown 72 bytes"
    ReDim dummy(0 To 72 - 1)
    Get ff, , dummy()
    Echo ""
    
    '@2264 (40*20=800 bytes)
    Echo " P block start at " & Loc(ff)
    Get ff, , bsd.Pnum                          '@2264
    Get ff, , bsd.Ptable()                      '@2268
    Echo "  Pnum:       " & bsd.Pnum
    size = 0
    For i = 0 To bsd.Pnum - 1
        Echo "  Ptable[" & i & "]:  " & bsd.Ptable(i).size
        size = size + bsd.Ptable(i).size
    Next i
    Echo "  total size: " & size & " (" & (size * 4) & " bytes)"
    Echo " P block end at " & Loc(ff)
    Echo ""
    
    'unknown @3086 (320 bytes)
    Echo " unknown 320 bytes at " & Loc(ff)
    ReDim dummy(0 To 320 - 1)
    Get ff, , dummy()
    Echo ""
    
    'unknown @3388 (104 bytes)
    Echo " unknown 104 bytes at " & Loc(ff)
    ReDim dummy(0 To 104 - 1)
    Get ff, , dummy()
    Echo ""
    
    'U data @3492 in 12_2 and 12_4.BSD
    Echo " U block starts at " & Loc(ff)
    Get ff, , bsd.Unum
    Echo "  Unum:       " & bsd.Unum
    ReDim dummy(0 To 256 - 1)
    For i = 0 To bsd.Unum - 1
        Get ff, , dummy()
    Next i
    Echo " U block ends at " & Loc(ff)
    Echo ""
    
    'P data
    Echo " Q block start at " & Loc(ff)
    For i = 0 To bsd.Pnum - 1
        size = bsd.Ptable(i).size * 4
        If size > 0 Then
            ReDim dummy(0 To size - 1)
            Get ff, , dummy()
        End If
        Echo "  " & size & " bytes"
    Next i
    Echo " Q block end at " & Loc(ff)
    Echo ""
    
    'Y data @9908
    Echo " node table start at " & Loc(ff)
    Get ff, , bsd.nodenum
    Get ff, , bsd.Yunknown
    Get ff, , bsd.Ymask1
    Get ff, , bsd.Ymask2
    Get ff, , bsd.Ymask3
    Get ff, , bsd.Ymask4
    ReDim bsd.nodetable(0 To bsd.nodenum - 1)
    Get ff, , bsd.nodetable()
    Echo "  nodenum:    " & bsd.nodenum
    Echo "  Yunknown:   " & bsd.Yunknown
    Echo " node table end at " & Loc(ff)
    Echo ""
    
    'read nodes
    Echo " nodes start at " & Loc(ff)
    ReDim bsd.node(0 To bsd.nodenum - 1)
    For i = 0 To bsd.nodenum - 1
        'read node header
        Get ff, , bsd.node(i)
        
        'read remaining bytes
        size = bsd.node(i).size - Len(bsd.node(i))
        ReDim dummy(0 To size - 1)
        Get ff, , dummy()
    Next i
    Echo " nodes end at " & Loc(ff)
    
    Echo ">>> stopped at " & Loc(ff)
    Echo ">>> size of file is " & LOF(ff)
    
    'close file
    Close ff
    
    LoadBsd = True
    Exit Function
errorhandler:
    MsgBox "LoadBsd" & vbLf & Err.Description, vbCritical
End Function


Public Sub DrawBsd()
    If bsd.Unum = 0 Then Exit Sub
    
Dim i As Long
    With bsd
        
        'draw nodes
        glPointSize 3
        If view_nodes Then
            glBegin GL_POINTS
            For i = 0 To .nodenum - 1
                Select Case .node(i).id
                Case 46662: glColor3f 1, 0.75, 0    'C
                Case 47379: glColor3f 0.5, 0.5, 1   'D
                Case 8499:  glColor3f 1, 0.5, 1     'B
                Case 37502: glColor3f 0.5, 1, 0.5   'A
                Case Else:  glColor3f 0.5, 0.5, 0.5 'unknown
                End Select
                
                glVertex3sv .node(i).pos.x
            Next i
            glEnd
        End If
                
    End With
End Sub
