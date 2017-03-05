VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.Form frmScene 
   Caption         =   "Scene"
   ClientHeight    =   5790
   ClientLeft      =   60
   ClientTop       =   630
   ClientWidth     =   7980
   BeginProperty Font 
      Name            =   "Tahoma"
      Size            =   8.25
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   HasDC           =   0   'False
   Icon            =   "frmScene.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   386
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   532
   StartUpPosition =   2  'CenterScreen
   Begin MSComctlLib.StatusBar stsMain 
      Align           =   2  'Align Bottom
      Height          =   255
      Left            =   0
      TabIndex        =   1
      Top             =   5535
      Width           =   7980
      _ExtentX        =   14076
      _ExtentY        =   450
      Style           =   1
      _Version        =   393216
      BeginProperty Panels {8E3867A5-8586-11D1-B16A-00C0F0283628} 
         NumPanels       =   1
         BeginProperty Panel1 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
         EndProperty
      EndProperty
   End
   Begin VB.PictureBox picMain 
      BackColor       =   &H00404040&
      BorderStyle     =   0  'None
      Height          =   2175
      Left            =   240
      ScaleHeight     =   145
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   233
      TabIndex        =   0
      Top             =   240
      Width           =   3495
   End
   Begin VB.Menu mnuScene 
      Caption         =   "Scene"
      Begin VB.Menu mnuSceneExplorer 
         Caption         =   "Show Explorer"
      End
      Begin VB.Menu mnuSceneLine1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuSceneClose 
         Caption         =   "Close"
      End
   End
   Begin VB.Menu mnuView 
      Caption         =   "View"
      Begin VB.Menu mnuViewWire 
         Caption         =   "Wireframe"
      End
      Begin VB.Menu mnuViewLine1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuViewAxis 
         Caption         =   "Axis"
         Checked         =   -1  'True
      End
      Begin VB.Menu mnuViewGrids 
         Caption         =   "Grids"
         Checked         =   -1  'True
      End
      Begin VB.Menu mnuViewLine3 
         Caption         =   "-"
      End
      Begin VB.Menu mnuViewLighting 
         Caption         =   "Lighting"
         Checked         =   -1  'True
      End
      Begin VB.Menu mnuViewTextures 
         Caption         =   "Textures"
         Checked         =   -1  'True
      End
      Begin VB.Menu mnuViewVertices 
         Caption         =   "Vertices"
      End
      Begin VB.Menu mnuViewAABBTree 
         Caption         =   "AABB Tree"
      End
      Begin VB.Menu mnuViewNodes 
         Caption         =   "Scene Nodes"
      End
      Begin VB.Menu mnuViewColliders 
         Caption         =   "Collision Geometry"
      End
      Begin VB.Menu mnuViewLine4 
         Caption         =   "-"
      End
      Begin VB.Menu mnuViewFiltering 
         Caption         =   "Texture Filtering"
         Checked         =   -1  'True
      End
      Begin VB.Menu mnuViewLine2 
         Caption         =   "-"
      End
      Begin VB.Menu mnuViewSetScale 
         Caption         =   "Scale..."
      End
      Begin VB.Menu mnuViewPointSize 
         Caption         =   "Point Size..."
      End
   End
   Begin VB.Menu mnuTools 
      Caption         =   "Tools"
      Begin VB.Menu mnuToolsRemap 
         Caption         =   "Remap Textures"
      End
      Begin VB.Menu mnuToolsLine1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuToolsUVs 
         Caption         =   "Show UV map"
      End
   End
   Begin VB.Menu mnuHelp 
      Caption         =   "Help"
      Begin VB.Menu mnuHelpInfo 
         Caption         =   "Info..."
      End
   End
End
Attribute VB_Name = "frmScene"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private mouse_down As Boolean
Private mouse_x As Single
Private mouse_y As Single

'--- form -------------------------------------------------------------------------------------

Private Sub Form_Load()
    
    scene_scale = 0.001
    
    xxx_base = 0
    xxx_stride = 4
    xxx_offsetx = 0
    xxx_offsety = 1
    xxx_offsetz = 2
    xxx_selstart = 0
    xxx_selend = 0
    xxx_3d = True
    
    view_wire = Me.mnuViewWire.Checked
    view_axis = Me.mnuViewAxis.Checked
    view_grids = Me.mnuViewGrids.Checked
    view_lighting = Me.mnuViewLighting.Checked
    view_textures = Me.mnuViewTextures.Checked
    view_vertices = Me.mnuViewVertices.Checked
    view_nodes = Me.mnuViewNodes.Checked
    view_aabbtree = Me.mnuViewAABBTree.Checked
    view_colliders = Me.mnuViewColliders.Checked
    view_filtering = Me.mnuViewFiltering.Checked
    view_uvs = Me.mnuToolsUVs.Checked
    view_pointsize = 2
    
    cam_rotx = 90
    cam_roty = 0
    cam_zoom = 15
    cam_fov = 50
    cam_asp = 1
    cam_near = 0.1
    cam_far = 1000
    
    InitGL Me.picMain.hdc
    
    dummytex = LoadTGA(app_path & "\default.tga")
    
End Sub

Private Sub Form_Resize()
    If Not Me.WindowState = vbMinimized Then
    
        If Me.width < 400 * 15 Then Me.width = 400 * 15
        If Me.height < 300 * 15 Then Me.height = 300 * 15
    
        Me.picMain.Move 1, 1, Me.ScaleWidth - 3, Me.ScaleHeight - Me.stsMain.height - 3
    End If
End Sub

Private Sub picMain_KeyDown(KeyCode As Integer, Shift As Integer)
    Select Case KeyCode
    Case vbKeyUp
        facesel = facesel + 1
        Me.stsMain.SimpleText = "Face " & facesel
    Case vbKeyDown
        facesel = facesel - 1
        Me.stsMain.SimpleText = "Face " & facesel
    End Select
    
    DrawGL
End Sub

Private Sub picMain_Resize()
    ResizeGL picMain.ScaleWidth, picMain.ScaleHeight
    cam_asp = picMain.ScaleWidth / picMain.ScaleHeight
    DrawGL
End Sub

Private Sub picMain_Paint()
    DrawGL
End Sub

Private Sub Form_Unload(Cancel As Integer)
    If Not app_exit Then
        Cancel = True
        Me.Hide
        frmExplorer.Hide
        Exit Sub
    End If
    
    KillGL
    Unload frmExplorer
End Sub

'--- menu -------------------------------------------------------------------------------------

Private Sub mnuSceneExplorer_Click()
    frmExplorer.Show
End Sub

Private Sub mnuSceneClose_Click()
    Unload Me
End Sub

Private Sub mnuViewWire_Click()
    view_wire = Not view_wire
    mnuViewWire.Checked = view_wire
    DrawGL
End Sub

Private Sub mnuViewAxis_Click()
    view_axis = Not view_axis
    mnuViewAxis.Checked = view_axis
    DrawGL
End Sub

Private Sub mnuViewGrids_Click()
    view_grids = Not view_grids
    mnuViewGrids.Checked = view_grids
    DrawGL
End Sub

Private Sub mnuViewLighting_Click()
    view_lighting = Not view_lighting
    mnuViewLighting.Checked = view_lighting
    DrawGL
End Sub

Private Sub mnuViewTextures_Click()
    view_textures = Not view_textures
    mnuViewTextures.Checked = view_textures
    DrawGL
End Sub

Private Sub mnuViewVertices_Click()
    view_vertices = Not view_vertices
    mnuViewVertices.Checked = view_vertices
    DrawGL
End Sub

Private Sub mnuViewAABBTree_Click()
    view_aabbtree = Not view_aabbtree
    mnuViewAABBTree.Checked = view_aabbtree
    DrawGL
End Sub

Private Sub mnuViewNodes_Click()
    view_nodes = Not view_nodes
    mnuViewNodes.Checked = view_nodes
    DrawGL
End Sub

Private Sub mnuViewColliders_Click()
    view_colliders = Not view_colliders
    mnuViewColliders.Checked = view_colliders
    DrawGL
End Sub

Private Sub mnuViewFiltering_Click()
    view_filtering = Not view_filtering
    mnuViewFiltering.Checked = view_filtering
    
    SetTexFilter dummytex, view_filtering
    
    Dim i As Long
    For i = 0 To timtexnum - 1
        SetTexFilter timtex(i).tex, view_filtering
    Next i
    
    DrawGL
End Sub

Private Sub mnuViewSetScale_Click()
Dim str As Single
    str = InputBox("Scene scale:", "Scene Scale", scene_scale)
    If Len(str) > 0 Then
        scene_scale = Val(str)
    End If
    DrawGL
End Sub

Private Sub mnuViewPointSize_Click()
Dim str As Single
    str = InputBox("Point size:", "Point size", view_pointsize)
    If Len(str) > 0 Then
        view_pointsize = Val(str)
    End If
    DrawGL
End Sub

Private Sub mnuToolsRemap_Click()
Dim i As Long
    For i = 1 To tspnum
        TspBuildTexLookupTable i
    Next i
    DrawGL
End Sub

Private Sub mnuToolsUVs_Click()
    view_uvs = Not view_uvs
    mnuToolsUVs.Checked = view_uvs
    DrawGL
End Sub

Private Sub mnuHelpInfo_Click()
Dim ptr As Long
Dim str As String
Dim msg As String
    
    ptr = glGetString(GL_VENDOR)
    str = CharToString(ptr)
    msg = "Vendor: " & str
    
    ptr = glGetString(GL_RENDERER)
    str = CharToString(ptr)
    msg = msg & vbLf & "Renderer: " & str
    
    ptr = glGetString(GL_VERSION)
    str = CharToString(ptr)
    msg = msg & vbLf & "Version: " & str
    
    ptr = glGetString(GL_EXTENSIONS)
    str = CharToString(ptr)
    msg = msg & vbLf & str
    
    MsgBox msg, vbInformation
End Sub

'--- viewport ---------------------------------------------------------------------------------

Private Sub picMain_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
    mouse_down = True
    mouse_x = x
    mouse_y = y
End Sub

Private Sub picMain_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
    If mouse_down Then
        
        If Button = 1 Then
            cam_roty = cam_roty + ((x - mouse_x) * 0.25)
            cam_rotx = cam_rotx + ((y - mouse_y) * 0.25)
            If cam_rotx > 360 Then cam_rotx = cam_rotx - 360
            If cam_roty > 360 Then cam_roty = cam_roty - 360
            If cam_rotx < 0 Then cam_rotx = cam_rotx + 360
            If cam_roty < 0 Then cam_roty = cam_roty + 360
        End If
        If Button = 2 Then
            cam_zoom = cam_zoom + ((y - mouse_y) * 0.125)
            If cam_zoom < cam_near Then cam_zoom = cam_near
            If cam_zoom > cam_far Then cam_zoom = cam_far
        End If
        If Button = 4 Then
            cam_panx = cam_panx + ((x - mouse_x) * 0.01)
            cam_pany = cam_pany - ((y - mouse_y) * 0.01)
        End If
        
        DrawGL
    End If
    mouse_x = x
    mouse_y = y
End Sub

Private Sub picMain_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)
    mouse_down = False
    mouse_x = x
    mouse_y = y
End Sub

