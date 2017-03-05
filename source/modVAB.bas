Attribute VB_Name = "modVAB"
Option Explicit

'from vablib.c (psxlib2)
'doesn't match up with our data for some reason, but a good for reference
'typedef struct {
'  unsigned long magicnum;
'  unsigned long version;
'  unsigned long vab_id;
'  unsigned long wave_size;
'  unsigned short num_progs;
'  unsigned short num_tones;
'  unsigned short num_vags;
'  unsigned char master_vol;
'  unsigned char master_pan;
'  unsigned char ba1;
'  unsigned char ba2;
'  unsigned short vag_length[256];
'  unsigned short vag_offset[256];
'  unsigned long wavedatasize;
'  unsigned long sb_addr;
'} VABHEADER;


Private Type vabhead        '32 bytes
    id As Long              '0          pBAV
    version As Long         '4          5
    vabid As Long           '8          0
    size As Long            '12         filesize
    u1 As Integer           '16         EEEE
    progs As Integer        '18         0
    tones As Integer        '20         0
    vags As Integer         '22         6
    u2 As Long              '24         0000 0000
    u3 As Long              '28         FFFF FFFF
End Type

Private Type vabXXX         '16 bytes
    u1 As Integer
    u2 As Integer
    u3 As Integer
    u4 As Integer
    u5 As Integer
    u6 As Integer
    u7 As Integer
    u8 As Integer
End Type

'Private Type vaghead '48 bytes
'    ...
'End Type

Private Type vagdata '16 bytes
    u1 As Byte
    endflag As Byte     '1 for last sample
    data(0 To 13) As Byte
End Type

Private Type vag
    'head as vaghead
    data() As vagdata
End Type

Private Type vabfile
    'header
    head As vabhead '1 entry (@0)
    
    'tables
    table_a(0 To 127) As vabXXX  '128 entries (@32)
    unknown(0 To 7) As Integer
    table_b(0 To 255) As Integer '256 entries (@2080)
    
    'wave data
    'vag() As vag
    
    'temp
    size As Long
    data() As Byte
End Type


Private vab As vabfile


'loads VAB file
Public Function LoadVab(ByVal filename As String) As Boolean
    On Error GoTo errorhandler
    
    'open file
    Dim ff As Integer
    ff = FreeFile
    Open filename For Binary Access Read Lock Write As ff
    
    'info
    Echo "File Info"
    Echo " filename: " & filename
    Echo " filesize: " & LOF(ff)
    
    'read header and data
    ReadVab ff
    
    Echo ">>> stopped at " & Loc(ff)
    Echo ">>> file size is " & LOF(ff)
    
    'close file
    Close ff
    
    LoadVab = True
    Exit Function
errorhandler:
    MsgBox "LoadVab" & vbLf & Err.Description, vbCritical
End Function


'reads VAB from file
Public Function ReadVab(ByVal ff As Integer) As Boolean
    
    'read file header
    Get ff, , vab.head
    
    Echo " pBAV header"
    Echo "  version:      " & vab.head.version
    Echo "  vabid:        " & vab.head.vabid
    Echo "  size:         " & vab.head.size
    Echo "  u1:           " & vab.head.u1
    Echo "  progs:        " & vab.head.progs
    Echo "  tones:        " & vab.head.tones
    Echo "  vags:         " & vab.head.vags
    Echo "  u2:           " & vab.head.u2
    Echo "  u3:           " & vab.head.u3
    
    'validate
    If Not vab.head.id = 1447117424 Then 'pBAV
        MsgBox "File is not a VAB file.", vbExclamation
        Exit Function
    End If
    
    'read table A
    Echo " table A at " & Loc(ff)
    Get ff, , vab.table_a() 'contains ???
    
    'read table B
    Echo " table B at " & Loc(ff)
    Get ff, , vab.table_b() 'contains size of each VAG block
    
    'read unknown
    Echo " unknown at " & Loc(ff)
    Get ff, , vab.unknown()
    
    'read wave data
    Echo " wave data at " & Loc(ff)
    vab.size = vab.head.size - 2608
    ReDim vab.data(0 To vab.size - 1)
    Get ff, , vab.data()
    
    'success
    ReadVab = True
End Function


'draws VAB data
Public Sub DrawVab()
Dim i As Long

Dim s As Single
Dim c As Single
        
    If vab.size Then
        
        '
        
    End If
End Sub

