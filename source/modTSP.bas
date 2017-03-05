Attribute VB_Name = "modTSP"
Option Explicit

Private Type tsphead    'off    val
    'file header (0-64)
    id As Integer       '0      1/1 (id)
    ver As Integer      '2      2/2 (version)
    
    'AABB tree (64-460)
    nodenum As Long      '4      13/46
    nodeoffset As Long   '8      64/64 (offset)
    
    'face block (460-1804)
    facenum As Long     '12     84/6     (block size / 16)
    faceoffset As Long  '16     460/1472 (offset)
    
    'vert block (1804-2564)
    vertnum As Long     '20     95/292    (block size / 8)
    vertoffset As Long  '24     1804/5648 (offset)
    
    'B block (2564-2564)
    Bnum As Long        '28     0/0
    Boffset As Long     '32     2564/7984 (offset)
    
    'color block (2564-2944)
    colornum As Long    '36     95/292    (block size / 4)
    coloroffset As Long '40     2564/7984 (offset)
    
    'C block (2944-2944)
    Cnum As Long        '44     0/0
    Coffset As Long     '48     2944/9152 (offset)
    
    'D block (2944-2944)
    Dnum As Long        '52     0/0
    Doffset As Long     '56     2944/9152 (offset)
    
    'collision data offset
    coloffset As Long   '60     2944/9152 (offset)
    
End Type

'--- AABB tree -----------------------------------------------------

Public Type tsppos '6 bytes
    x As Integer
    y As Integer
    z As Integer
End Type

Private Type tspaabb '12 bytes
    min As tsppos
    max As tsppos
End Type

Private Type tspnode '30 bytes
    aabb As tspaabb '6 bytes
    u1 As Long      'number of faces?
    u2 As Long      'subdiv flags?
    u3 As Long      'always 510
    u4 As Long      'face offset on 28, node offset on 36?
    
    s1 As Long      'subnode 1 offset
    s2 As Long      'subnode 2 offset
End Type

'--- visible geometry data -------------------------------------------------------

Private Type tspuv '2 bytes
    u As Byte
    v As Byte
End Type

Private Type tspface '16 bytes
    v1 As Integer   'vertex 1 index
    v2 As Integer   'vertex 2 index
    v3 As Integer   'vertex 3 index
    
    uv1 As tspuv    'vertex 1 texcoord
    
    cba As Integer
    'u1 As Byte      'unknown
    'u2 As Byte      'texture page index?
    
    uv2 As tspuv    'vertex 2 texcoord
    
    tsb As Integer
    'u3 As Byte      'unknown
    'u4 As Byte      'transparancy mode?
    
    uv3 As tspuv    'vertex 3 texcoord
End Type

Private Type tspvert '8 bytes
    x As Integer
    y As Integer
    z As Integer
    w As Integer
End Type

Private Type tspcolor '4 bytes
    r As Byte
    g As Byte
    b As Byte
    a As Byte
End Type

'--- D block -----------------------------------------------------

Private Type tspD '24 bytes
    size As Long        'size of this D block
    u1 As Long          '0/0/0
    u2 As Long          '0/0/0
    u3 As Long          'seems to be block number, random order
    u4 As Integer       '2/2/2
    datanum As Integer  '4/4/8
    u6 As Integer       '18/18/18
    u7 As Integer       '40/40/32
    data() As Integer   '*22
End Type

'--- collision data ----------------------------------------------

Private Type tspcolhead '18 bytes
    u1 As Integer
    u2 As Integer
    u3 As Integer
    u4 As Integer           'SM   BG
    Gnum As Integer         ' 15   31
    Hnum As Integer         '185  444
    vertnum As Integer      ' 86  162
    normalnum As Integer    '105  234
    facenum As Integer      '108  263
End Type

Private Type tspcolface '10 bytes
    v1 As Integer      'vertex index
    v2 As Integer      'vertex index
    v3 As Integer      'vertex index
    n As Integer       'normal index
    flag As Integer    'collision flags (ladder bits??)
End Type

Private Type tspcolG '8 bytes
    u1 As Integer
    u2 As Integer
    u3 As Integer
    u4 As Integer
End Type

Private Type tspcol 'collider chunk
    head As tspcolhead
    
    Gdata() As tspcolG      '8 byte stride
    Hdata() As Integer      '2 byte stride
    vert() As tspvert       '4 byte stride
    normal() As tspvert     '4 byte stride
    face() As tspcolface    '10 byte stride
End Type

'------------------------------------------------------------

Public Type vram_page
    x As Integer
    y As Integer
    w As Integer
    h As Integer
    
    r As Single
    g As Single
    b As Single
End Type
Public Const pagenum As Long = 256
Public page(0 To pagenum - 1) As vram_page

Private Type float2
    x As Single
    y As Single
End Type

Public Type face_uv
    t1 As float2
    t2 As float2
    t3 As float2
End Type

Private Type tspfile
    
    'header
    head As tsphead
    
    'octree
    node() As tspnode
    
    'visible level geometry
    face() As tspface
    vert() As tspvert
    'Bdata() As tspB
    color() As tspcolor
    'Cdata() As tspC
    Ddata() As tspD
    
    'collider chunk
    col As tspcol
    
    'internal
    safefacenum As Long
    timptr() As Integer
    faceuv() As face_uv
    uvpnt() As float2
End Type


Public tsp(1 To 15) As tspfile
Public tspnum As Long


'loads TSP file
Public Function LoadTsp(ByVal filename As String) As Boolean
    On Error GoTo errorhandler
    
Dim i As Long
    
    If tspnum = 15 Then
        MsgBox "All TSP slots in use, overwriting last!"
        'Exit Function
    End If
    
    tspnum = tspnum + 1
    With tsp(tspnum)
        
        'open file
        Dim ff As Integer
        ff = FreeFile
        Open filename For Binary Access Read Lock Write As ff
        
        'info
        Echo "File Info"
        Echo " filename: " & filename
        Echo " filesize: " & LOF(ff)
        
        'read file header
        Get ff, , .head
        
        'validate
        If Not .head.id = 1 Then
            MsgBox "File is not a TSP file.", vbExclamation
            Close ff
            Exit Function
        End If
        
        Echo "Header"
        Echo " nodenum:      " & .head.nodenum
        Echo " nodeoffset:   " & .head.nodeoffset
        Echo " facenum:      " & .head.facenum
        Echo " faceoffset:   " & .head.faceoffset
        Echo " vertnum:      " & .head.vertnum
        Echo " vertoffset:   " & .head.vertoffset
        Echo " Bnum:         " & .head.Bnum
        Echo " Boffset:      " & .head.Boffset
        Echo " colornum:     " & .head.colornum
        Echo " coloroffset:  " & .head.coloroffset
        Echo " Cnum:         " & .head.Cnum
        Echo " Coffset:      " & .head.Coffset
        Echo " Dnum:         " & .head.Dnum
        Echo " Doffset:      " & .head.Doffset
        Echo " coloffset:    " & .head.coloffset
        
        'alerts
        If .head.vertnum <> .head.colornum Then MsgBox "vertnum does not match colornum!"
        If .head.nodenum = 0 Then MsgBox "This file does not have A block!"
        If .head.Bnum > 0 Then MsgBox "This file has B block!"
        If .head.Cnum > 0 Then MsgBox "This file has C block!"
        
        'block sizes
        Echo ">>> B block size is " & .head.coloroffset - .head.Boffset
        Echo ">>> C block size is " & .head.Doffset - .head.Coffset
        Echo ">>> D block size is " & .head.coloffset - .head.Doffset
        
        'face check
        Dim fmissing As Long
        fmissing = .head.faceoffset + (.head.facenum * 16) - .head.vertoffset
        If fmissing > 0 Then
            Echo ">>> " & fmissing & " bytes of face data missing!"
            .safefacenum = (.head.vertoffset - .head.faceoffset) / 16
            Echo ">>> adjusted face number to " & .safefacenum
        Else
            .safefacenum = .head.facenum
        End If 'note: seems to be always power of two number!
        
        '--- AABB tree ------------------------------------------------------
        
        Echo ">>> start of node data at " & Loc(ff)
        ReDim .node(0 To .head.nodenum - 1)
        For i = 0 To .head.nodenum - 1
            Get ff, , .node(i).aabb
            Get ff, , .node(i).u1
            Get ff, , .node(i).u2
            Get ff, , .node(i).u3
            Get ff, , .node(i).u4
            If .node(i).u1 = 0 Then
                Get ff, , .node(i).s1
                Get ff, , .node(i).s2
            End If
        Next i
        Echo ">>> end of node data at " & Loc(ff)
        
        'Get ff, 1 + 64 + 0, .node(0).aabb: .node(0).p = True
        'If filename = "C:\Mijn documenten\psxtool\12_7_C2_sm.TSP" Then
        '    Get ff, 1 + 64 + 36, .node(1).aabb: .node(1).p = False
        '    Get ff, 1 + 64 + 64, .node(2).aabb: .node(2).p = False
        '    Get ff, 1 + 64 + 92, .node(3).aabb: .node(3).p = True
        '    Get ff, 1 + 64 + 128, .node(4).aabb: .node(4).p = False
        '    Get ff, 1 + 64 + 156, .node(5).aabb: .node(5).p = False
        '    Get ff, 1 + 64 + 184, .node(6).aabb: .node(6).p = True
        '    Get ff, 1 + 64 + 220, .node(7).aabb: .node(7).p = True
        '    Get ff, 1 + 64 + 256, .node(8).aabb: .node(8).p = False
        '    Get ff, 1 + 64 + 284, .node(9).aabb: .node(9).p = False
        '    Get ff, 1 + 64 + 312, .node(10).aabb: .node(10).p = False
        '    Get ff, 1 + 64 + 340, .node(11).aabb: .node(11).p = False
        '    Get ff, 1 + 64 + 368, .node(12).aabb: .node(12).p = False
        'End If
        
        '--- visible level geometry ---------------------------------------
        
        'load face data
        Echo ">>> start of face data at " & .head.faceoffset
        ReDim .face(0 To .head.facenum - 1)
        Get ff, 1 + .head.faceoffset, .face()
        Echo ">>> end of face data at " & Loc(ff)
        
        'load vertex data
        Echo ">>> start of vertex data at " & .head.vertoffset
        ReDim .vert(0 To .head.vertnum - 1)
        Get ff, 1 + .head.vertoffset, .vert()
        Echo ">>> end of vertex data at " & Loc(ff)
        
        'get vertex color data
        Echo ">>> start of color data at " & .head.coloroffset
        ReDim .color(0 To .head.colornum - 1)
        Get ff, 1 + .head.coloroffset, .color()
        Echo ">>> end of color data at " & Loc(ff)
        
        '--- D blocks -----------------------------------------------------
        
        Const readDblock = False
        If readDblock Then
            ReDim .Ddata(0 To .head.Dnum - 1)
            For i = 0 To .head.Dnum - 1
                Echo ">>> D block " & i & " start at " & Loc(ff)
                
                'read D block header
                Get ff, , .Ddata(i).size
                Get ff, , .Ddata(i).u1
                Get ff, , .Ddata(i).u2
                Get ff, , .Ddata(i).u3
                Get ff, , .Ddata(i).u4
                Get ff, , .Ddata(i).datanum
                Get ff, , .Ddata(i).u6
                Get ff, , .Ddata(i).u7
                Echo ">>>  size:     " & .Ddata(i).size
                Echo ">>>  datanum:  " & .Ddata(i).datanum
                
                'read D block stuff
                ReDim .Ddata(i).data(0 To (.Ddata(i).datanum * 11) - 1)
                Get ff, , .Ddata(i).data()
                
                Echo ">>> D " & i & " block ends at " & Loc(ff)
            Next i
        End If
        
        '--- collision data -----------------------------------------------
        
        'read collision chunk header
        Echo "Collision Header"
        Get ff, 1 + .head.coloffset, .col.head.u1
        Get ff, , .col.head.u2
        Get ff, , .col.head.u3
        Get ff, , .col.head.u4
        Get ff, , .col.head.Gnum
        Get ff, , .col.head.Hnum
        Get ff, , .col.head.vertnum
        Get ff, , .col.head.normalnum
        Get ff, , .col.head.facenum
        Echo " u1:           " & .col.head.u1
        Echo " u2:           " & .col.head.u2
        Echo " u3:           " & .col.head.u3
        Echo " u4:           " & .col.head.u4
        Echo " Gnum:         " & .col.head.Gnum
        Echo " Hnum:         " & .col.head.Hnum
        Echo " vertnum:      " & .col.head.vertnum
        Echo " normalnum:    " & .col.head.normalnum
        Echo " facenum:      " & .col.head.facenum
        
        Dim csize As Long
        csize = 18 'header
        csize = csize + (.col.head.Gnum * 8)      'G block
        csize = csize + (.col.head.Hnum * 2)      'H block
        csize = csize + (.col.head.vertnum * 8)   'vertices
        csize = csize + (.col.head.normalnum * 8) 'normals
        csize = csize + (.col.head.facenum * 10)  'faces
        Echo ">>> collision block size should be " & csize
        
        'read collision chunk data
        Dim dummy As Integer
        
        'collision G data
        ReDim .col.Gdata(0 To .col.head.Gnum - 1)
        Get ff, , .col.Gdata()
        Echo ">>> collision G data end at " & Loc(ff)
        
        'collision H data
        ReDim .col.Hdata(0 To .col.head.Hnum - 1)
        Get ff, , .col.Hdata()
        Echo ">>> collision H data end at " & Loc(ff)
        
        'align to 4 bytes
        If Loc(ff) Mod 4 > 0 Then
            Get ff, , dummy
            Echo ">>> adjusted aligment to " & Loc(ff)
        End If
        
        'collision vertices
        ReDim .col.vert(0 To .col.head.vertnum - 1)
        Get ff, , .col.vert()
        Echo ">>> collision vertices end at " & Loc(ff)
        
        'collision normals
        ReDim .col.normal(0 To .col.head.normalnum - 1)
        Get ff, , .col.normal()
        Echo ">>> collision normals end at " & Loc(ff)
        
        'collision faces
        ReDim .col.face(0 To .col.head.facenum - 1)
        Get ff, , .col.face()
        Echo ">>> collision faces end at " & Loc(ff)
        
        'align to 4 bytes
        If Loc(ff) Mod 4 > 0 Then
            Get ff, , dummy
            Echo ">>> adjusted aligment to " & Loc(ff)
        End If
            
        Echo ">>> file should end at " & Loc(ff)
        Echo ">>> size of file is " & LOF(ff)
        
        'close file
        Close ff
        
    End With
    Echo ""
    
    'check data
    TspIntegrityCheck tspnum
    
    'build table
    TspBuildTexLookupTable tspnum
    
    LoadTsp = True
    Exit Function
errorhandler:
    MsgBox "LoadTsp" & vbLf & Err.Description, vbCritical
End Function


'draws TSP data
Public Sub DrawTsp()
    'On Error GoTo errorhandler
    
    Dim t As Long
    Dim i As Long
    Dim tex As GLuint
    Dim prevtex As GLuint
    Dim v1 As Integer
    Dim v2 As Integer
    Dim v3 As Integer
    
    Dim alpha As Byte
    Dim blend As Long
    Dim alphatest As Boolean
    
    prevtex = 99999
    For t = 1 To tspnum
        With tsp(t)
            If .head.vertnum Then
                
                'draw faces
                glPolygonOffset 1, 1
                glAlphaFunc GL_GREATER, 0.5
                If view_colliders Then glEnable GL_POLYGON_OFFSET_FILL
                If view_textures Then glEnable GL_TEXTURE_2D
                For i = 0 To .safefacenum - 1
                    'get vert indices
                    v1 = .face(i).v1
                    v2 = .face(i).v2
                    v3 = .face(i).v3
                    
                    'blending
                    blend = (.face(i).tsb And 96) / 32
                    
                    'bind texture
                    If view_textures Then
                        If .timptr(i) > -1 Then
                            tex = timtex(.timptr(i)).tex
                            alphatest = timtex(.timptr(i)).hasalpha
                        Else
                            tex = dummytex
                        End If

                        If tex <> prevtex Then
                            glBindTexture GL_TEXTURE_2D, tex
                            prevtex = tex
                        End If
                    End If
                    
                    Select Case blend
                    Case 0
                        alpha = 255
                    Case 1:
                        glBlendFunc GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
                        alpha = 200
                    Case 2:
                        'used???
                        alpha = 255
                    End Select

                    If blend Then
                        glEnable GL_BLEND
                        glDepthMask False
                    End If
                    
                    If alphatest Then
                        'blend = 1
                        'glBlendFunc GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
                        'glEnable GL_BLEND
                        glEnable GL_ALPHA_TEST
                    End If

                    glBegin GL_TRIANGLES
                        If view_lighting Then
                            glColor4ub .color(v3).r, .color(v3).g, .color(v3).b, alpha
                        Else
                            glColor4ub 255, 255, 255, alpha
                        End If
                        
                        glTexCoord2fv .faceuv(i).t3.x
                        glVertex3sv .vert(v3).x
                        
                        If view_lighting Then glColor3ubv .color(v2).r
                        glTexCoord2fv .faceuv(i).t2.x
                        glVertex3sv .vert(v2).x
                        
                        If view_lighting Then glColor3ubv .color(v1).r
                        glTexCoord2fv .faceuv(i).t1.x
                        glVertex3sv .vert(v1).x
                    glEnd
                    If blend Then
                        glDepthMask True
                        glDisable GL_BLEND
                    End If
                    If alphatest Then
                        glDisable GL_ALPHA_TEST
                    End If
                Next i
                If view_textures Then glDisable GL_TEXTURE_2D
                If view_colliders Then glDisable GL_POLYGON_OFFSET_FILL
                
                'draw vertices
                If view_vertices Then
                    glColor3f 0, 0, 1
                    glPointSize 3
                    glBegin GL_POINTS
                        For i = 0 To .head.vertnum - 1
                            glVertex3f .vert(i).x, .vert(i).y, .vert(i).z
                        Next i
                    glEnd
                End If
                
                'draw AABB tree
                If view_aabbtree Then
                    For i = 0 To .head.nodenum - 1
                        If i = 0 Then
                            glLineWidth 2
                        Else
                            glLineWidth 1
                        End If
                        If .node(i).u1 = 0 Then
                            glColor3f 1, 0.5, 0
                        Else
                            glColor3f 1, 1, 0
                        End If
                        DrawBox .node(i).aabb.min, .node(i).aabb.max
                    Next i
                    glLineWidth 1
                End If
                
                'draw collision data
                If view_colliders Then
                    glColor3f 1, 0, 1
                    
                    If Not view_wire Then
                        glPolygonMode GL_FRONT_AND_BACK, GL_LINE
                    End If
                    
                    Dim n As Long
                    Dim p1x, p1y, p1z As Single
                    Dim p2x, p2y, p2z As Single
                    For i = 0 To .col.head.facenum - 1
                        v1 = .col.face(i).v1
                        v2 = .col.face(i).v2
                        v3 = .col.face(i).v3
                        n = .col.face(i).n
                        
                        'draw triangle
                        glBegin GL_TRIANGLES
                            glVertex3sv .col.vert(v3).x
                            glVertex3sv .col.vert(v2).x
                            glVertex3sv .col.vert(v1).x
                        glEnd
                        
                        'draw normal
                        'p1x = (CSng(.col.vert(v1).x) + CSng(.col.vert(v2).x) + CSng(.col.vert(v3).x)) / 3
                        'p1y = (CSng(.col.vert(v1).y) + CSng(.col.vert(v2).y) + CSng(.col.vert(v3).y)) / 3
                        'p1z = (CSng(.col.vert(v1).z) + CSng(.col.vert(v2).z) + CSng(.col.vert(v3).z)) / 3
                        'p2x = p1x + (CSng(.col.normal(n).x) / 255)
                        'p2y = p1y + (CSng(.col.normal(n).y) / 255)
                        'p2z = p1z + (CSng(.col.normal(n).z) / 255)
                        'glPointSize 3
                        'glBegin GL_POINTS
                        '    glVertex3f p1x, p1y, p1z
                        'glEnd
                        'glBegin GL_LINES
                        '    glVertex3f p1x, p1y, p1z
                        '    glVertex3f p2x, p2y, p2z
                        'glEnd
                    Next i
                    
                    If Not view_wire Then
                        glPolygonMode GL_FRONT_AND_BACK, GL_FILL
                    End If
                End If
                
            End If
        End With
    Next t
    
    Exit Sub
errorhandler:
    frmScene.stsMain.SimpleText = Err.Description
End Sub


'unloads tsp data
Public Sub UnloadTsp()
Dim t As Long
    For t = 1 To tspnum
        With tsp(t)
            Erase .face()
            Erase .vert()
            Erase .color()
        End With
    Next t
    tspnum = 0
    
    DrawGL
End Sub

'--- temp -----------------------------------------------------------------------------

Private Function ComputeUV(ByVal u As Single, ByVal v As Single, _
                           ByVal t As Long, ByVal p As Long) As float2
    
    u = u - ((timtex(t).posx - page(p).x) * timtex(t).bitscale)
    v = v - (timtex(t).posy - page(p).y)
    
    u = u / (timtex(t).sizex * timtex(t).bitscale)
    v = v / (timtex(t).sizey - 1)
    
    ComputeUV.x = u
    ComputeUV.y = v
End Function

'builds face texture index and uv arrays
Public Sub TspBuildTexLookupTable(ByVal tspindex As Long)
Dim u1, u2, u3 As Single
Dim v1, v2, v3 As Single
Dim minx As Long
Dim miny As Long
Dim maxx As Long
Dim maxy As Long
Dim cu As Single
Dim cv As Single
Dim i As Long
Dim j As Long
Dim p As Long 'page index
Dim t As Long 'texture index
Dim bits As Long 'texture bits (0=4, 1=8)
    
    'load page config file
    LoadPageConfig app_path & "\vram.ini"
    
Dim foo As Boolean
    With tsp(tspindex)
        frmMain.stsMain.SimpleText = "Building texture lookup table..."
        
        Echo ">>> building texture lookup table..."
        
        'allocate
        ReDim .timptr(0 To .safefacenum - 1)
        ReDim .faceuv(0 To .safefacenum - 1)
        ReDim .uvpnt(0 To .safefacenum - 1)
        
        'loop faces
        For i = 0 To .safefacenum - 1
            
            'reset texture index
            t = -1
            
            'get page index from face
            'p = .face(i).u2
            p = (.face(i).tsb And 31)
            bits = (.face(i).tsb And 448) / 128
            
            'get page space face UVs
            u1 = .face(i).uv1.u
            v1 = .face(i).uv1.v
            u2 = .face(i).uv2.u
            v2 = .face(i).uv2.v
            u3 = .face(i).uv3.u
            v3 = .face(i).uv3.v
            
            'compute UV triangle center point
            cu = (u1 + u2 + u3) / 3
            cv = (v1 + v2 + v3) / 3
            
            If bits Then
                cu = cu * 2
            End If
            
            'scale to [0-1] range
            cu = (cu / 255)
            cv = (cv / 255)
            
            'scale point to page space
            cu = cu * (page(p).w)
            cv = cv * (page(p).h - 1)
            
            'page offset
            cu = cu + page(p).x
            cv = cv + page(p).y
            
            '''' temp
            .uvpnt(i).x = cu
            .uvpnt(i).y = cv
            '''' temp
            
            'determine texture index with point test
            For j = 0 To timtexnum - 1
                minx = timtex(j).posx
                miny = timtex(j).posy
                maxx = timtex(j).posx + timtex(j).sizex '- 1
                maxy = timtex(j).posy + timtex(j).sizey - 1

                If cu >= minx Then
                If cu <= maxx Then
                    If cv >= miny Then
                    If cv <= maxy Then
                        t = j
                        Exit For
                    End If
                    End If
                End If
                End If
                
            Next j
            .timptr(i) = t
            
            'compute texture space UVs
            If t > -1 Then
                
                .faceuv(i).t1 = ComputeUV(u1, v1, t, p)
                .faceuv(i).t2 = ComputeUV(u2, v2, t, p)
                .faceuv(i).t3 = ComputeUV(u3, v3, t, p)
            Else
                .faceuv(i).t1.x = 0
                .faceuv(i).t1.y = 0
                .faceuv(i).t2.x = 0
                .faceuv(i).t2.y = 1
                .faceuv(i).t3.x = 1
                .faceuv(i).t3.y = 1
                
                '.faceuv(i).t1.x = (CSng(u1) - 96) / 64
                '.faceuv(i).t1.y = (CSng(v1) - 96) / 64
                '.faceuv(i).t2.x = (CSng(u2) - 96) / 64
                '.faceuv(i).t2.y = (CSng(v2) - 96) / 64
                '.faceuv(i).t3.x = (CSng(u3) - 96) / 64
                '.faceuv(i).t3.y = (CSng(v3) - 96) / 64
            End If
            
        Next i
        
        frmMain.stsMain.SimpleText = "Done."
    End With
End Sub

Public Sub TspIntegrityCheck(ByVal tspindex As Long)
    With tsp(tspindex)
        
        'face vertex indices range check
        Echo ">>> checking face range..."
        Dim i As Long
        Dim j As Long
        Dim ok As Boolean
        For i = 0 To .safefacenum - 1
            ok = True
            If .face(i).v1 < 0 Then ok = False
            If .face(i).v2 < 0 Then ok = False
            If .face(i).v3 < 0 Then ok = False
            If .face(i).v1 > .head.vertnum - 1 Then ok = False
            If .face(i).v2 > .head.vertnum - 1 Then ok = False
            If .face(i).v3 > .head.vertnum - 1 Then ok = False
            If ok = False Then
                Echo ">>>  face " & i & " vertex index out of range!"
            End If
        Next i
        
        'check if vertex is unused (out of curiousity)
        Echo ">>> checking vertex usage..."
        Dim used As Boolean
        For i = 0 To .head.vertnum - 1
            used = False
            For j = 0 To .head.facenum - 1
                If .face(j).v1 = i Then
                    used = True
                    Exit For
                End If
                If .face(j).v2 = i Then
                    used = True
                    Exit For
                End If
                If .face(j).v3 = i Then
                    used = True
                    Exit For
                End If
            Next j
            If Not used Then
                Echo ">>>  vertex " & i & " is not referenced!"
            End If
        Next i
        
        'check face unknown ranges
        'Echo ">>> checking face unknown range..."
        'Dim min As Long
        'Dim max As Long
        'min = 99999999
        'max = -99999999
        'For i = 0 To .safefacenum - 1
        '    If .face(i).u3 < min Then min = .face(i).u3
        '    If .face(i).u3 > max Then max = .face(i).u3
        'Next i
        'Echo ">>>  u3 min: " & min
        'Echo ">>>  u3 max: " & max
        
        'collision face indices range check
        Echo ">>> checking collision data..."
        Dim v_ok As Boolean
        Dim n_ok As Boolean
        Dim err_count As Long
        For i = 0 To .col.head.facenum - 1
            v_ok = True
            n_ok = True
            
            If .col.face(i).v1 < 0 Then v_ok = False
            If .col.face(i).v2 < 0 Then v_ok = False
            If .col.face(i).v3 < 0 Then v_ok = False
            If .col.face(i).v1 > .col.head.vertnum - 1 Then v_ok = False
            If .col.face(i).v2 > .col.head.vertnum - 1 Then v_ok = False
            If .col.face(i).v3 > .col.head.vertnum - 1 Then v_ok = False
            
            If .col.face(i).n < 0 Then n_ok = False
            If .col.face(i).n > .col.head.normalnum - 1 Then n_ok = False
            
            If Not v_ok Then Echo ">>>  collision face " & i & " vertex index out of range!"
            If Not n_ok Then Echo ">>>  collision face " & i & " normal index out of range!"
            
            If Not v_ok Or Not n_ok Then
                err_count = err_count + 1
                If err_count >= 50 Then
                    Echo ">>>  to many errors, no more warnings posted!"
                    Exit For
                End If
            End If
        Next i
        
        'print face text file
        Dim texpage As Long
        Dim blend As Long
        Dim bits As Long
        
        Dim str1 As String
        Dim str2 As String
        Dim ff As Integer
        ff = FreeFile
        Open app_path & "\facelist.txt" For Output As ff
        For i = 0 To .head.facenum - 1
            
            str1 = .face(i).uv1.u & "," & .face(i).uv1.v
            str2 = .face(i).uv2.u & "," & .face(i).uv2.v
            If Len(str1) < 8 Then str1 = str1 & Chr(9)
            If Len(str2) < 8 Then str2 = str2 & Chr(9)
            
            'Print #ff, "[" & i & "]" & Chr(9) & _
            '           .face(i).u1 & Chr(9) & _
            '           .face(i).u2 & Chr(9) & _
            '           .face(i).u3 & Chr(9) & _
            '           .face(i).u4 & Chr(9) & _
            '           str1 & Chr(9) & _
            '           str2 & Chr(9) & _
            '           .face(i).uv3.u & "," & .face(i).uv3.v
            
         texpage = (.face(i).tsb And 31)        'shift 0 bits
           blend = (.face(i).tsb And 96) / 32   'shift 5 bits (2^5)=32
            bits = (.face(i).tsb And 448) / 128 'shift 7 bits (2^7)=128
            
            Print #ff, "[" & i & "]" & Chr(9) & _
                       texpage & Chr(9) & _
                       blend & Chr(9) & _
                       bits & Chr(9) & _
                       str1 & Chr(9) & _
                       str2 & Chr(9) & _
                       .face(i).uv3.u & "," & .face(i).uv3.v
            
        Next i
        Close ff
        
    End With
End Sub


'draws wire box
Public Sub DrawBox(ByRef min As tsppos, ByRef max As tsppos)
    
    'bottom square
    glBegin GL_LINE_LOOP
        glVertex3f min.x, min.y, min.z
        glVertex3f min.x, min.y, max.z
        glVertex3f max.x, min.y, max.z
        glVertex3f max.x, min.y, min.z
    glEnd
    
    'top square
    glBegin GL_LINE_LOOP
        glVertex3f min.x, max.y, min.z
        glVertex3f min.x, max.y, max.z
        glVertex3f max.x, max.y, max.z
        glVertex3f max.x, max.y, min.z
    glEnd
    
    'vertical lines
    glBegin GL_LINES
        glVertex3f min.x, min.y, min.z
        glVertex3f min.x, max.y, min.z
        glVertex3f min.x, min.y, max.z
        glVertex3f min.x, max.y, max.z
        
        glVertex3f max.x, min.y, min.z
        glVertex3f max.x, max.y, min.z
        glVertex3f max.x, min.y, max.z
        glVertex3f max.x, max.y, max.z
    glEnd
End Sub

Public Sub LoadPageConfig(ByVal filename As String)
    On Error GoTo errorhandler
Dim p As Long
Dim ff As Long
Dim ln As String
Dim str() As String
    frmScene.stsMain.SimpleText = "Loading VRAM config file..."
    ff = FreeFile
    Open filename For Input As ff
    Do Until EOF(ff)
        Line Input #ff, ln
        If Len(ln) = 0 Then GoTo nextline
        If Left(ln, 1) = ";" Then GoTo nextline
        
        str = Split(ln, Chr(9))
        p = Val(str(0))
        
        If p < 0 Or p > pagenum - 1 Then
            Echo ">>> invalid page index in VRAM config file"
            GoTo nextline
        End If
        
        page(p).x = Val(str(1))
        page(p).y = Val(str(2))
        page(p).w = Val(str(3))
        page(p).h = Val(str(4))
        
        str = Split(str(5), "/")
        page(p).r = Val(str(0))
        page(p).g = Val(str(1))
        page(p).b = Val(str(2))
nextline:
    Loop
    Close ff
    Exit Sub
errorhandler:
    MsgBox "LoadPageConfig" & vbLf & Err.Description
End Sub
