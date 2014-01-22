object frmIrcOptions: TfrmIrcOptions
  Left = 303
  Top = 244
  Width = 388
  Height = 378
  Caption = 'frmIrcOptions'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 365
    Height = 333
    ActivePage = tsSounds
    TabOrder = 0
    object tsIRCMain: TTabSheet
      Caption = 'tsIRCMain'
      object gbIRCMain: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 305
        Align = alClient
        Caption = 'IRC'
        TabOrder = 0
        object frameOtherNick: TGroupBox
          Left = 6
          Top = 16
          Width = 341
          Height = 65
          Caption = #1044#1086#1087'. '#1085#1072#1089#1090#1088#1086#1081#1082#1080' '#1085#1080#1082#1072
          TabOrder = 0
          object lbOtherNick: TLabel
            Left = 10
            Top = 17
            Width = 106
            Height = 13
            Caption = #1040#1083#1100#1090#1077#1088#1085#1072#1090#1080#1074#1085#1099#1081' '#1085#1080#1082
          end
          object lbFullName: TLabel
            Left = 10
            Top = 39
            Width = 61
            Height = 13
            Caption = #1055#1086#1083#1085#1086#1077' '#1080#1084#1103
          end
          object editOtherNick: TEdit
            Left = 132
            Top = 15
            Width = 201
            Height = 21
            TabOrder = 0
          end
          object editFullName: TEdit
            Left = 132
            Top = 37
            Width = 201
            Height = 21
            TabOrder = 1
          end
        end
        object frameIrcMessages: TGroupBox
          Left = 6
          Top = 82
          Width = 341
          Height = 215
          Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1103
          TabOrder = 1
          object lbQuitMessage: TLabel
            Left = 10
            Top = 18
            Width = 119
            Height = 13
            Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1077' '#1087#1088#1080' '#1074#1099#1093#1086#1076#1077
          end
          object lbAway: TLabel
            Left = 10
            Top = 42
            Width = 117
            Height = 13
            Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1077' "'#1084#1077#1085#1103' '#1085#1077#1090'"'
          end
          object editQuitMessage: TEdit
            Left = 136
            Top = 16
            Width = 197
            Height = 21
            TabOrder = 0
          end
          object editAway: TEdit
            Left = 136
            Top = 38
            Width = 197
            Height = 21
            TabOrder = 1
          end
          object cbSendUTF8: TCheckBox
            Left = 8
            Top = 64
            Width = 169
            Height = 17
            Caption = #1086#1090#1087#1088#1072#1074#1083#1103#1090#1100' '#1090#1077#1082#1089#1090' '#1074' UTF-8'
            TabOrder = 2
          end
          object cbReceiveUTF8: TCheckBox
            Left = 8
            Top = 80
            Width = 165
            Height = 17
            Caption = #1087#1088#1080#1085#1080#1084#1072#1090#1100' '#1090#1077#1082#1089#1090' UTF-8'
            TabOrder = 3
          end
        end
      end
    end
    object tsNickServ: TTabSheet
      Caption = 'tsNickServ'
      ImageIndex = 1
      object gbNickServ: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 305
        Align = alClient
        Caption = 'gbNickServ'
        TabOrder = 0
        object lbNickServ1: TLabel
          Left = 16
          Top = 88
          Width = 23
          Height = 13
          Caption = #1053#1080#1082':'
        end
        object lbNickServ2: TLabel
          Left = 16
          Top = 112
          Width = 41
          Height = 13
          Caption = #1055#1072#1088#1086#1083#1100':'
        end
        object lbNickServ3: TLabel
          Left = 16
          Top = 136
          Width = 31
          Height = 13
          Caption = 'E-mail:'
        end
        object lbNickServ4: TLabel
          Left = 16
          Top = 16
          Width = 317
          Height = 39
          Caption = 
            #1056#1077#1075#1080#1089#1090#1088#1072#1094#1080#1103' '#1085#1080#1082#1072' '#1085#1077' '#1087#1086#1079#1074#1086#1083#1080#1090' '#1080#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1074#1072#1096' '#1085#1080#1082' '#1076#1088#1091#1075#1080#1084' '#1083#1102#1076#1103#1084' '#1080 +
            ' '#1076#1072#1077#1090' '#1074#1086#1079#1084#1086#1078#1085#1086#1089#1090#1100' '#1080#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1076#1086#1089#1082#1091' '#1086#1073#1100#1103#1074#1083#1077#1085#1080#1081' '#1080' '#1087#1077#1081#1076#1078#1077#1088'. '#1044#1083#1103' '#1088 +
            #1077#1075#1080#1089#1090#1088#1072#1094#1080#1080' '#1085#1091#1078#1077#1085' '#1076#1077#1081#1089#1090#1074#1091#1102#1097#1080#1081' '#1077'-'#1084#1077#1081#1083'.'
          WordWrap = True
        end
        object eNServNick: TEdit
          Left = 64
          Top = 88
          Width = 177
          Height = 21
          TabOrder = 0
        end
        object eNServPassw: TEdit
          Left = 64
          Top = 112
          Width = 177
          Height = 21
          TabOrder = 1
        end
        object eNServEmail: TEdit
          Left = 64
          Top = 136
          Width = 177
          Height = 21
          TabOrder = 2
        end
        object btnNickServ1: TButton
          Left = 256
          Top = 88
          Width = 75
          Height = 25
          Caption = #1056#1077#1075#1080#1089#1090#1088#1072#1094#1080#1103
          TabOrder = 3
        end
        object btnNickServ2: TButton
          Left = 256
          Top = 128
          Width = 75
          Height = 25
          Caption = #1042#1093#1086#1076
          TabOrder = 4
        end
      end
    end
    object tsConnection: TTabSheet
      Caption = 'tsConnection'
      ImageIndex = 2
      object gbConnection: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 305
        Align = alClient
        Caption = #1055#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077
        TabOrder = 0
        Visible = False
        object gbServer: TGroupBox
          Left = 180
          Top = 16
          Width = 166
          Height = 237
          Caption = #1057#1077#1088#1074#1077#1088
          TabOrder = 0
          object lbServerName: TLabel
            Left = 6
            Top = 18
            Width = 31
            Height = 13
            Caption = #1040#1076#1088#1077#1089
          end
          object lbServerPort: TLabel
            Left = 6
            Top = 42
            Width = 25
            Height = 13
            Caption = #1055#1086#1088#1090
          end
          object btnAddServer: TButton
            Left = 10
            Top = 65
            Width = 67
            Height = 17
            Caption = #1044#1086#1073#1072#1074#1080#1090#1100
            TabOrder = 0
            OnClick = AddServerClick
          end
          object btnDelServer: TButton
            Left = 87
            Top = 65
            Width = 67
            Height = 17
            Caption = #1059#1076#1072#1083#1080#1090#1100
            TabOrder = 1
            OnClick = DelServerClick
          end
          object editServerName: TEdit
            Left = 48
            Top = 16
            Width = 111
            Height = 21
            TabOrder = 2
          end
          object editServerPort: TEdit
            Left = 82
            Top = 40
            Width = 77
            Height = 21
            TabOrder = 3
          end
          object listServerList: TListBox
            Left = 4
            Top = 88
            Width = 156
            Height = 145
            ItemHeight = 13
            Sorted = True
            TabOrder = 4
            OnDblClick = SetNewServer
          end
        end
        object gbNick: TGroupBox
          Left = 8
          Top = 16
          Width = 166
          Height = 281
          Caption = #1053#1080#1082
          TabOrder = 1
          object listNickList: TListBox
            Left = 4
            Top = 91
            Width = 156
            Height = 142
            ItemHeight = 13
            Sorted = True
            TabOrder = 0
            OnDblClick = SetNewNick
          end
          object gbNickButtons: TGroupBox
            Left = 4
            Top = 12
            Width = 157
            Height = 75
            TabOrder = 1
            object rbtnNick1: TRadioButton
              Left = 8
              Top = 12
              Width = 120
              Height = 16
              Caption = #1053#1080#1082' '#1080#1079' '#1074#1080#1085#1076#1099
              TabOrder = 0
              OnClick = NickModeChange
            end
            object rbtnNick2: TRadioButton
              Left = 8
              Top = 28
              Width = 120
              Height = 25
              Caption = #1048#1084#1103' '#1082#1086#1084#1087#1072
              Checked = True
              TabOrder = 1
              TabStop = True
              OnClick = NickModeChange
            end
            object rbtnNick3: TRadioButton
              Left = 8
              Top = 48
              Width = 120
              Height = 25
              Caption = #1053#1080#1082' '#1080#1079' '#1089#1087#1080#1089#1082#1072':'
              TabOrder = 2
              OnClick = NickModeChange
            end
          end
          object editNick: TEdit
            Left = 12
            Top = 236
            Width = 143
            Height = 21
            TabOrder = 2
          end
          object btnAddNick: TButton
            Left = 10
            Top = 260
            Width = 67
            Height = 17
            Caption = #1044#1086#1073#1072#1074#1080#1090#1100
            TabOrder = 3
            OnClick = AddNickClick
          end
          object btnDelNick: TButton
            Left = 88
            Top = 260
            Width = 67
            Height = 17
            Caption = #1059#1076#1072#1083#1080#1090#1100
            TabOrder = 4
            OnClick = DelNickClick
          end
        end
        object gbProxy: TGroupBox
          Left = 180
          Top = 256
          Width = 165
          Height = 41
          Caption = #1055#1088#1086#1082#1089#1080'-'#1089#1077#1088#1074#1077#1088
          TabOrder = 2
          object editProxyServer: TEdit
            Left = 4
            Top = 16
            Width = 157
            Height = 21
            TabOrder = 0
          end
        end
      end
    end
    object tsAutojoin: TTabSheet
      Caption = 'tsAutojoin'
      ImageIndex = 3
      object gbAutojoin: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 305
        Align = alClient
        Caption = #1050#1086#1084#1072#1085#1076#1099' '#1087#1088#1080' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1080
        TabOrder = 0
        Visible = False
        object lbAJList: TLabel
          Left = 16
          Top = 16
          Width = 313
          Height = 25
          AutoSize = False
          Caption = 
            #1057#1087#1080#1089#1086#1082' '#1082#1086#1084#1072#1085#1076', '#1074#1099#1087#1086#1083#1085#1103#1077#1084#1099#1093' '#1087#1088#1080' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1080' '#1082' '#1089#1077#1088#1074#1077#1088#1091'. '#1054#1076#1085#1072' '#1089#1090#1088#1086#1082 +
            #1072' - '#1086#1076#1085#1072' '#1082#1086#1084#1072#1085#1076#1072'.'
          WordWrap = True
        end
        object mAutojoinList: TMemo
          Left = 8
          Top = 48
          Width = 337
          Height = 249
          TabOrder = 0
        end
      end
    end
    object tsIgnore: TTabSheet
      Caption = 'tsIgnore'
      ImageIndex = 4
      object gbIgnore: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 305
        Align = alClient
        Caption = #1048#1075#1085#1086#1088#1080#1088#1091#1077#1084#1099#1077
        TabOrder = 0
        object lbIgnore1: TLabel
          Left = 8
          Top = 16
          Width = 337
          Height = 17
          AutoSize = False
          Caption = #1057#1087#1080#1089#1086#1082' '#1080#1075#1085#1086#1088#1080#1088#1091#1077#1084#1099#1093' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077#1081'. '#1050#1072#1078#1076#1072#1103' '#1089#1090#1088#1086#1082#1072' '#1080#1084#1077#1077#1090' '#1074#1080#1076
          WordWrap = True
        end
        object lbIgnore2: TLabel
          Left = 16
          Top = 34
          Width = 95
          Height = 13
          Caption = #1048#1052#1071'>'#1055#1056#1048#1047#1053#1040#1050
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lbIgnore3: TLabel
          Left = 8
          Top = 48
          Width = 324
          Height = 13
          Caption = #1075#1076#1077' '#1080#1084#1103' - '#1101#1090#1086' '#1080#1084#1103' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103', '#1072' '#1087#1088#1080#1079#1085#1072#1082' - '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '#1080#1075#1085#1086#1088#1072
        end
        object memoIgnore: TMemo
          Left = 8
          Top = 72
          Width = 337
          Height = 225
          Lines.Strings = (
            '')
          TabOrder = 0
        end
      end
    end
    object tsTemplates: TTabSheet
      Caption = 'tsTemplates'
      ImageIndex = 5
      object gbTemplates: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 305
        Align = alClient
        Caption = 'gbTemplates'
        TabOrder = 0
        object lbTemplates1: TLabel
          Left = 8
          Top = 16
          Width = 300
          Height = 13
          Caption = #1042' '#1096#1072#1073#1083#1086#1085#1072#1093' '#1089#1086#1086#1073#1097#1077#1085#1080#1081' '#1084#1086#1078#1085#1086' '#1080#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1087#1077#1088#1077#1084#1077#1085#1085#1099#1077':'
        end
        object lbTemplates2: TLabel
          Left = 8
          Top = 32
          Width = 49
          Height = 13
          AutoSize = False
          Caption = '&MyNick'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          ShowAccelChar = False
        end
        object lbTemplates3: TLabel
          Left = 8
          Top = 48
          Width = 61
          Height = 13
          AutoSize = False
          Caption = '&UserNick'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          ShowAccelChar = False
        end
        object lbTemplates4: TLabel
          Left = 172
          Top = 32
          Width = 73
          Height = 13
          AutoSize = False
          Caption = '&ChanName'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          ShowAccelChar = False
        end
        object lbTemplates5: TLabel
          Left = 196
          Top = 48
          Width = 21
          Height = 13
          AutoSize = False
          Caption = '&s'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          ShowAccelChar = False
        end
        object lbTemplates6: TLabel
          Left = 60
          Top = 32
          Width = 113
          Height = 13
          AutoSize = False
          Caption = '- '#1089#1086#1073#1089#1090#1074#1077#1085#1085#1099#1081' '#1085#1080#1082
        end
        object lbTemplates7: TLabel
          Left = 68
          Top = 48
          Width = 125
          Height = 13
          AutoSize = False
          Caption = ' - '#1085#1080#1082' '#1074#1099#1073#1088#1072#1085#1086#1075#1086' '#1102#1079#1077#1088#1072
        end
        object lbTemplates8: TLabel
          Left = 240
          Top = 32
          Width = 96
          Height = 13
          Caption = ' - '#1085#1072#1079#1074#1072#1085#1080#1077' '#1082#1072#1085#1072#1083#1072
        end
        object lbTemplates9: TLabel
          Left = 212
          Top = 48
          Width = 109
          Height = 13
          AutoSize = False
          Caption = '- '#1089#1090#1088#1086#1082#1072' '#1080#1079' '#1076#1080#1072#1083#1086#1075#1072
        end
        object memoTemplates: TMemo
          Left = 8
          Top = 68
          Width = 337
          Height = 225
          TabOrder = 0
        end
      end
    end
    object tsSounds: TTabSheet
      Caption = 'tsSounds'
      ImageIndex = 6
      object gbSounds: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 305
        Align = alClient
        Caption = #1047#1074#1091#1082#1080
        TabOrder = 0
        object lbSoundTest: TLabel
          Left = 180
          Top = 280
          Width = 161
          Height = 13
          AutoSize = False
          Caption = '- '#1087#1088#1086#1080#1075#1088#1072#1090#1100' '#1074#1099#1073#1088#1072#1085#1099#1081' '#1079#1074#1091#1082
        end
        object vleSounds: TValueListEditor
          Left = 8
          Top = 16
          Width = 337
          Height = 257
          Strings.Strings = (
            '1=2')
          TabOrder = 0
          TitleCaptions.Strings = (
            #1057#1086#1073#1099#1090#1080#1077
            #1060#1072#1081#1083)
          ColWidths = (
            150
            181)
        end
        object btnSoundTest: TButton
          Left = 148
          Top = 276
          Width = 25
          Height = 21
          Caption = '>'
          TabOrder = 1
          OnClick = btnSoundTestClick
        end
        object cbPlaySounds: TCheckBox
          Left = 8
          Top = 280
          Width = 137
          Height = 17
          Caption = #1074#1082#1083#1102#1095#1080#1090#1100' '#1079#1074#1091#1082#1080
          TabOrder = 2
        end
      end
    end
  end
end
