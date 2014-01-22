object frmOptions: TfrmOptions
  Left = 321
  Top = 219
  BorderStyle = bsDialog
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  ClientHeight = 413
  ClientWidth = 620
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object tvConfTree: TTreeView
    Left = 8
    Top = 8
    Width = 209
    Height = 361
    HotTrack = True
    Indent = 19
    ReadOnly = True
    TabOrder = 0
    OnChange = tvConfTreeChange
  end
  object panOptionsPanel: TPanel
    Left = 224
    Top = 8
    Width = 389
    Height = 361
    BevelOuter = bvNone
    TabOrder = 1
    object panValuesList: TPanel
      Left = 0
      Top = 0
      Width = 389
      Height = 361
      Align = alClient
      TabOrder = 0
      object lvItemsList: TListView
        Left = 1
        Top = 1
        Width = 387
        Height = 275
        Align = alTop
        Columns = <
          item
            Caption = 'ID'
            MinWidth = 25
            Width = 25
          end
          item
            Caption = 'Name'
            MinWidth = 50
          end
          item
            Caption = 'Full Name'
            MinWidth = 100
            Width = 100
          end
          item
            Caption = 'Value'
            MinWidth = 200
            Width = 200
          end>
        GridLines = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnSelectItem = lvItemsListSelectItem
      end
      object panelModValue: TPanel
        Left = 1
        Top = 276
        Width = 387
        Height = 84
        Align = alClient
        TabOrder = 1
        object lbValueName: TLabel
          Left = 12
          Top = 8
          Width = 313
          Height = 16
          AutoSize = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object cbValue: TCheckBox
          Left = 8
          Top = 8
          Width = 313
          Height = 17
          Caption = 'cbValue'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          Visible = False
        end
        object edValueString: TEdit
          Left = 8
          Top = 32
          Width = 321
          Height = 21
          TabOrder = 0
          Visible = False
        end
        object btnSetValue: TButton
          Left = 332
          Top = 40
          Width = 51
          Height = 25
          Caption = 'SET'
          TabOrder = 1
          OnClick = btnSetValueClick
        end
        object memoValue: TMemo
          Left = 8
          Top = 32
          Width = 321
          Height = 45
          ScrollBars = ssVertical
          TabOrder = 3
          Visible = False
        end
      end
    end
  end
  object btOk: TButton
    Left = 356
    Top = 380
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 2
    OnClick = btOkClick
  end
  object btnApply: TButton
    Left = 444
    Top = 380
    Width = 75
    Height = 25
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    TabOrder = 3
    OnClick = btnApplyClick
  end
  object btnCancel: TButton
    Left = 532
    Top = 380
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object bbtnFold: TBitBtn
    Left = 12
    Top = 376
    Width = 25
    Height = 25
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    OnClick = bbtnFoldClick
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000010000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
      777770000000000000777833333333333077787B7B7B7B7B307778B7B7B7B7B7
      3077787B7B7B7B7B307778B7B7B7B7B73077787B7B7B7B7B307778FFFFFFFFFF
      30777788888888888777778FFF07777777747778887777777774777777777777
      4747777777777777447777777777777744477777777777777777}
  end
  object bbtnUnfold: TBitBtn
    Left = 44
    Top = 376
    Width = 25
    Height = 25
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
    OnClick = bbtnUnfoldClick
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000010000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
      7777777777777777777777777777777777770000000000077777003333333330
      77770F033333333307770BF03333333330770FBF0333333333070BFBF0000000
      00070FBFBFBFBF0777770BFBFBFBFB0777770FBF000000077777700077777777
      0007777777777777700777777777077707077777777770007777}
  end
end
