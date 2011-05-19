object DirShortCutForm: TDirShortCutForm
  Left = 0
  Top = 0
  Caption = 'DirShortCutForm'
  ClientHeight = 404
  ClientWidth = 610
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lvShortCut: TListView
    Left = 0
    Top = 0
    Width = 488
    Height = 404
    Align = alClient
    Columns = <
      item
        Caption = 'ShortCut'
        Width = 100
      end
      item
        Caption = 'Name'
        Width = 100
      end
      item
        Caption = 'Param Type'
        Width = 100
      end
      item
        Caption = 'Command Line'
        Width = 400
      end>
    Ctl3D = False
    DragMode = dmAutomatic
    FlatScrollBars = True
    FullDrag = True
    GridLines = True
    HideSelection = False
    RowSelect = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = lvShortCutDblClick
    ExplicitLeft = 8
    ExplicitWidth = 362
  end
  object pnlRight: TPanel
    Left = 488
    Top = 0
    Width = 122
    Height = 404
    Align = alRight
    TabOrder = 1
    ExplicitLeft = 494
    DesignSize = (
      122
      404)
    object btnOpenDir: TBitBtn
      Left = 22
      Top = 16
      Width = 75
      Height = 25
      Caption = 'OpenDir'
      TabOrder = 0
      OnClick = btnOpenDirClick
    end
    object btnEdit: TBitBtn
      Left = 22
      Top = 128
      Width = 75
      Height = 25
      Caption = 'Edit'
      TabOrder = 1
      OnClick = btnEditClick
    end
    object btnDelete: TBitBtn
      Left = 22
      Top = 168
      Width = 75
      Height = 25
      Caption = 'Delete'
      TabOrder = 2
      OnClick = btnDeleteClick
    end
    object btnCancel: TBitBtn
      Left = 23
      Top = 328
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      TabOrder = 3
      Kind = bkCancel
    end
    object btnOK: TBitBtn
      Left = 23
      Top = 281
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 4
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        3333333333333333333333330000333333333333333333333333F33333333333
        00003333344333333333333333388F3333333333000033334224333333333333
        338338F3333333330000333422224333333333333833338F3333333300003342
        222224333333333383333338F3333333000034222A22224333333338F338F333
        8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
        33333338F83338F338F33333000033A33333A222433333338333338F338F3333
        0000333333333A222433333333333338F338F33300003333333333A222433333
        333333338F338F33000033333333333A222433333333333338F338F300003333
        33333333A222433333333333338F338F00003333333333333A22433333333333
        3338F38F000033333333333333A223333333333333338F830000333333333333
        333A333333333333333338330000333333333333333333333333333333333333
        0000}
      NumGlyphs = 2
    end
    object btnClear: TBitBtn
      Left = 22
      Top = 208
      Width = 75
      Height = 25
      Caption = 'Clear'
      TabOrder = 5
      OnClick = btnClearClick
    end
    object chkRecurve: TCheckBox
      Left = 32
      Top = 56
      Width = 97
      Height = 17
      Caption = 'Recurve'
      TabOrder = 6
    end
  end
end
