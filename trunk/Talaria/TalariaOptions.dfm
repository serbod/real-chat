object frmTalariaOptions: TfrmTalariaOptions
  Left = 396
  Top = 354
  Width = 400
  Height = 380
  Caption = 'Talaria Options'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object pgcOptions: TPageControl
    Left = 8
    Top = 8
    Width = 365
    Height = 333
    ActivePage = tsMain
    TabOrder = 0
    object tsMain: TTabSheet
      Caption = 'tsMain'
      object gbiChatMain: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 305
        Align = alClient
        Caption = #1054#1089#1085#1086#1074#1085#1099#1077' '#1085#1072#1089#1090#1088#1086#1081#1082#1080
        TabOrder = 0
        DesignSize = (
          357
          305)
        object gbMsgSettings: TGroupBox
          Left = 6
          Top = 20
          Width = 343
          Height = 133
          Anchors = [akLeft, akTop, akRight]
          Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1103
          TabOrder = 0
          DesignSize = (
            343
            133)
          object lbQuitMessage: TLabel
            Left = 10
            Top = 70
            Width = 121
            Height = 13
            Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1077' '#1087#1088#1080' '#1074#1099#1093#1086#1076#1077
          end
          object lbAway: TLabel
            Left = 10
            Top = 46
            Width = 114
            Height = 13
            Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1077' "'#1084#1077#1085#1103' '#1085#1077#1090'"'
          end
          object lbHelloMessage: TLabel
            Left = 10
            Top = 22
            Width = 113
            Height = 13
            Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1077' '#1087#1088#1080' '#1074#1093#1086#1076#1077
          end
          object editQuitMessage: TEdit
            Left = 136
            Top = 68
            Width = 197
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 0
          end
          object editAway: TEdit
            Left = 136
            Top = 42
            Width = 197
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 1
          end
          object cbSendUTF8: TCheckBox
            Left = 8
            Top = 92
            Width = 169
            Height = 17
            Caption = #1086#1090#1087#1088#1072#1074#1083#1103#1090#1100' '#1090#1077#1082#1089#1090' '#1074' UTF-8'
            TabOrder = 2
          end
          object cbReceiveUTF8: TCheckBox
            Left = 8
            Top = 108
            Width = 165
            Height = 17
            Caption = #1087#1088#1080#1085#1080#1084#1072#1090#1100' '#1090#1077#1082#1089#1090' UTF-8'
            TabOrder = 3
          end
          object editHelloMessage: TEdit
            Left = 136
            Top = 16
            Width = 197
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 4
          end
        end
        object gbOther: TGroupBox
          Left = 8
          Top = 160
          Width = 341
          Height = 137
          Anchors = [akLeft, akTop, akRight]
          Caption = #1055#1088#1086#1095#1077#1077
          TabOrder = 1
          object cbAutoReconnect: TCheckBox
            Left = 8
            Top = 32
            Width = 329
            Height = 17
            Caption = #1040#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080' '#1087#1077#1088#1077#1087#1086#1076#1082#1083#1102#1095#1072#1090#1100#1089#1103' '#1087#1088#1080' '#1086#1073#1088#1099#1074#1077
            TabOrder = 0
          end
          object cbAutoConnect: TCheckBox
            Left = 8
            Top = 16
            Width = 321
            Height = 17
            Hint = 
              #1057#1088#1072#1079#1091' '#1087#1086#1089#1083#1077' '#1079#1072#1087#1091#1089#1082#1072' '#1087#1088#1086#1075#1088#1072#1084#1084#1099' '#1087#1086#1076#1082#1083#1102#1095#1072#1090#1100#1089#1103' '#1082' '#1089#1077#1088#1074#1077#1088#1091' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080 +
              #1102
            Caption = #1040#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080' '#1087#1086#1076#1082#1083#1102#1095#1072#1090#1100#1089#1103' '#1082' '#1089#1077#1088#1074#1077#1088#1091
            TabOrder = 1
          end
          object cbShowServerPing: TCheckBox
            Left = 8
            Top = 48
            Width = 257
            Height = 17
            Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1087#1080#1085#1075#1080' '#1089#1077#1088#1074#1077#1088#1072' (PING? PONG!)'
            TabOrder = 2
          end
          object cbLogMessages: TCheckBox
            Left = 8
            Top = 64
            Width = 293
            Height = 17
            Caption = #1057#1086#1093#1088#1072#1085#1103#1090#1100' '#1080#1089#1090#1086#1088#1080#1102' '#1089#1086#1086#1073#1097#1077#1085#1080#1081
            TabOrder = 3
          end
          object cbShowStatusMessages: TCheckBox
            Left = 8
            Top = 80
            Width = 341
            Height = 17
            Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1089#1090#1072#1090#1091#1089#1085#1099#1077' '#1089#1086#1086#1073#1097#1077#1085#1080#1103' ('#1074#1086#1096#1077#1083'/'#1091#1096#1077#1083'/'#1089#1084#1077#1085#1080#1083' '#1085#1080#1082')'
            TabOrder = 4
          end
          object cbDebugMessages: TCheckBox
            Left = 8
            Top = 96
            Width = 317
            Height = 17
            Caption = #1054#1090#1083#1072#1076#1086#1095#1085#1099#1077' '#1089#1086#1086#1073#1097#1077#1085#1080#1103
            TabOrder = 5
          end
          object cbLocalEcho: TCheckBox
            Left = 8
            Top = 112
            Width = 321
            Height = 17
            Caption = #1051#1086#1082#1072#1083#1100#1085#1086#1077' '#1101#1093#1086' ('#1087#1088#1080#1085#1091#1076#1080#1090#1077#1083#1100#1085#1099#1081' '#1087#1088#1080#1077#1084' '#1089#1074#1086#1080#1093' '#1089#1086#1086#1073#1097#1077#1085#1080#1081')'
            TabOrder = 6
          end
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
        DesignSize = (
          357
          305)
        object gbServer: TGroupBox
          Left = 180
          Top = 16
          Width = 165
          Height = 237
          Anchors = [akLeft, akTop, akRight, akBottom]
          Caption = #1057#1077#1088#1074#1077#1088
          TabOrder = 0
          DesignSize = (
            165
            237)
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
            Width = 64
            Height = 13
            Caption = #1053#1086#1084#1077#1088' '#1087#1086#1088#1090#1072
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
            Left = 86
            Top = 65
            Width = 67
            Height = 17
            Anchors = [akTop, akRight]
            Caption = #1059#1076#1072#1083#1080#1090#1100
            TabOrder = 1
            OnClick = DelServerClick
          end
          object editServerName: TEdit
            Left = 48
            Top = 16
            Width = 110
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 2
          end
          object editServerPort: TEdit
            Left = 100
            Top = 40
            Width = 58
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 3
          end
          object listServerList: TListBox
            Left = 8
            Top = 88
            Width = 151
            Height = 141
            Anchors = [akLeft, akTop, akRight, akBottom]
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
          Height = 185
          Anchors = [akLeft, akTop, akBottom]
          Caption = #1053#1080#1082
          TabOrder = 1
          DesignSize = (
            166
            185)
          object listNickList: TListBox
            Left = 8
            Top = 67
            Width = 149
            Height = 110
            Anchors = [akLeft, akTop, akBottom]
            ItemHeight = 13
            Sorted = True
            TabOrder = 0
            OnDblClick = SetNewNick
          end
          object editNick: TEdit
            Left = 8
            Top = 16
            Width = 149
            Height = 21
            TabOrder = 1
          end
          object btnAddNick: TButton
            Left = 10
            Top = 44
            Width = 67
            Height = 17
            Caption = #1044#1086#1073#1072#1074#1080#1090#1100
            TabOrder = 2
            OnClick = AddNickClick
          end
          object btnDelNick: TButton
            Left = 92
            Top = 44
            Width = 67
            Height = 17
            Caption = #1059#1076#1072#1083#1080#1090#1100
            TabOrder = 3
            OnClick = DelNickClick
          end
        end
        object gbProxy: TGroupBox
          Left = 8
          Top = 208
          Width = 165
          Height = 45
          Anchors = [akLeft, akBottom]
          Caption = #1055#1088#1086#1082#1089#1080'-'#1089#1077#1088#1074#1077#1088
          TabOrder = 2
          object editProxyServer: TEdit
            Left = 8
            Top = 16
            Width = 149
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
          Width = 322
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
        Caption = #1064#1072#1073#1083#1086#1085#1099' '#1089#1086#1086#1073#1097#1077#1085#1080#1081
        TabOrder = 0
        object lbTemplates1: TLabel
          Left = 8
          Top = 16
          Width = 295
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
        DesignSize = (
          357
          305)
        object lbSoundTest: TLabel
          Left = 180
          Top = 280
          Width = 161
          Height = 13
          Anchors = [akLeft, akBottom]
          AutoSize = False
          Caption = '- '#1087#1088#1086#1080#1075#1088#1072#1090#1100' '#1074#1099#1073#1088#1072#1085#1099#1081' '#1079#1074#1091#1082
        end
        object vleSounds: TValueListEditor
          Left = 8
          Top = 16
          Width = 337
          Height = 257
          Anchors = [akLeft, akTop, akRight, akBottom]
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
          Anchors = [akLeft, akBottom]
          Caption = '>'
          TabOrder = 1
          OnClick = btnSoundTestClick
        end
        object cbPlaySounds: TCheckBox
          Left = 8
          Top = 280
          Width = 137
          Height = 17
          Anchors = [akLeft, akBottom]
          Caption = #1074#1082#1083#1102#1095#1080#1090#1100' '#1079#1074#1091#1082#1080
          TabOrder = 2
        end
      end
    end
    object tsNotes: TTabSheet
      Caption = 'tsNotes'
      ImageIndex = 7
      object gbNotes: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 305
        Align = alClient
        Caption = #1054#1073#1098#1103#1074#1083#1077#1085#1080#1103
        TabOrder = 0
        DesignSize = (
          357
          305)
        object lbNotesReadme: TLabel
          Left = 8
          Top = 16
          Width = 337
          Height = 33
          AutoSize = False
          Caption = 
            #1042#1072#1096#1080' '#1086#1073#1098#1103#1074#1083#1077#1085#1080#1103' '#1076#1083#1103' '#1076#1086#1089#1082#1080' '#1086#1073#1098#1103#1074#1083#1077#1085#1080#1081'. '#1055#1086#1089#1090#1072#1088#1072#1081#1090#1077#1089#1100' '#1085#1077' '#1076#1077#1083#1072#1090#1100' '#1086#1095#1077 +
            #1085#1100' '#1073#1086#1083#1100#1096#1080#1093' '#1086#1073#1098#1103#1074#1083#1077#1085#1080#1081'.'
          WordWrap = True
        end
        object memoNotes: TMemo
          Left = 8
          Top = 72
          Width = 337
          Height = 225
          Anchors = [akLeft, akTop, akRight, akBottom]
          ScrollBars = ssVertical
          TabOrder = 0
        end
        object cbShowNotesOnJoin: TCheckBox
          Left = 8
          Top = 48
          Width = 305
          Height = 17
          Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1086#1073#1100#1103#1074#1083#1077#1085#1080#1103' '#1087#1088#1080' '#1079#1072#1093#1086#1076#1077' '#1085#1072' '#1082#1072#1085#1072#1083
          TabOrder = 1
        end
      end
    end
  end
end
