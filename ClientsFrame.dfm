object FrameClients: TFrameClients
  Left = 0
  Top = 0
  Width = 435
  Height = 266
  Align = alClient
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object panTop: TPanel
    Left = 0
    Top = 35
    Width = 435
    Height = 231
    Align = alClient
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 193
      Top = 1
      Height = 229
    end
    object tvClientsList: TTreeView
      Left = 1
      Top = 1
      Width = 192
      Height = 229
      Align = alLeft
      Indent = 19
      ParentShowHint = False
      ReadOnly = True
      RightClickSelect = True
      RowSelect = True
      ShowHint = False
      TabOrder = 0
      OnClick = tvClientsListClick
      OnDblClick = tvClientsListDblClick
    end
    object panRight: TPanel
      Left = 196
      Top = 1
      Width = 238
      Height = 229
      Align = alClient
      TabOrder = 1
      object MesText: TRichView
        Left = 1
        Top = 1
        Width = 236
        Height = 227
        Align = alClient
        TabOrder = 0
        DoInPaletteMode = rvpaCreateCopies
        Style = Form1.MessStyle
      end
    end
  end
  object tbButtons: TToolBar
    Left = 0
    Top = 0
    Width = 435
    Height = 35
    ButtonHeight = 30
    ButtonWidth = 31
    Caption = 'tbButtons'
    Images = Form1.ImageList24
    TabOrder = 1
    object tbtnRefresh: TToolButton
      Left = 0
      Top = 2
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100
      Caption = 'tbtnRefresh'
      ImageIndex = 10
      OnClick = tbtnRefreshClick
    end
    object tbtnConnect: TToolButton
      Left = 31
      Top = 2
      Hint = #1055#1086#1076#1082#1083#1102#1095#1080#1090#1089#1103
      Caption = 'tbtnConnect'
      ImageIndex = 1
      OnClick = tbtnConnectClick
    end
    object tbtnClear: TToolButton
      Left = 62
      Top = 2
      Hint = 'Clear'
      Caption = 'tbtnClear'
      ImageIndex = 0
      OnClick = tbtnClearClick
    end
    object tbtnVScrollStop: TToolButton
      Left = 93
      Top = 2
      Hint = 'Stop scrolling'
      Caption = 'tbtnVScrollStop'
      ImageIndex = 9
      OnClick = tbtnVScrollStopClick
    end
    object ToolButton4: TToolButton
      Left = 124
      Top = 2
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 3
      Style = tbsSeparator
    end
    object tbtnAddIRCClient: TToolButton
      Left = 132
      Top = 2
      Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1082#1083#1080#1077#1085#1090#1072' IRC'
      Caption = 'tbtnAddIRCClient'
      ImageIndex = 11
      OnClick = tbtnAddIRCClientClick
    end
    object tbtnAddIChatClient: TToolButton
      Left = 163
      Top = 2
      Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1082#1083#1080#1077#1085#1090#1072' IntranetChat'
      Caption = 'tbtnAddIChatClient'
      ImageIndex = 12
      OnClick = tbtnAddIChatClientClick
    end
    object tbtnRemoveClient: TToolButton
      Left = 194
      Top = 2
      Hint = #1059#1076#1072#1083#1080#1090#1100' '#1074#1099#1073#1088#1072#1085#1086#1075#1086' '#1082#1083#1080#1077#1085#1090#1072
      Caption = 'tbtnRemoveClient'
      ImageIndex = 13
      OnClick = tbtnRemoveClientClick
    end
  end
end
