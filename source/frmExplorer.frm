VERSION 5.00
Begin VB.Form frmExplorer 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Explorer"
   ClientHeight    =   3015
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   3615
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
   Icon            =   "frmExplorer.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   201
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   241
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox txtFileOffsetEnd 
      Height          =   285
      Left            =   2400
      TabIndex        =   19
      Text            =   "0"
      Top             =   2280
      Width           =   1095
   End
   Begin VB.TextBox txtFileOffsetStart 
      Height          =   285
      Left            =   2400
      TabIndex        =   18
      Text            =   "0"
      Top             =   1920
      Width           =   1095
   End
   Begin VB.OptionButton optDims 
      Caption         =   "3D"
      Height          =   255
      Index           =   1
      Left            =   2040
      TabIndex        =   16
      Top             =   2640
      Value           =   -1  'True
      Width           =   495
   End
   Begin VB.OptionButton optDims 
      Caption         =   "2D"
      Height          =   255
      Index           =   0
      Left            =   1440
      TabIndex        =   15
      Top             =   2640
      Width           =   495
   End
   Begin VB.TextBox txtBase 
      Height          =   285
      Left            =   1440
      TabIndex        =   14
      Text            =   "0"
      Top             =   120
      Width           =   855
   End
   Begin VB.CommandButton cmdApply 
      Caption         =   "Apply"
      Height          =   375
      Left            =   2400
      TabIndex        =   12
      Top             =   120
      Width           =   1095
   End
   Begin VB.TextBox txtSelEnd 
      Height          =   285
      Left            =   1440
      TabIndex        =   10
      Text            =   "0"
      Top             =   2280
      Width           =   855
   End
   Begin VB.TextBox txtSelStart 
      Height          =   285
      Left            =   1440
      TabIndex        =   9
      Text            =   "0"
      Top             =   1920
      Width           =   855
   End
   Begin VB.TextBox txtOffsetZ 
      Height          =   285
      Left            =   1440
      TabIndex        =   8
      Text            =   "0"
      Top             =   1200
      Width           =   855
   End
   Begin VB.TextBox txtOffsetY 
      Height          =   285
      Left            =   1440
      TabIndex        =   7
      Text            =   "0"
      Top             =   840
      Width           =   855
   End
   Begin VB.TextBox txtOffsetX 
      Height          =   285
      Left            =   1440
      TabIndex        =   6
      Text            =   "0"
      Top             =   480
      Width           =   855
   End
   Begin VB.TextBox txtStride 
      Height          =   285
      Left            =   1440
      TabIndex        =   5
      Text            =   "0"
      Top             =   1560
      Width           =   855
   End
   Begin VB.Label labStrideBytes 
      Caption         =   "8 bytes"
      Height          =   255
      Left            =   2400
      TabIndex        =   20
      Top             =   1560
      Width           =   1095
   End
   Begin VB.Label labMisc 
      AutoSize        =   -1  'True
      Caption         =   "Dimensions:"
      Height          =   195
      Index           =   7
      Left            =   120
      TabIndex        =   17
      Top             =   2640
      Width           =   855
   End
   Begin VB.Label labMisc 
      AutoSize        =   -1  'True
      Caption         =   "Base:"
      Height          =   195
      Index           =   6
      Left            =   120
      TabIndex        =   13
      Top             =   120
      Width           =   405
   End
   Begin VB.Label labMisc 
      AutoSize        =   -1  'True
      Caption         =   "Selection End:"
      Height          =   195
      Index           =   5
      Left            =   120
      TabIndex        =   11
      Top             =   2280
      Width           =   1020
   End
   Begin VB.Label labMisc 
      AutoSize        =   -1  'True
      Caption         =   "Selection Start:"
      Height          =   195
      Index           =   4
      Left            =   120
      TabIndex        =   4
      Top             =   1920
      Width           =   1110
   End
   Begin VB.Label labMisc 
      AutoSize        =   -1  'True
      Caption         =   "Offset Z:"
      Height          =   195
      Index           =   3
      Left            =   120
      TabIndex        =   3
      Top             =   1200
      Width           =   660
   End
   Begin VB.Label labMisc 
      AutoSize        =   -1  'True
      Caption         =   "Offset Y:"
      Height          =   195
      Index           =   2
      Left            =   120
      TabIndex        =   2
      Top             =   840
      Width           =   660
   End
   Begin VB.Label labMisc 
      AutoSize        =   -1  'True
      Caption         =   "Offset X:"
      Height          =   195
      Index           =   1
      Left            =   120
      TabIndex        =   1
      Top             =   480
      Width           =   660
   End
   Begin VB.Label labMisc 
      AutoSize        =   -1  'True
      Caption         =   "Stride:"
      Height          =   195
      Index           =   0
      Left            =   120
      TabIndex        =   0
      Top             =   1560
      Width           =   480
   End
End
Attribute VB_Name = "frmExplorer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Form_Load()
    Me.txtBase.Text = xxx_base
    Me.txtStride.Text = xxx_stride
    Me.txtOffsetX.Text = xxx_offsetx
    Me.txtOffsetY.Text = xxx_offsety
    Me.txtOffsetZ.Text = xxx_offsetz
    Me.txtSelStart.Text = xxx_selstart
    Me.txtSelEnd.Text = xxx_selend
    Me.optDims(0).Value = Not xxx_3d
    Me.optDims(1).Value = xxx_3d
End Sub

Private Sub cmdApply_Click()
    xxx_base = Val(Me.txtBase.Text)
    xxx_stride = Val(Me.txtStride.Text)
    xxx_offsetx = Val(Me.txtOffsetX.Text)
    xxx_offsety = Val(Me.txtOffsetY.Text)
    xxx_offsetz = Val(Me.txtOffsetZ.Text)
    xxx_selstart = Val(Me.txtSelStart.Text)
    xxx_selend = Val(Me.txtSelEnd.Text)
    xxx_3d = Me.optDims(1).Value
    DrawGL
End Sub

Private Sub txtStride_Change()
    Me.labStrideBytes.Caption = Val(Me.txtStride.Text) * 2
End Sub

Private Sub txtSelStart_Change()
    Me.txtFileOffsetStart.Text = Val(Me.txtSelStart.Text) * 2
End Sub

Private Sub txtSelEnd_Change()
    Me.txtFileOffsetEnd.Text = Val(Me.txtSelEnd.Text) * 2
End Sub

Private Sub txtFileOffsetStart_Change()
    Me.txtSelStart.Text = Val(Me.txtFileOffsetStart.Text) / 2
End Sub

Private Sub txtFileOffsetEnd_Change()
    Me.txtSelEnd.Text = Val(Me.txtFileOffsetEnd.Text) / 2
End Sub


