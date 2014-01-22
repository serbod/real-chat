object frmMainOptions: TfrmMainOptions
  Left = 405
  Top = 369
  Width = 400
  Height = 380
  Caption = 'frmMainOptions'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 11
    Top = 8
    Width = 365
    Height = 337
    ActivePage = tsLanguage
    TabOrder = 0
    Visible = False
    object tsTemplates: TTabSheet
      Caption = 'tsTemplates'
      object gbTemplates: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 309
        Align = alClient
        Caption = 'gbTemplates'
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
      ImageIndex = 1
      object gbSounds: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 309
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
            'Event'
            'Sound file')
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
    object tsSmiles: TTabSheet
      Caption = 'tsSmiles'
      ImageIndex = 2
      object gbSmiles: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 309
        Align = alClient
        Caption = #1057#1084#1072#1081#1083#1099
        TabOrder = 0
        Visible = False
        object lbSmilesCount: TLabel
          Left = 10
          Top = 17
          Width = 256
          Height = 13
          Caption = #1052#1072#1082#1089#1080#1084#1072#1083#1100#1085#1086#1077' '#1082#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1089#1084#1072#1081#1083#1086#1074' '#1074' 1 '#1089#1086#1086#1073#1097#1077#1085#1080#1080
        end
        object cbSmilesCloseAfterSelect: TCheckBox
          Left = 10
          Top = 34
          Width = 273
          Height = 17
          Caption = #1047#1072#1082#1088#1099#1074#1072#1090#1100' '#1086#1082#1085#1086' '#1089#1084#1072#1081#1083#1086#1074' '#1087#1086#1089#1083#1077' '#1074#1099#1073#1086#1088#1072' '#1089#1084#1072#1081#1083#1072
          TabOrder = 0
        end
        object editSmilesCount: TEdit
          Left = 278
          Top = 14
          Width = 45
          Height = 21
          TabOrder = 1
          Text = '0'
        end
        object UpDownSmilesCount: TUpDown
          Left = 323
          Top = 14
          Width = 12
          Height = 21
          Associate = editSmilesCount
          Max = 1000
          TabOrder = 2
        end
      end
    end
    object tsPlugins: TTabSheet
      Caption = 'tsPlugins'
      ImageIndex = 3
      object gbPlugins: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 309
        Align = alClient
        Caption = #1055#1083#1072#1075#1080#1085#1099
        TabOrder = 0
        object lbPluginInfo: TLabel
          Left = 8
          Top = 248
          Width = 337
          Height = 49
          AutoSize = False
          WordWrap = True
        end
        object lvPluginsList: TListView
          Left = 8
          Top = 20
          Width = 337
          Height = 221
          Columns = <
            item
              Caption = 'Name'
              Width = 80
            end
            item
              Caption = 'Description'
              Width = 200
            end
            item
              Caption = 'Version'
            end>
          GridLines = True
          HotTrack = True
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
          OnSelectItem = lvPluginsListSelectItem
        end
      end
    end
    object tsNotesGrabber: TTabSheet
      Caption = 'tsNotesGrabber'
      ImageIndex = 4
      object gbNotesGrabber: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 309
        Align = alClient
        Caption = #1057#1073#1086#1088#1097#1080#1082' '#1079#1072#1084#1077#1090#1086#1082
        TabOrder = 0
        object lbNotesGrabberReadme: TLabel
          Left = 12
          Top = 20
          Width = 329
          Height = 41
          AutoSize = False
          Caption = 
            #1050#1083#1102#1095#1077#1074#1099#1077' '#1089#1083#1086#1074#1072', '#1087#1086' '#1082#1086#1090#1086#1088#1099#1084' '#1089#1086#1086#1073#1097#1077#1085#1080#1103' '#1073#1091#1076#1091#1090' '#1082#1086#1087#1080#1088#1086#1074#1072#1090#1100#1089#1103' '#1074' '#1079#1072#1082#1083#1072#1076 +
            #1082#1091' '#1079#1072#1084#1077#1090#1086#1082'. '#1053#1077#1089#1082#1086#1083#1100#1082#1086' '#1089#1083#1086#1074' '#1074' '#1089#1090#1088#1086#1082#1077' '#1088#1072#1089#1089#1084#1072#1090#1088#1080#1074#1072#1102#1090#1089#1103' '#1082#1072#1082' '#1086#1076#1085#1072' '#1092#1088#1072 +
            #1079#1072'.'
          WordWrap = True
        end
        object memoGrabKeywords: TMemo
          Left = 8
          Top = 72
          Width = 337
          Height = 221
          TabOrder = 0
        end
      end
    end
    object tsNotes: TTabSheet
      Caption = 'tsNotes'
      ImageIndex = 5
      object gbNotes: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 309
        Align = alClient
        Caption = #1054#1073#1100#1103#1074#1083#1077#1085#1080#1103
        TabOrder = 0
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
    object tsMain: TTabSheet
      Caption = 'tsMain'
      ImageIndex = 7
      object gbMain: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 309
        Align = alClient
        Caption = #1054#1073#1097#1080#1077' '#1085#1072#1089#1090#1088#1086#1081#1082#1080
        TabOrder = 0
        Visible = False
        object lbHotkey: TLabel
          Left = 8
          Top = 176
          Width = 105
          Height = 13
          Caption = 'Hotkey (need restart)'
        end
        object cbCopySelected: TCheckBox
          Left = 8
          Top = 16
          Width = 297
          Height = 17
          Caption = #1041#1099#1089#1090#1088#1086#1077' '#1082#1086#1087#1080#1088#1086#1074#1072#1085#1080#1077' ('#1087#1088#1080' '#1074#1099#1076#1077#1083#1077#1085#1080#1080')'
          TabOrder = 0
        end
        object cbNotifyPrivates: TCheckBox
          Left = 8
          Top = 32
          Width = 241
          Height = 17
          Caption = #1055#1088#1080#1074#1072#1090#1099' '#1074' '#1074#1080#1076#1077' '#1079#1072#1087#1080#1089#1086#1082
          TabOrder = 1
        end
        object cbNotifyAllMessages: TCheckBox
          Left = 8
          Top = 48
          Width = 233
          Height = 17
          Caption = #1042#1089#1077' '#1089#1086#1086#1073#1097#1077#1085#1080#1103' '#1074' '#1074#1080#1076#1077' '#1079#1072#1087#1080#1089#1086#1082
          TabOrder = 2
        end
        object cbUserlistCheckboxes: TCheckBox
          Left = 8
          Top = 80
          Width = 337
          Height = 17
          Caption = #1055#1086#1084#1077#1090#1082#1072' '#1087#1086#1083#1091#1095#1072#1090#1077#1083#1077#1081' ('#1076#1083#1103' '#1087#1088#1080#1074#1072#1090#1086#1074' '#1087#1086' Alt-Enter)'
          TabOrder = 3
        end
        object cbPopupPrivate: TCheckBox
          Left = 8
          Top = 64
          Width = 281
          Height = 17
          Caption = #1042#1089#1087#1083#1099#1074#1072#1102#1097#1077#1077' '#1086#1082#1086#1096#1082#1086' '#1087#1088#1080' '#1087#1086#1089#1090#1091#1087#1083#1077#1085#1080#1080' '#1087#1088#1080#1074#1072#1090#1072
          TabOrder = 4
        end
        object cbUseAvatars: TCheckBox
          Left = 8
          Top = 140
          Width = 281
          Height = 17
          Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1072#1074#1072#1090#1072#1088#1099
          TabOrder = 5
        end
        object cbLogMessages: TCheckBox
          Left = 8
          Top = 124
          Width = 293
          Height = 17
          Caption = #1057#1086#1093#1088#1072#1085#1103#1090#1100' '#1080#1089#1090#1086#1088#1080#1102' '#1089#1086#1086#1073#1097#1077#1085#1080#1081
          Enabled = False
          TabOrder = 6
        end
        object cbSendMsgOnCtrlEnter: TCheckBox
          Left = 8
          Top = 96
          Width = 329
          Height = 17
          Caption = 'Enter - '#1085#1086#1074#1072#1103' '#1089#1090#1088#1086#1082#1072', Ctrl-Enter - '#1086#1090#1087#1088#1072#1074#1080#1090#1100' ('#1080#1085#1072#1095#1077' '#1085#1072#1086#1073#1086#1088#1086#1090')'
          TabOrder = 7
        end
        object edHotkey: TEdit
          Left = 8
          Top = 192
          Width = 101
          Height = 21
          ReadOnly = True
          TabOrder = 8
          OnKeyDown = edHotkeyKeyDown
        end
      end
    end
    object tsIgnore: TTabSheet
      Caption = 'tsIgnore'
      ImageIndex = 10
      object gbIgnore: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 309
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
    object tsFonts: TTabSheet
      Caption = 'tsFonts'
      ImageIndex = 11
      object gbFonts: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 309
        Align = alClient
        Caption = #1064#1088#1080#1092#1090#1099
        TabOrder = 0
        Visible = False
        object lbFontSelect: TListBox
          Left = 8
          Top = 16
          Width = 337
          Height = 281
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemHeight = 16
          Items.Strings = (
            #1054#1089#1085#1086#1074#1085#1086#1077' '#1086#1082#1085#1086' '#1095#1072#1090#1072
            #1057#1087#1080#1089#1086#1082' '#1080#1084#1077#1085
            #1055#1086#1083#1077' '#1074#1074#1086#1076#1072' '#1089#1086#1086#1073#1097#1077#1085#1080#1103)
          ParentFont = False
          TabOrder = 0
          OnClick = lbFontSelectClick
        end
      end
    end
    object tsFastMsg: TTabSheet
      Caption = 'tsFastMsg'
      ImageIndex = 12
      object gbFastMsg: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 309
        Align = alClient
        Caption = #1041#1099#1089#1090#1088#1099#1077' '#1089#1086#1086#1073#1097#1077#1085#1080#1103
        TabOrder = 0
        Visible = False
        object lbFM1: TLabel
          Left = 16
          Top = 16
          Width = 200
          Height = 13
          AutoSize = False
          Caption = #1050#1072#1078#1076#1072#1103' '#1089#1090#1088#1086#1082#1072' - '#1086#1090#1076#1077#1083#1100#1085#1086#1077' '#1089#1086#1086#1073#1097#1077#1085#1080#1077
          WordWrap = True
        end
        object memoFastMsg: TMemo
          Left = 8
          Top = 40
          Width = 337
          Height = 257
          TabOrder = 0
        end
      end
    end
    object tsProxy: TTabSheet
      Caption = 'tsProxy'
      ImageIndex = 13
      object gbProxy: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 309
        Align = alClient
        Caption = #1055#1088#1086#1082#1089#1080
        TabOrder = 0
        Visible = False
        object gbProxyList: TGroupBox
          Left = 8
          Top = 20
          Width = 337
          Height = 245
          Caption = 'Proxy - c'#1077#1088#1074#1077#1088#1072
          TabOrder = 0
          object lbProxyHost: TLabel
            Left = 6
            Top = 18
            Width = 31
            Height = 13
            Caption = #1040#1076#1088#1077#1089
          end
          object lbProxyPort: TLabel
            Left = 6
            Top = 42
            Width = 25
            Height = 13
            Caption = #1055#1086#1088#1090
          end
          object lbProxyUser: TLabel
            Left = 168
            Top = 20
            Width = 29
            Height = 13
            Caption = #1083#1086#1075#1080#1085
          end
          object lbProxyPass: TLabel
            Left = 168
            Top = 44
            Width = 36
            Height = 13
            Caption = #1087#1072#1088#1086#1083#1100
          end
          object lbProxyType: TLabel
            Left = 8
            Top = 64
            Width = 18
            Height = 13
            Caption = #1058#1080#1087
          end
          object btnAddProxy: TButton
            Left = 170
            Top = 69
            Width = 67
            Height = 17
            Caption = #1044#1086#1073#1072#1074#1080#1090#1100
            TabOrder = 0
            OnClick = btnAddProxyClick
          end
          object btnDelProxy: TButton
            Left = 259
            Top = 69
            Width = 67
            Height = 17
            Caption = #1059#1076#1072#1083#1080#1090#1100
            TabOrder = 1
            OnClick = btnDelProxyClick
          end
          object edProxyHost: TEdit
            Left = 48
            Top = 16
            Width = 111
            Height = 21
            TabOrder = 2
          end
          object edProxyPort: TEdit
            Left = 68
            Top = 40
            Width = 91
            Height = 21
            TabOrder = 3
          end
          object edProxyUser: TEdit
            Left = 224
            Top = 16
            Width = 105
            Height = 21
            TabOrder = 4
          end
          object edProxyPass: TEdit
            Left = 224
            Top = 40
            Width = 105
            Height = 21
            TabOrder = 5
          end
          object cboxProxyType: TComboBox
            Left = 68
            Top = 64
            Width = 93
            Height = 21
            ItemHeight = 13
            ItemIndex = 0
            TabOrder = 6
            Text = 'HTTP'
            Items.Strings = (
              'HTTP'
              'HTTPS'
              'SOCKS'
              'SOCKS4'
              'SOCKS5')
          end
          object memoProxyList: TMemo
            Left = 8
            Top = 92
            Width = 321
            Height = 141
            TabOrder = 7
          end
        end
      end
    end
    object tsAutojoin: TTabSheet
      Caption = 'tsAutojoin'
      ImageIndex = 14
      object gbAutojoin: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 309
        Align = alClient
        Caption = #1050#1086#1084#1072#1085#1076#1099' '#1087#1088#1080' '#1079#1072#1087#1091#1089#1082#1077' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
        TabOrder = 0
        Visible = False
        object lbAJList: TLabel
          Left = 16
          Top = 16
          Width = 313
          Height = 25
          AutoSize = False
          Caption = 
            #1057#1087#1080#1089#1086#1082' '#1082#1086#1084#1072#1085#1076', '#1074#1099#1087#1086#1083#1085#1103#1077#1084#1099#1093' '#1087#1088#1080' '#1079#1072#1087#1091#1089#1082#1077' '#1087#1088#1086#1075#1088#1072#1084#1084#1099'. '#1054#1076#1085#1072' '#1089#1090#1088#1086#1082#1072' - ' +
            #1086#1076#1085#1072' '#1082#1086#1084#1072#1085#1076#1072'.'
          WordWrap = True
        end
        object memoAutojoinList: TMemo
          Left = 8
          Top = 48
          Width = 337
          Height = 249
          TabOrder = 0
        end
      end
    end
    object tsMessages: TTabSheet
      Caption = 'tsMessages'
      ImageIndex = 12
      object gbMessages: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 309
        Align = alClient
        Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1103
        TabOrder = 0
      end
    end
    object tsLanguage: TTabSheet
      Caption = 'tsLanguage'
      ImageIndex = 13
      object gbLanguage: TGroupBox
        Left = 0
        Top = 0
        Width = 357
        Height = 309
        Align = alClient
        Caption = #1071#1079#1099#1082' / Language'
        TabOrder = 0
        object lbLangInfo: TLabel
          Left = 200
          Top = 68
          Width = 145
          Height = 225
          AutoSize = False
        end
        object listboxLangs: TListBox
          Left = 12
          Top = 24
          Width = 177
          Height = 269
          ItemHeight = 13
          TabOrder = 0
          OnClick = listboxLangsClick
        end
        object btnLoadLang: TButton
          Left = 200
          Top = 28
          Width = 149
          Height = 25
          Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' / Load'
          TabOrder = 1
          OnClick = btnLoadLangClick
        end
      end
    end
  end
end
