object DCCFileAccept: TDCCFileAccept
  Left = 449
  Top = 333
  Width = 385
  Height = 250
  Caption = #1055#1088#1080#1085#1103#1090#1100' '#1092#1072#1081#1083'?'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 361
    Height = 73
    Caption = #1054#1090#1087#1088#1072#1074#1080#1090#1077#1083#1100
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 16
      Width = 49
      Height = 13
      AutoSize = False
      Caption = #1048#1084#1103':'
    end
    object Label2: TLabel
      Left = 8
      Top = 32
      Width = 49
      Height = 13
      AutoSize = False
      Caption = #1040#1076#1088#1077#1089':'
    end
    object Label3: TLabel
      Left = 8
      Top = 48
      Width = 14
      Height = 13
      Caption = 'IP:'
    end
    object lbSenderName: TLabel
      Left = 56
      Top = 16
      Width = 249
      Height = 13
      AutoSize = False
      Caption = 'lbSenderName'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lbSenderAddress: TLabel
      Left = 56
      Top = 32
      Width = 80
      Height = 13
      Caption = 'lbSenderAddress'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lbSenderIP: TLabel
      Left = 56
      Top = 48
      Width = 52
      Height = 13
      Caption = 'lbSenderIP'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 88
    Width = 361
    Height = 97
    Caption = #1060#1072#1081#1083
    TabOrder = 1
    object lbFileName: TLabel
      Left = 8
      Top = 16
      Width = 345
      Height = 13
      AutoSize = False
      Caption = 'lbFileName'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 8
      Top = 48
      Width = 68
      Height = 13
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074':'
    end
    object Label5: TLabel
      Left = 8
      Top = 32
      Width = 42
      Height = 13
      Caption = #1056#1072#1079#1084#1077#1088': '
    end
    object lbFileSize: TLabel
      Left = 56
      Top = 32
      Width = 297
      Height = 13
      AutoSize = False
      Caption = 'lbFileSize'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object edPathName: TEdit
      Left = 8
      Top = 64
      Width = 321
      Height = 21
      TabOrder = 0
      Text = 'edPathName'
    end
    object btnSelectDirectory: TButton
      Left = 334
      Top = 64
      Width = 19
      Height = 20
      Caption = '...'
      TabOrder = 1
      OnClick = btnSelectDirectoryClick
    end
  end
  object btnAccept: TButton
    Left = 8
    Top = 192
    Width = 75
    Height = 25
    Caption = #1055#1088#1080#1085#1103#1090#1100
    TabOrder = 2
    OnClick = btnAcceptClick
  end
  object btnCancel: TButton
    Left = 288
    Top = 192
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 3
    OnClick = btnCancelClick
  end
end
