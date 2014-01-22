object FrameFiles: TFrameFiles
  Left = 0
  Top = 0
  Width = 590
  Height = 446
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object FilesGrid: TDrawGrid
    Left = 0
    Top = 0
    Width = 590
    Height = 398
    Align = alClient
    ColCount = 6
    DefaultRowHeight = 14
    FixedCols = 0
    RowCount = 50
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect, goThumbTracking]
    TabOrder = 0
    OnDrawCell = FilesGridOnDrawCell
    OnMouseDown = FilesGridOnMouseDown
  end
  object InfoPanel: TPanel
    Left = 0
    Top = 398
    Width = 590
    Height = 48
    Align = alBottom
    TabOrder = 1
    object InfoText: TLabel
      Left = 1
      Top = 1
      Width = 588
      Height = 46
      Align = alClient
    end
  end
  object FilesGridMenu: TPopupMenu
    Left = 417
    Top = 166
    object mStartFileTransfer: TMenuItem
      Caption = #1042#1086#1079#1086#1073#1085#1086#1074#1080#1090#1100
      Enabled = False
      OnClick = FilesGridPopupClick
    end
    object mStopFileTransfer: TMenuItem
      Caption = #1054#1089#1090#1072#1085#1086#1074#1080#1090#1100
      OnClick = FilesGridPopupClick
    end
    object mResendFile: TMenuItem
      Caption = #1053#1072#1095#1072#1090#1100' '#1079#1072#1085#1086#1074#1086
      OnClick = FilesGridPopupClick
    end
    object mDeleteFileTransfer: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1079#1072#1075#1088#1091#1079#1082#1091
      OnClick = FilesGridPopupClick
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object mOpenFile: TMenuItem
      Caption = #1054#1090#1082#1088#1099#1090#1100' '#1092#1072#1081#1083
      Enabled = False
      OnClick = FilesGridPopupClick
    end
    object mDeleteFile: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1092#1072#1081#1083
      OnClick = FilesGridPopupClick
    end
  end
end
