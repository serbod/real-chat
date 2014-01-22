object frmStartupWizard: TfrmStartupWizard
  Left = 436
  Top = 327
  BorderStyle = bsSingle
  Caption = 'RealChat'
  ClientHeight = 289
  ClientWidth = 381
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pcWizardPages: TPageControl
    Left = 0
    Top = 0
    Width = 381
    Height = 289
    ActivePage = tsIRC
    Align = alClient
    TabOrder = 0
    object tsLanguage: TTabSheet
      Caption = 'tsLanguage'
      object lbLangInfo: TLabel
        Left = 200
        Top = 16
        Width = 169
        Height = 201
        AutoSize = False
        Caption = 'Language info'
        WordWrap = True
      end
      object lboxLang: TListBox
        Left = 8
        Top = 12
        Width = 181
        Height = 241
        ItemHeight = 13
        TabOrder = 0
        OnClick = lboxLangClick
      end
      object btn1_Next: TButton
        Left = 300
        Top = 192
        Width = 67
        Height = 25
        Caption = '>>>'
        TabOrder = 1
        OnClick = btnClick
      end
    end
    object tsUserData: TTabSheet
      Caption = 'tsUserData'
      ImageIndex = 1
      object gbUserInfo: TGroupBox
        Left = 4
        Top = 152
        Width = 281
        Height = 101
        Caption = 'User information'
        TabOrder = 0
        object lbFirstNick: TLabel
          Left = 8
          Top = 20
          Width = 93
          Height = 17
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Main nick'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object lbSecondNick: TLabel
          Left = 8
          Top = 48
          Width = 95
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Second nick'
        end
        object lbUserFullName: TLabel
          Left = 8
          Top = 76
          Width = 94
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Full name'
        end
        object edFirstNick: TEdit
          Left = 108
          Top = 16
          Width = 165
          Height = 21
          TabOrder = 0
        end
        object edSecondNick: TEdit
          Left = 108
          Top = 44
          Width = 165
          Height = 21
          TabOrder = 1
        end
        object edFullName: TEdit
          Left = 108
          Top = 72
          Width = 165
          Height = 21
          TabOrder = 2
        end
      end
      object gbAdditionalInfo: TGroupBox
        Left = 4
        Top = 4
        Width = 353
        Height = 141
        Caption = 'Additional information'
        TabOrder = 1
        object lbAvatarURL: TLabel
          Left = 12
          Top = 16
          Width = 123
          Height = 13
          Caption = 'User'#39's Avatar picture URL'
        end
        object lbAwayMessage: TLabel
          Left = 12
          Top = 56
          Width = 101
          Height = 13
          Caption = 'Away mode message'
        end
        object lbQuitMessage: TLabel
          Left = 12
          Top = 96
          Width = 78
          Height = 13
          Caption = 'Message on quit'
        end
        object edAvatarURL: TEdit
          Left = 8
          Top = 32
          Width = 333
          Height = 21
          TabOrder = 0
        end
        object edAwayMessage: TEdit
          Left = 8
          Top = 72
          Width = 333
          Height = 21
          TabOrder = 1
        end
        object edQuitMessage: TEdit
          Left = 8
          Top = 112
          Width = 333
          Height = 21
          TabOrder = 2
        end
      end
      object btn2_Next: TButton
        Left = 300
        Top = 192
        Width = 67
        Height = 25
        Caption = '>>>'
        TabOrder = 2
        OnClick = btnClick
      end
      object btn2_Prev: TButton
        Left = 300
        Top = 224
        Width = 67
        Height = 25
        Caption = '<<<'
        TabOrder = 3
        OnClick = btnClick
      end
    end
    object tsIRC: TTabSheet
      Caption = 'tsIRC'
      ImageIndex = 2
      object lbIrcReadme: TLabel
        Left = 164
        Top = 116
        Width = 121
        Height = 137
        AutoSize = False
        Caption = 
          'Please, fill list of your favorite channel'#39's. One string - one c' +
          'hannel.'
        WordWrap = True
      end
      object lbIrcChannels: TLabel
        Left = 8
        Top = 116
        Width = 85
        Height = 13
        Caption = 'Favorite channels'
      end
      object gbIrcServer: TGroupBox
        Left = 4
        Top = 4
        Width = 361
        Height = 105
        Caption = 'IRC Server'
        TabOrder = 0
        object lbIrcHost: TLabel
          Left = 16
          Top = 20
          Width = 93
          Height = 13
          Caption = 'IRC server address'
        end
        object lbIrcPort: TLabel
          Left = 296
          Top = 20
          Width = 20
          Height = 13
          Caption = 'port'
        end
        object lbIrcProxy: TLabel
          Left = 16
          Top = 60
          Width = 159
          Height = 13
          Caption = 'Proxy server (optional) host:port'
        end
        object lbIrcProxyType: TLabel
          Left = 236
          Top = 60
          Width = 53
          Height = 13
          Caption = 'Proxy type'
        end
        object edIrcHost: TEdit
          Left = 12
          Top = 36
          Width = 273
          Height = 21
          TabOrder = 0
        end
        object edIrcPort: TEdit
          Left = 292
          Top = 36
          Width = 61
          Height = 21
          TabOrder = 1
        end
        object edIrcProxy: TEdit
          Left = 12
          Top = 76
          Width = 209
          Height = 21
          TabOrder = 2
        end
        object cboxIrcProxyType: TComboBox
          Left = 232
          Top = 76
          Width = 121
          Height = 21
          ItemHeight = 13
          TabOrder = 3
        end
      end
      object btn3_Next: TButton
        Left = 300
        Top = 192
        Width = 67
        Height = 25
        Caption = '>>>'
        TabOrder = 1
        OnClick = btnClick
      end
      object btn3_Prev: TButton
        Left = 300
        Top = 224
        Width = 67
        Height = 25
        Caption = '<<<'
        TabOrder = 2
        OnClick = btnClick
      end
      object memoIrcChannels: TMemo
        Left = 8
        Top = 136
        Width = 145
        Height = 117
        Lines.Strings = (
          '#help')
        TabOrder = 3
      end
    end
    object tsFinish: TTabSheet
      Caption = 'tsFinish'
      ImageIndex = 3
      object lbFinalNote: TLabel
        Left = 8
        Top = 12
        Width = 357
        Height = 169
        AutoSize = False
        Caption = 'Congtatulations!'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object btn4_Next: TButton
        Left = 300
        Top = 192
        Width = 67
        Height = 25
        Caption = '>>>'
        TabOrder = 0
        OnClick = btnClick
      end
      object btn4_Prev: TButton
        Left = 300
        Top = 224
        Width = 67
        Height = 25
        Caption = '<<<'
        TabOrder = 1
        OnClick = btnClick
      end
    end
  end
end
