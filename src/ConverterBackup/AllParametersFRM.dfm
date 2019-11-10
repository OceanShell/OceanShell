object AllParameters: TAllParameters
  Left = 462
  Top = 143
  Caption = 'All parameters'
  ClientHeight = 508
  ClientWidth = 802
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter2: TSplitter
    Left = 0
    Top = 318
    Width = 802
    Height = 3
    Cursor = crVSplit
    Align = alTop
    Beveled = True
    ExplicitLeft = 8
    ExplicitTop = 336
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 802
    Height = 318
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitHeight = 321
    object Splitter1: TSplitter
      Left = 658
      Top = 22
      Height = 238
      Align = alRight
      Beveled = True
      ExplicitLeft = 648
      ExplicitTop = 29
      ExplicitHeight = 239
    end
    object DBGridEh1: TDBGridEh
      Left = 0
      Top = 22
      Width = 658
      Height = 238
      Align = alClient
      AutoFitColWidths = True
      DataSource = DS1
      DynProps = <>
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      FooterRowCount = 1
      FooterParams.Color = clYellow
      IndicatorOptions = [gioShowRowIndicatorEh]
      ParentFont = False
      PopupMenu = PopupMenu1
      SumList.Active = True
      TabOrder = 0
      OnDrawColumnCell = DBGridEh1DrawColumnCell
      OnGetCellParams = DBGridEh1GetCellParams
      OnKeyUp = DBGridEh1KeyUp
      OnMouseDown = DBGridEh1MouseDown
      object RowDetailData: TRowDetailPanelControlEh
      end
    end
    object CheckListBox1: TCheckListBox
      Left = 661
      Top = 22
      Width = 141
      Height = 238
      Align = alRight
      BevelInner = bvNone
      BevelOuter = bvNone
      Ctl3D = True
      ItemHeight = 13
      ParentCtl3D = False
      TabOrder = 1
      OnClick = CheckListBox1Click
    end
    object ToolBar1: TToolBar
      Left = 0
      Top = 0
      Width = 802
      Height = 22
      AutoSize = True
      ButtonWidth = 62
      Caption = 'ToolBar1'
      DrawingStyle = dsGradient
      Images = Main.IL1
      List = True
      ParentShowHint = False
      ShowCaptions = True
      ShowHint = True
      TabOrder = 2
      Transparent = False
      object btnAdd: TToolButton
        Left = 0
        Top = 0
        Hint = 'Add level'
        Caption = 'Add'
        ImageIndex = 25
        OnClick = btnAddClick
      end
      object btnDelete: TToolButton
        Left = 62
        Top = 0
        Hint = 'Delete level'
        Caption = 'Delete'
        ImageIndex = 26
        OnClick = btnDeleteClick
      end
      object ToolButton3: TToolButton
        Left = 124
        Top = 0
        Width = 8
        Caption = 'ToolButton3'
        ImageIndex = 29
        Style = tbsSeparator
      end
      object btnSetFlag: TToolButton
        Left = 132
        Top = 0
        Hint = 'Set flag on all parameters'
        AutoSize = True
        Caption = 'Flag'
        ImageIndex = 43
        OnClick = btnSetFlagClick
      end
      object ToolButton2: TToolButton
        Left = 183
        Top = 0
        Width = 8
        Caption = 'ToolButton2'
        ImageIndex = 28
        Style = tbsSeparator
      end
      object btnCommit: TToolButton
        Left = 191
        Top = 0
        Hint = 'Commit changes'
        AutoSize = True
        Caption = 'Commit'
        ImageIndex = 28
        OnClick = btnCommitClick
      end
    end
    object Memo1: TMemo
      Left = 0
      Top = 260
      Width = 802
      Height = 58
      Align = alBottom
      Color = clRed
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      Lines.Strings = (
        '')
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 3
    end
  end
  object pCharts: TPanel
    Left = 0
    Top = 321
    Width = 802
    Height = 187
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
  end
  object DS1: TDataSource
    Left = 240
    Top = 112
  end
  object PopupMenu1: TPopupMenu
    Images = Main.IL1
    Left = 176
    Top = 112
    object Setflag1: TMenuItem
      Caption = 'Set flag'
      ImageIndex = 43
      OnClick = Setflag1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Copyparameterstoanotherstation1: TMenuItem
      Caption = 'Copy parameter to another station'
      OnClick = Copyparameterstoanotherstation1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object btnDeletePar: TMenuItem
      Caption = 'Delete parameter'
      ImageIndex = 13
      OnClick = btnDeleteParClick
    end
  end
end
