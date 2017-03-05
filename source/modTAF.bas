Attribute VB_Name = "modTAF"
Option Explicit

Private Type timtexgl
    posx As Long
    posy As Long
    sizex As Long
    sizey As Long
    tex As GLuint
    
    bitscale As Integer
    lookupscale As Integer
    
    hasalpha As Boolean
End Type

Public timtexnum As Long
Public timtex(0 To 255) As timtexgl


Private Type tafchunkhead 'todo: merge with timhead, create generic header struct
    id As Integer
    ver As Integer
End Type


'loads TAF file
Public Function LoadTaf(ByVal filename As String) As Boolean
    'On Error GoTo errorhandler
    
    'open file
    Dim ff As Integer
    ff = FreeFile
    Open filename For Binary Access Read Lock Write As ff
    
    'info
    Echo "File Info"
    Echo " filename: " & filename
    Echo " filesize: " & LOF(ff)
    
    Dim i As Long
    Dim o As Long
    Dim r As Boolean
    Dim k As String
    Dim tafhead As tafchunkhead
    
    'read chunks
    Echo ">>> start of file at " & Loc(ff)
    r = True
    Do While r = True
        
        'chunk counter
        i = i + 1
        
        'Echo ">>> chunk " & i & " start at " & Loc(ff)
        
        'get chunk header
        Get ff, , tafhead
        
        'read chunk data
        Select Case tafhead.id
        Case 16: 'TIM chunk
            
            'Echo "TIM [" & i & "] " & (Loc(ff) - 4)
            
            Dim ofs As Long
            ofs = Loc(ff) - 4
            
            'Echo " TIM chunk"
            
            'copy chunk header to TIM
            tim.head.id = tafhead.id
            tim.head.ver = tafhead.ver
            
            'read tim data
            r = ReadTimData(ff, -1)
            If r Then
                'frmMain.picMain.Cls
                'DrawTim frmMain.picMain.hdc, 2, 2
                frmMain.stsMain.SimpleText = "TIM " & i
                
                CreateTimTexture
                
                DoEvents
                
                k = i & "@"
                frmMain.lsvMain.ListItems.Add , k, i & ".tim"
                frmMain.lsvMain.ListItems(k).SubItems(1) = Loc(ff) - ofs
                frmMain.lsvMain.ListItems(k).SubItems(2) = ofs
                frmMain.lsvMain.ListItems(k).SubItems(3) = "0"
            Else
                MsgBox "Invalid TIM", vbExclamation
            End If
            
        Case 4: '@372160
            
            Echo ">>> chunk at " & (Loc(ff) - 4)
            Echo "Non-TIM chunk"
            Echo " id:     " & tafhead.id
            Echo " ver:    " & tafhead.ver
            
            Dim headsize As Long
            Dim totalsize As Long
            Dim numvabs As Integer
            Dim u1 As Integer
            Dim u2 As Integer
            Dim u3 As Integer
            
            Get ff, , headsize  '20
            Get ff, , totalsize '245508 (VAB + 20 byte header)
            Get ff, , u1        '41524
            Get ff, , numvabs   '4
            Get ff, , u2        '61108
            Get ff, , u3        '4
            
            Echo " headsize:  " & headsize
            Echo " totalsize: " & totalsize
            Echo " numvabs:   " & numvabs
            Echo " u1:        " & u1
            Echo " u2:        " & u2
            
            '...
            
            frmMain.SelectTab 3
            Echo ">>> not further implemented, aborting..."
            r = False
            
        Case 1: 'file chunk
            
            Echo ">>> chunk at " & (Loc(ff) - 4)
            Echo "Non-TIM chunk"
            Echo " id:     " & tafhead.id
            Echo " ver:    " & tafhead.ver
            
            'read subtype
            Dim subtype As Long
            Get ff, , subtype
            Echo " subtype " & subtype
            
            Select Case subtype
            Case 8
                r = ReadVab(ff)
                If Not r Then
                    Echo "  ReadVab failed"
                End If
            Case Else
                Echo ">>> unknown subtype, aborting..."
                r = False
            End Select
            
        Case Else
            MsgBox "Unknown header " & tafhead.id & " at " & Loc(ff) & ".", vbExclamation
            r = False
        End Select
        
        'Echo ">>> chunk " & i & " end at " & Loc(ff)
        
        'end of file
        o = Loc(ff) - LOF(ff)
        If o = 0 Then r = False
        If o > 0 Then
            MsgBox "Overshot end of file by " & o & " bytes.", vbExclamation
        End If
    Loop
    Echo ">>> stopped at " & Loc(ff)
    Echo ">>> size of file is " & LOF(ff)
    
    'close file
    Close ff
    
    LoadTaf = True
    Exit Function
errorhandler:
    MsgBox "LoadTaf" & vbLf & Err.Description, vbCritical
End Function


Public Sub UnloadTaf()
Dim i As Long

    'unload textures
    For i = 0 To timtexnum - 1
        glDeleteTextures 1, timtex(i).tex
    Next i
    timtexnum = 0
    
End Sub


Public Sub DrawTaf()
Const s As Single = 1 / 256
Dim i As Long
Dim x As Single
Dim y As Single
Dim w As Single
Dim h As Single
    
    glDisable GL_DEPTH_TEST
    glPushMatrix
        glScalef s, 0, s
        
        glAlphaFunc GL_GREATER, 0.5
        glColor3f 1, 1, 1
        
        glEnable GL_TEXTURE_2D
        glEnable GL_ALPHA_TEST
        For i = 0 To timtexnum - 1
            
            x = timtex(i).posx
            y = timtex(i).posy
            w = timtex(i).sizex
            h = timtex(i).sizey
            
            glBindTexture GL_TEXTURE_2D, timtex(i).tex
            glBegin GL_QUADS
                glTexCoord2f 0, 0: glVertex3f x + 0, 0, y + 0
                glTexCoord2f 0, 1: glVertex3f x + 0, 0, y + h
                glTexCoord2f 1, 1: glVertex3f x + w, 0, y + h
                glTexCoord2f 1, 0: glVertex3f x + w, 0, y + 0
            glEnd
            
            'x = x + w + 0.01
            
        Next i
        glDisable GL_ALPHA_TEST
        glDisable GL_TEXTURE_2D
        
        'draw uvs
        Dim sx As Single
        Dim sy As Single
        Dim p As Long
        Dim j As Long
        glPointSize 3
        For i = 1 To tspnum
            With tsp(i)
                For j = 0 To .safefacenum - 1
                    'p = .face(j).u2
                    p = (.face(j).tsb And 31)
                    glColor3fv page(p).r
                    x = page(p).x
                    y = page(p).y
                    sx = page(p).w / 256
                    sy = page(p).h / 256
                    glBegin GL_LINE_LOOP
                        glVertex3f x + (.face(j).uv1.u * sx), 0, y + (.face(j).uv1.v * sy)
                        glVertex3f x + (.face(j).uv2.u * sx), 0, y + (.face(j).uv2.v * sy)
                        glVertex3f x + (.face(j).uv3.u * sx), 0, y + (.face(j).uv3.v * sy)
                    glEnd
                    glBegin GL_POINTS
                        glVertex3f .uvpnt(j).x, 0, .uvpnt(j).y
                    glEnd
                Next j
             End With
        Next i
        
        'draw page rects
        For i = 0 To pagenum - 1
            glBegin GL_LINE_LOOP
                glColor3f page(i).r, page(i).g, page(i).b
                glVertex3f page(i).x, 0, page(i).y
                glVertex3f page(i).x, 0, page(i).y + page(i).h
                glVertex3f page(i).x + page(i).w, 0, page(i).y + page(i).h
                glVertex3f page(i).x + page(i).w, 0, page(i).y
            glEnd
        Next i
        
    glPopMatrix
    glEnable GL_DEPTH_TEST
End Sub



Public Sub CreateTimTexture()
Dim i As Long

Dim frags As Long
Dim format As GLenum
Dim intformat As GLint

    'to many textures
    If timtexnum = 256 Then
        Echo "Cannot load more textures!"
        Exit Sub
    End If
    
    'create texture
    timtexnum = timtexnum + 1
    With timtex(timtexnum - 1)
        
        'create bitmap buffer
        TimCreateBitmap
        
        'copy data
        .posx = timbmp.posx
        .posy = timbmp.posy
        .sizex = timbmp.width
        .sizey = timbmp.height
        
        'select texture format
        Select Case timbmp.frags
        Case 3
            format = GL_RGB
            intformat = GL_RGB8
            .hasalpha = False
        Case 4
            format = GL_RGBA
            intformat = GL_RGBA8
            .hasalpha = True
            Echo "alpha!!!"
        End Select
        
        'create texture
        glGenTextures 1, .tex
        glBindTexture GL_TEXTURE_2D, .tex
        glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE
        glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE
        'glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST 'GL_LINEAR
        'glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST 'GL_LINEAR
        SetTexFilter .tex, view_filtering 'temp: neater way to do this?
        'glTexImage2D GL_TEXTURE_2D, 0, intformat, .sizex, .sizey, 0, format, _
        '             GL_UNSIGNED_BYTE, timbmp.data(0)
        gluBuild2DMipmaps GL_TEXTURE_2D, intformat, .sizex, .sizey, format, _
                          GL_UNSIGNED_BYTE, VarPtr(timbmp.data(0))
        
        'some hacks
        .sizex = timbmp.realwidth
        .bitscale = timbmp.width / timbmp.realwidth
    

    End With
End Sub
