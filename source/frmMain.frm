VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "Comdlg32.ocx"
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.Form frmMain 
   Caption         =   "PsxTool"
   ClientHeight    =   4845
   ClientLeft      =   165
   ClientTop       =   450
   ClientWidth     =   6870
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
   Icon            =   "frmMain.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   323
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   458
   StartUpPosition =   2  'CenterScreen
   Begin MSComctlLib.ImageList imlMain 
      Left            =   4200
      Top             =   2520
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   16711935
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   6
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":1CFA
            Key             =   ""
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":1E0E
            Key             =   ""
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":1F22
            Key             =   ""
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":2036
            Key             =   ""
         EndProperty
         BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":214A
            Key             =   ""
         EndProperty
         BeginProperty ListImage6 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":225E
            Key             =   ""
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.Toolbar tlbMain 
      Align           =   1  'Align Top
      Height          =   360
      Left            =   0
      TabIndex        =   4
      Top             =   0
      Width           =   6870
      _ExtentX        =   12118
      _ExtentY        =   635
      ButtonWidth     =   609
      ButtonHeight    =   582
      Appearance      =   1
      Style           =   1
      ImageList       =   "imlMain"
      _Version        =   393216
      BeginProperty Buttons {66833FE8-8583-11D1-B16A-00C0F0283628} 
         NumButtons      =   8
         BeginProperty Button1 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "open"
            ImageIndex      =   1
         EndProperty
         BeginProperty Button2 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "close"
            ImageIndex      =   2
         EndProperty
         BeginProperty Button3 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Style           =   3
         EndProperty
         BeginProperty Button4 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "resource"
            ImageIndex      =   3
            Style           =   2
         EndProperty
         BeginProperty Button5 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "image"
            ImageIndex      =   4
            Style           =   2
            Value           =   1
         EndProperty
         BeginProperty Button6 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "log"
            ImageIndex      =   5
            Style           =   2
         EndProperty
         BeginProperty Button7 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Style           =   3
         EndProperty
         BeginProperty Button8 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "about"
            ImageIndex      =   6
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.StatusBar stsMain 
      Align           =   2  'Align Bottom
      Height          =   255
      Left            =   0
      TabIndex        =   3
      Top             =   4590
      Width           =   6870
      _ExtentX        =   12118
      _ExtentY        =   450
      Style           =   1
      _Version        =   393216
      BeginProperty Panels {8E3867A5-8586-11D1-B16A-00C0F0283628} 
         NumPanels       =   1
         BeginProperty Panel1 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.ListView lsvMain 
      Height          =   2415
      Left            =   120
      TabIndex        =   2
      Top             =   480
      Visible         =   0   'False
      Width           =   2775
      _ExtentX        =   4895
      _ExtentY        =   4260
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   -1  'True
      HideSelection   =   -1  'True
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   4
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "Filename"
         Object.Width           =   5292
      EndProperty
      BeginProperty ColumnHeader(2) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   1
         Text            =   "Size"
         Object.Width           =   1984
      EndProperty
      BeginProperty ColumnHeader(3) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   2
         Text            =   "Offset"
         Object.Width           =   1984
      EndProperty
      BeginProperty ColumnHeader(4) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   3
         Text            =   "Unknown"
         Object.Width           =   1984
      EndProperty
   End
   Begin VB.PictureBox picMain 
      AutoRedraw      =   -1  'True
      BackColor       =   &H8000000C&
      Height          =   1695
      Left            =   3120
      ScaleHeight     =   1635
      ScaleWidth      =   3315
      TabIndex        =   1
      Top             =   360
      Width           =   3375
   End
   Begin VB.TextBox txtLog 
      BackColor       =   &H80000018&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   9
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1335
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   0
      Top             =   3120
      Visible         =   0   'False
      Width           =   3615
   End
   Begin MSComDlg.CommonDialog cdlFile 
      Left            =   5640
      Top             =   2760
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.Menu mnuFile 
      Caption         =   "File"
      Begin VB.Menu mnuFileOpen 
         Caption         =   "Open..."
      End
      Begin VB.Menu mnuFileClose 
         Caption         =   "Close"
      End
      Begin VB.Menu mnuFileLine1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuFileRecent 
         Caption         =   "recent"
         Index           =   1
         Visible         =   0   'False
      End
      Begin VB.Menu mnuFileRecent 
         Caption         =   "recent"
         Index           =   2
         Visible         =   0   'False
      End
      Begin VB.Menu mnuFileRecent 
         Caption         =   "recent"
         Index           =   3
         Visible         =   0   'False
      End
      Begin VB.Menu mnuFileRecent 
         Caption         =   "recent"
         Index           =   4
         Visible         =   0   'False
      End
      Begin VB.Menu mnuFileRecentLine 
         Caption         =   "-"
         Visible         =   0   'False
      End
      Begin VB.Menu mnuFileExit 
         Caption         =   "Exit"
      End
   End
   Begin VB.Menu mnuView 
      Caption         =   "View"
      Begin VB.Menu mnuViewResource 
         Caption         =   "Resource"
      End
      Begin VB.Menu mnuViewImage 
         Caption         =   "Image"
      End
      Begin VB.Menu mnuViewLog 
         Caption         =   "Log"
      End
      Begin VB.Menu mnuViewLine1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuViewScene 
         Caption         =   "Scene"
      End
   End
   Begin VB.Menu mnuHelp 
      Caption         =   "Help"
      Begin VB.Menu mnuHelpAbout 
         Caption         =   "About..."
      End
   End
   Begin VB.Menu mnuResource 
      Caption         =   "Resource"
      Visible         =   0   'False
      Begin VB.Menu mnuResourceView 
         Caption         =   "View"
      End
      Begin VB.Menu mnuResourceExtract 
         Caption         =   "Extract..."
      End
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Const configfile = "\config.ini"
Private Const logheight As Long = 110

'--- form ---------------------------------------------------------

Private Sub Form_Load()
    
    'detect IDE
    app_idemode = IsIdeMode
    'If app_idemode Then
   '     app_path = "C:\Mijn documenten\psxtool"
   ' Else
        app_path = App.path
   ' End If
    
    'load config
    LoadConfig app_path & configfile
    
    'load scene form
    Load frmScene
    
    'command line
Dim cmd As String
    cmd = Replace(Command$(), Chr(34), "")
    If Len(cmd) Then
        OpenFile cmd
    Else
        UpdateGui
    End If
    
End Sub

Private Sub Form_Resize()
    If Not Me.WindowState = vbMinimized Then
        
        If Me.width < 400 * 15 Then Me.width = 400 * 15
        If Me.height < 300 * 15 Then Me.height = 300 * 15
        
        'Me.picMain.Move 2, 2, Me.ScaleWidth - 4, _
        '                Me.ScaleHeight - logheight - Me.stsMain.Height - 8
        'Me.lsvMain.Move 2, 2, Me.ScaleWidth - 4, _
        '                Me.ScaleHeight - logheight - Me.stsMain.Height - 8
        'Me.txtLog.Move 2, Me.ScaleHeight - logheight - Me.stsMain.Height - 2, _
        '               Me.ScaleWidth - 4, logheight
        
        Me.picMain.Move 2, Me.tlbMain.height + 4, _
                        Me.ScaleWidth - 4, _
                        Me.ScaleHeight - Me.tlbMain.height - Me.stsMain.height - 6
        Me.lsvMain.Move 2, Me.tlbMain.height + 4, _
                        Me.ScaleWidth - 4, _
                        Me.ScaleHeight - Me.tlbMain.height - Me.stsMain.height - 6
        Me.txtLog.Move 2, Me.tlbMain.height + 4, _
                       Me.ScaleWidth - 4, _
                       Me.ScaleHeight - Me.tlbMain.height - Me.stsMain.height - 6
    End If
End Sub

Private Sub Form_Unload(Cancel As Integer)
    SaveConfig app_path & configfile
    app_exit = True
    Unload frmScene
End Sub

'--- menu ----------------------------------------------------------

Private Sub mnuFileOpen_Click()
    With Me.cdlFile
        .DialogTitle = "Open File"
        .filter = "BIN Files (*.bin)|*.bin" & _
                  "|BSD Files (*.bsd)|*.bsd" & _
                  "|GFX Files (*.gfx)|*.gfx" & _
                  "|PAL Files (*.pal)|*.pal" & _
                  "|RSC Files (*.rsc)|*.rsc" & _
                  "|TAF Files (*.taf)|*.taf" & _
                  "|TIM Files (*.tim)|*.tim" & _
                  "|TSP Files (*.tsp)|*.tsp" & _
                  "|VAB Files (*.vab)|*.vab" & _
                  "|VB Files (*.vb)|*.vb" & _
                  "|All Files (*.*)|*.*"
        .FilterIndex = current_filter
        .Flags = cdlOFNFileMustExist
        .filename = current_file
        .InitDir = current_path
        .CancelError = True
        On Error Resume Next
        .ShowOpen
        DoEvents
        If Err.Number <> cdlCancel Then
            On Error GoTo 0
            
            current_filter = .FilterIndex
            OpenFile .filename
        End If
    End With
End Sub

Private Sub mnuFileClose_Click()
    CloseFile
End Sub

Private Sub mnuFileRecent_Click(index As Integer)
    'CloseFile
    OpenFile recent_file(index)
End Sub

Private Sub mnuFileExit_Click()
    Unload Me
End Sub

Private Sub mnuViewResource_Click()
    SelectTab 1
End Sub

Private Sub mnuViewImage_Click()
    SelectTab 2
End Sub

Private Sub mnuViewLog_Click()
    SelectTab 3
End Sub

Private Sub mnuViewScene_Click()
    frmScene.Show
End Sub

Private Sub mnuHelpAbout_Click()
    MsgBox App.Title & " " & App.Major & "." & App.Minor & "." & App.Revision & vbLf & _
           "By Martijn Buijs, 2007", vbInformation
End Sub

Private Sub tlbMain_ButtonClick(ByVal Button As MSComctlLib.Button)
    Select Case Button.Key
    Case "open":        mnuFileOpen_Click
    Case "close":       mnuFileClose_Click
    Case "resource":    SelectTab 1
    Case "image":       SelectTab 2
    Case "log":         SelectTab 3
    Case "about":       mnuHelpAbout_Click
    End Select
End Sub

'--- resource ------------------------------------------------------

Private Sub lsvMain_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
Dim px As Long
Dim py As Long
    If Button = 2 Then
        lsvMain.SelectedItem = lsvMain.HitTest(x, y)
        If Not lsvMain.SelectedItem Is Nothing Then
            px = lsvMain.Left + (x / 15)
            py = lsvMain.Top + (y / 15)
            PopupMenu Me.mnuResource, , px, py
        End If
    End If
End Sub

Private Sub lsvMain_DblClick()
    mnuResourceView_Click
End Sub

Private Sub mnuResourceView_Click()
    Dim n As Long

    n = Val(Me.lsvMain.SelectedItem.Key)
    
    If rsc.root.num > 0 Then
        If n < 1 Or n > rsc.root.num Then Exit Sub
    End If
    
    Dim ext As String
    ext = LCase(Right(Me.lsvMain.SelectedItem.Text, 3)) 'LCase(Right(SafeStr(rsc.node(n).filename), 3))
    Select Case ext
    Case "tim"
        Echo "read file " & current_file
        ViewTim current_file, Me.lsvMain.SelectedItem.SubItems(2) 'rsc.node(n).offset
        SelectTab 2
    Case Else
        'todo?
    End Select
End Sub

Private Sub mnuResourceExtract_Click()
    Dim n As Long
    n = Val(Me.lsvMain.SelectedItem.Key)

    If rsc.root.num > 0 Then
        If n < 1 Or n > rsc.root.num Then Exit Sub
    End If
    
    With Me.cdlFile
        .DialogTitle = "Extract"
        .filter = "All Files (*.*)|*.*"
        .FilterIndex = 0
        .Flags = cdlOFNOverwritePrompt Or cdlOFNNoReadOnlyReturn
        .filename = FileFromFilePath(Me.lsvMain.SelectedItem.Text)
        .InitDir = current_path
        .CancelError = True
        On Error Resume Next
        .ShowSave
        DoEvents
        If Err.Number <> cdlCancel Then
            On Error GoTo 0
            
            ExtractFile current_file, .filename, _
                        Me.lsvMain.SelectedItem.SubItems(2), Me.lsvMain.SelectedItem.SubItems(1)
            
        End If
    End With
End Sub

'--- misc ----------------------------------------------------------

Public Sub SelectTab(ByVal index As Long)
    Select Case index
    Case 1
        Me.lsvMain.Visible = True
        Me.picMain.Visible = False
        Me.txtLog.Visible = False
        Me.mnuViewResource.Checked = True
        Me.mnuViewImage.Checked = False
        Me.mnuViewLog.Checked = False
        Me.tlbMain.Buttons("resource").Value = tbrPressed
    Case 2
        Me.lsvMain.Visible = False
        Me.picMain.Visible = True
        Me.txtLog.Visible = False
        Me.mnuViewResource.Checked = False
        Me.mnuViewImage.Checked = True
        Me.mnuViewLog.Checked = False
        Me.tlbMain.Buttons("image").Value = tbrPressed
    Case 3
        Me.lsvMain.Visible = False
        Me.picMain.Visible = False
        Me.txtLog.Visible = True
        Me.mnuViewResource.Checked = False
        Me.mnuViewImage.Checked = False
        Me.mnuViewLog.Checked = True
        Me.tlbMain.Buttons("log").Value = tbrPressed
    End Select
End Sub

Private Sub OpenFile(ByRef filename As String)
    Dim ext As String
    ext = LCase(FileExtension(filename))
    Select Case ext
    Case "rsc"
        CloseFile
        printdebug = True
        SelectTab 1
        LoadRsc filename
    Case "tim"
        CloseFile
        printdebug = True
        SelectTab 2
        LoadTim filename
    Case "taf"
        CloseFile
        printdebug = False
        SelectTab 2
        LoadTaf filename
    Case "tsp"
        printdebug = True
        SelectTab 3
        LoadTsp filename
    Case "bsd"
        printdebug = True
        SelectTab 3
        If MsgBox("Use BSD loader?", vbYesNo) = vbYes Then
            LoadBsd filename
        Else
            LoadXXX filename
        End If
    Case "vab"
        CloseFile
        printdebug = True
        SelectTab 3
        LoadVab filename
    'Case "vb"
        'todo
    Case "pal"
        CloseFile
        printdebug = True
        SelectTab 2
        LoadPal filename
    Case Else
        CloseFile
        printdebug = True
        SelectTab 3
        LoadXXX filename
    End Select
    
    'update GUI
    If filename <> recent_file(1) Then
        recent_file(4) = recent_file(3)
        recent_file(3) = recent_file(2)
        recent_file(2) = recent_file(1)
    End If
    recent_file(1) = filename
    
    current_file = filename
    current_path = filename
        
    UpdateGui
End Sub

Private Sub CloseFile()
    'unload stuff
    'unloadpal
    'unloadrsc
    UnloadTaf
    'UnloadTim
    UnloadTsp
    'unloadvab
    'unloadxxx
    
    'reset GUI
    current_file = ""
    Me.picMain.Cls
    Me.txtLog.Text = ""
    Me.lsvMain.ListItems.Clear
    UpdateGui
End Sub

Private Sub UpdateGui()
Dim str As String
    str = App.Title & " " & App.Major & "." & App.Minor & "." & App.Revision
    If Len(current_file) Then
        str = str & " - [" & current_file & "]"
    End If
    Me.Caption = str
    
    If Len(recent_file(1)) Then
        mnuFileRecentLine.Visible = True
        mnuFileRecent(1).Visible = True
        mnuFileRecent(1).Caption = "1 " & recent_file(1)
    End If
    If Len(recent_file(2)) Then
        mnuFileRecent(2).Visible = True
        mnuFileRecent(2).Caption = "2 " & recent_file(2)
    End If
    If Len(recent_file(3)) Then
        mnuFileRecent(3).Visible = True
        mnuFileRecent(3).Caption = "3 " & recent_file(3)
    End If
    If Len(recent_file(4)) Then
        mnuFileRecent(4).Visible = True
        mnuFileRecent(4).Caption = "4 " & recent_file(4)
    End If
End Sub

