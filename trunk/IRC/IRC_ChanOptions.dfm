object frmChanOptions: TfrmChanOptions
  Left = 447
  Top = 326
  Width = 469
  Height = 393
  Caption = 'frmChanOptions'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbTopic: TLabel
    Left = 8
    Top = 8
    Width = 49
    Height = 17
    AutoSize = False
    Caption = 'Topic'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btnSetTopic: TButton
    Left = 8
    Top = 32
    Width = 49
    Height = 25
    Caption = #1054#1050
    TabOrder = 0
    OnClick = btnSetTopicClick
  end
  object memoTopic: TMemo
    Left = 64
    Top = 8
    Width = 385
    Height = 49
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object grpChanModes: TGroupBox
    Left = 8
    Top = 64
    Width = 233
    Height = 289
    Caption = 'Channel Modes'
    TabOrder = 2
    object lbChanUserLimit: TLabel
      Left = 8
      Top = 232
      Width = 121
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Chan users limit'
    end
    object lbKeyword: TLabel
      Left = 8
      Top = 256
      Width = 121
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Keyword'
    end
    object cbPrivate: TCheckBox
      Left = 8
      Top = 16
      Width = 217
      Height = 17
      Caption = 'Private (name hidden in list)'
      TabOrder = 0
    end
    object cbSecret: TCheckBox
      Left = 8
      Top = 40
      Width = 217
      Height = 17
      Caption = 'Secret (name hidden in list)'
      TabOrder = 1
    end
    object cbNoExtMsg: TCheckBox
      Left = 8
      Top = 64
      Width = 217
      Height = 17
      Caption = 'No external messages'
      TabOrder = 2
    end
    object cbTopicOpsOnly: TCheckBox
      Left = 8
      Top = 88
      Width = 217
      Height = 17
      Caption = 'Topic changed by Ops only'
      TabOrder = 3
    end
    object cbModerated: TCheckBox
      Left = 8
      Top = 112
      Width = 217
      Height = 17
      Caption = 'Moderated (voiced only can talk)'
      TabOrder = 4
    end
    object cbInviteOnly: TCheckBox
      Left = 8
      Top = 136
      Width = 217
      Height = 17
      Caption = 'Invite only (You must invite new users)'
      TabOrder = 5
    end
    object edLimit: TEdit
      Left = 136
      Top = 232
      Width = 89
      Height = 21
      TabOrder = 6
    end
    object edKeyword: TEdit
      Left = 136
      Top = 256
      Width = 89
      Height = 21
      TabOrder = 7
    end
    object cbColorsDisabled: TCheckBox
      Left = 8
      Top = 160
      Width = 217
      Height = 17
      Caption = 'Colors disabled'
      TabOrder = 8
    end
    object cbRobots: TCheckBox
      Left = 8
      Top = 184
      Width = 217
      Height = 17
      Caption = 'Robots on channel'
      Enabled = False
      TabOrder = 9
    end
  end
  object grpBanList: TGroupBox
    Left = 248
    Top = 64
    Width = 201
    Height = 289
    Caption = 'Ban List'
    TabOrder = 3
    object lstBanList: TListBox
      Left = 8
      Top = 16
      Width = 185
      Height = 241
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 0
    end
    object btnUnban: TButton
      Left = 104
      Top = 264
      Width = 91
      Height = 20
      Caption = 'Unban'
      TabOrder = 1
      OnClick = btnUnbanClick
    end
  end
end
