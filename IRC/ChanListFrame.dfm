object FrameChanList: TFrameChanList
  Left = 0
  Top = 0
  Width = 566
  Height = 400
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object MesText: TRichView
    Left = 0
    Top = 0
    Width = 566
    Height = 344
    Align = alClient
    TabOrder = 0
    BottomMargin = 2
    DoInPaletteMode = rvpaCreateCopies
    HScrollVisible = False
    LeftMargin = 2
    RightMargin = 2
    TopMargin = 2
  end
  object InfoPanel: TPanel
    Left = 0
    Top = 344
    Width = 566
    Height = 56
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      566
      56)
    object InfoText: TLabel
      Left = 1
      Top = 1
      Width = 564
      Height = 54
      Align = alClient
    end
    object lbChanCountName: TLabel
      Left = 176
      Top = 4
      Width = 121
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1082#1072#1085#1072#1083#1086#1074':'
    end
    object lbChanCount: TLabel
      Left = 300
      Top = 4
      Width = 8
      Height = 13
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object TxtToSend: TEdit
      Left = 4
      Top = 28
      Width = 557
      Height = 21
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
      OnKeyDown = ChanSearchKeyDown
    end
    object btnSortByNames: TButton
      Left = 6
      Top = 5
      Width = 79
      Height = 20
      Caption = 'SortByNames'
      TabOrder = 1
      OnClick = SortByNamesClick
    end
    object btnSortByUsers: TButton
      Left = 92
      Top = 5
      Width = 80
      Height = 20
      Caption = 'SortByUsers'
      TabOrder = 2
      OnClick = SortByUsersClick
    end
  end
end
