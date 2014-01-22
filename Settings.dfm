object Form3: TForm3
  Left = 646
  Top = 263
  Width = 537
  Height = 378
  Caption = 'Form3'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnApply: TButton
    Left = 336
    Top = 320
    Width = 75
    Height = 25
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    TabOrder = 0
  end
  object btOk: TButton
    Left = 248
    Top = 320
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 424
    Top = 320
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object TreeView1: TTreeView
    Left = 8
    Top = 8
    Width = 153
    Height = 305
    Indent = 19
    TabOrder = 3
    Items.Data = {
      05000000240000000000000000000000FFFFFFFFFFFFFFFF0000000000000000
      0BCFEEE4EAEBFEF7E5EDE8E51E0000000000000000000000FFFFFFFFFFFFFFFF
      000000000000000005CEE1F9E8E51F0000000000000000000000FFFFFFFFFFFF
      FFFF000000000000000006D8F0E8F4F2FB200000000000000000000000FFFFFF
      FFFFFFFFFF000000000400000007CCE5F1F1E0E3E82000000000000000000000
      00FFFFFFFFFFFFFFFF000000000000000007D4E8EBFCF2F0FB28000000000000
      0000000000FFFFFFFFFFFFFFFF00000000000000000FC1FBF1F2F0FBE520ECE5
      F1F1E0E3E81D0000000000000000000000FFFFFFFFFFFFFFFF00000000000000
      0004CBEEE3E8260000000000000000000000FFFFFFFFFFFFFFFF000000000000
      00000DC4EEEF2E20ECE5F1F1E0E3E82E260000000000000000000000FFFFFFFF
      FFFFFFFF00000000000000000DCEEDEBE0E9ED20E0EBE5F0F2FB}
  end
  object MainFrame: TGroupBox
    Left = 168
    Top = 8
    Width = 353
    Height = 305
    Caption = #1055#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077
    TabOrder = 4
  end
  object XPManifest1: TXPManifest
    Left = 488
    Top = 232
  end
end
