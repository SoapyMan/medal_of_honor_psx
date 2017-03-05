Attribute VB_Name = "modScene"
Option Explicit

Public dummytex As GLuint

Public scene_scale As Single

Public view_wire As Boolean
Public view_axis As Boolean
Public view_grids As Boolean
Public view_lighting As Boolean
Public view_textures As Boolean
Public view_vertices As Boolean
Public view_aabbtree As Boolean
Public view_nodes As Boolean
Public view_colliders As Boolean
Public view_filtering As Boolean
Public view_pointsize As Single
Public view_uvs As Boolean

Public cam_panx As Single
Public cam_pany As Single
Public cam_rotx As Single
Public cam_roty As Single
Public cam_zoom As Single
Public cam_fov As Single
Public cam_asp As Single
Public cam_near As Single
Public cam_far As Single

Public facesel As Long

'draws scene
Public Sub DrawScene()
    
    'clear buffers
    glClearColor 0.25, 0.25, 0.25, 0
    glClear GL_COLOR_BUFFER_BIT Or GL_DEPTH_BUFFER_BIT
    
    'set up projection
    glMatrixMode GL_PROJECTION
    glLoadIdentity
    gluPerspective cam_fov, cam_asp, cam_near, cam_far
    
    'set up camera view
    glMatrixMode GL_MODELVIEW
    glLoadIdentity
    glTranslatef cam_panx, cam_pany, 0
    gluLookAt 0, 0, cam_zoom, _
              0, 0, 0, _
              0, 1, 0
    glRotatef cam_rotx, 1, 0, 0
    glRotatef cam_roty, 0, 1, 0
    
    
    'defaults
    glEnable GL_DEPTH_TEST
    glEnable GL_CULL_FACE
    
    'wireframe
    If view_wire Then
        glPolygonMode GL_FRONT_AND_BACK, GL_LINE
    Else
        glPolygonMode GL_FRONT_AND_BACK, GL_FILL
    End If
    
    'draw axis
    If view_axis Then
        glBegin GL_LINES
            glColor3f 1, 0, 0
            glVertex3f 0, 0, 0
            glVertex3f 1, 0, 0
            
            glColor3f 0, 1, 0
            glVertex3f 0, 0, 0
            glVertex3f 0, 1, 0
            
            glColor3f 0, 0, 1
            glVertex3f 0, 0, 0
            glVertex3f 0, 0, 1
        glEnd
    End If
    
    'draw grids
    If view_grids Then
        Dim i As Long
        For i = -10 To 10
            If i = 0 Then glColor3f 0, 0, 0 Else glColor3f 0.125, 0.125, 0.125
            glBegin GL_LINES
                glVertex3f -10, 0, i
                glVertex3f 10, 0, i
                glVertex3f i, 0, -10
                glVertex3f i, 0, 10
            glEnd
        Next i
    End If
    
    'test quad
    'glColor3f 1, 1, 1
    'glEnable GL_TEXTURE_2D
    'glBegin GL_QUADS
    '    glTexCoord2f 0, 0: glVertex3f 0, 0, 0
    '    glTexCoord2f 0, 1: glVertex3f 0, 0, 1
    '    glTexCoord2f 1, 1: glVertex3f 1, 0, 1
    '    glTexCoord2f 1, 0: glVertex3f 1, 0, 0
    'glEnd
    'glDisable GL_TEXTURE_2D
    
    'fog
    Dim fogcolor(0 To 3) As Single
    fogcolor(0) = 0.25
    fogcolor(1) = 0.25
    fogcolor(2) = 0.25
    fogcolor(3) = 0
    glFogfv GL_FOG_COLOR, fogcolor(0)
    glFogf GL_FOG_START, cam_near
    glFogf GL_FOG_END, cam_far
    glFogf GL_FOG_DENSITY, 1
    glFogi GL_FOG_MODE, GL_LINEAR
    glEnable GL_FOG
    
    'draw scene
    glPushMatrix
        glScalef scene_scale, scene_scale, scene_scale
        
        DrawTsp
        DrawBsd
        DrawXXX
        
    glPopMatrix
    
    If view_uvs Then DrawTaf
    
    glDisable GL_FOG
End Sub
