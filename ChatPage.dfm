object ChatFrame: TChatFrame
  Left = 0
  Top = 0
  Width = 600
  Height = 411
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object SplitterV: TSplitter
    Left = 447
    Top = 0
    Height = 411
    Align = alRight
    ResizeStyle = rsUpdate
  end
  object RightPanel: TPanel
    Left = 450
    Top = 0
    Width = 150
    Height = 411
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    object AvatarSplitter: TSplitter
      Left = 0
      Top = 300
      Width = 150
      Height = 3
      Cursor = crVSplit
      Align = alBottom
    end
    object UserList: TTreeView
      Left = 0
      Top = 0
      Width = 150
      Height = 300
      Align = alClient
      HotTrack = True
      Indent = 19
      ReadOnly = True
      RowSelect = True
      ShowLines = False
      ShowRoot = False
      SortType = stText
      TabOrder = 0
    end
    object AvatarPanel: TPanel
      Left = 0
      Top = 303
      Width = 150
      Height = 108
      Align = alBottom
      BevelInner = bvLowered
      BevelOuter = bvNone
      TabOrder = 1
    end
  end
  object LeftPanel: TPanel
    Left = 0
    Top = 0
    Width = 447
    Height = 411
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object SplitterH: TSplitter
      Left = 0
      Top = 357
      Width = 447
      Height = 4
      Cursor = crVSplit
      Align = alBottom
      AutoSnap = False
      MinSize = 48
      ResizeStyle = rsUpdate
    end
    object MessPanel: TPanel
      Left = 0
      Top = 361
      Width = 447
      Height = 50
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      object TxtToolBar: TToolBar
        Left = 0
        Top = 0
        Width = 447
        Height = 26
        Images = Form1.ImageList16
        TabOrder = 0
        object btnBold: TToolButton
          Left = 0
          Top = 2
          Action = actBold
          ParentShowHint = False
          ShowHint = True
        end
        object btnItalic: TToolButton
          Left = 23
          Top = 2
          Action = actItalic
          ParentShowHint = False
          ShowHint = True
        end
        object btnUnderline: TToolButton
          Left = 46
          Top = 2
          Action = actUnderline
          ParentShowHint = False
          ShowHint = True
        end
        object tbtnSeparator1: TToolButton
          Left = 69
          Top = 2
          Width = 8
          ImageIndex = 2
          Style = tbsSeparator
        end
        object btnColor: TToolButton
          Left = 77
          Top = 2
          Action = actColor
          ParentShowHint = False
          ShowHint = True
        end
        object btnSmiles: TToolButton
          Left = 100
          Top = 2
          Action = actSmiles
          ParentShowHint = False
          ShowHint = True
        end
        object tbtnSeparator2: TToolButton
          Left = 123
          Top = 2
          Width = 8
          ImageIndex = 1
          Style = tbsSeparator
        end
        object btnFreezeScrolling: TToolButton
          Left = 131
          Top = 2
          Action = actFreezeScrolling
          ParentShowHint = False
          ShowHint = True
        end
        object btnTranslit: TToolButton
          Left = 154
          Top = 2
          Action = actTranslit
        end
        object btnClearText: TToolButton
          Left = 177
          Top = 2
          Action = actClearText
          ParentShowHint = False
          ShowHint = True
        end
      end
      object TxtToSend: TMemo
        Left = 0
        Top = 26
        Width = 447
        Height = 24
        Align = alClient
        ScrollBars = ssVertical
        TabOrder = 1
        WantReturns = False
        WantTabs = True
        WordWrap = False
        OnKeyPress = TxtToSendKeyPress
      end
    end
    object MesText: TRichView
      Left = 0
      Top = 0
      Width = 447
      Height = 357
      Align = alClient
      TabOrder = 1
      AnimationMode = rvaniOnFormat
      BottomMargin = 2
      DoInPaletteMode = rvpaCreateCopies
      HScrollVisible = False
      LeftMargin = 2
      RightMargin = 2
      Style = Form1.MessStyle
      TopMargin = 2
    end
  end
  object TextWindowPopUp: TPopupMenu
    Images = Form1.ImageList16
    OnPopup = TextWindowPopUpPopup
    Left = 54
    Top = 58
    object mCtrlC: TMenuItem
      Action = actCopy
    end
    object mFreezeScrolling: TMenuItem
      Action = actFreezeScrolling
      AutoCheck = True
    end
    object mHScroll: TMenuItem
      Action = actHScroll
      AutoCheck = True
    end
  end
  object UserListContextMenu: TPopupMenu
    AutoPopup = False
    Images = Form1.ImageList16
    Left = 170
    Top = 58
    object mInsertName: TMenuItem
      Caption = #1042#1089#1090#1072#1074#1080#1090#1100
      ImageIndex = 35
      OnClick = mInsertNameClick
    end
    object mInsertPrivate: TMenuItem
      Caption = #1052#1077#1089#1089#1072#1075#1072' '#1076#1083#1103
      ImageIndex = 18
      OnClick = UserListPopupClick
    end
    object mPrivateAll: TMenuItem
      Caption = #1051#1080#1095#1082#1072' '#1074#1089#1077#1084
      Enabled = False
      OnClick = UserListPopupClick
    end
    object mPrivateWith: TMenuItem
      Caption = #1055#1088#1080#1074#1072#1090' '#1089
      ImageIndex = 37
      OnClick = UserListPopupClick
    end
    object mInfoAboutUser: TMenuItem
      Caption = #1048#1085#1092#1072' '#1086
      ImageIndex = 19
      OnClick = UserListPopupClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object mSendFile: TMenuItem
      Caption = #1055#1086#1089#1083#1072#1090#1100' '#1092#1072#1081#1083
      ImageIndex = 4
      OnClick = UserListPopupClick
    end
    object mCreateLine: TMenuItem
      Caption = #1057#1086#1079#1076#1072#1090#1100' '#1083#1080#1085#1080#1102
      OnClick = UserListPopupClick
    end
    object mRefreshUserList: TMenuItem
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100' '#1089#1087#1080#1089#1086#1082
      ImageIndex = 17
      OnClick = UserListPopupClick
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object mIgnorePersonal: TMenuItem
      Caption = #1048#1075#1085#1086#1088' '#1083#1080#1095#1082#1080
      Enabled = False
      OnClick = UserListPopupClick
    end
    object mIgnoreAll: TMenuItem
      Caption = #1048#1075#1085#1086#1088' '#1074#1089#1077#1075#1086
      OnClick = UserListPopupClick
    end
    object mIgnoreForTime: TMenuItem
      Caption = #1048#1075#1085#1086#1088#1080#1088#1086#1074#1072#1090#1100' '#1085#1072' '#1086#1087#1088#1077#1076#1077#1083#1077#1085#1085#1086#1077' '#1074#1088#1077#1084#1103
      Enabled = False
      OnClick = UserListPopupClick
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object mTemplates: TMenuItem
      AutoHotkeys = maManual
      Caption = #1064#1072#1073#1083#1086#1085#1099
      OnClick = UserListPopupClick
    end
    object mActionsSubmenu: TMenuItem
      Caption = #1044#1077#1081#1089#1090#1074#1080#1103
      OnClick = UserListPopupClick
      object mCreateUsersGroup: TMenuItem
        Caption = #1057#1086#1079#1076#1072#1090#1100' '#1075#1088#1091#1087#1087#1091
        OnClick = UserListPopupClick
      end
      object mDeleteUsersGroup: TMenuItem
        Caption = #1059#1076#1072#1083#1080#1090#1100' '#1075#1088#1091#1087#1087#1091
        OnClick = UserListPopupClick
      end
      object mRenameUsersGroup: TMenuItem
        Caption = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100
        OnClick = UserListPopupClick
      end
      object mDefineUserColor: TMenuItem
        Caption = #1053#1072#1079#1085#1072#1095#1080#1090#1100' '#1094#1074#1077#1090
        Enabled = False
        OnClick = UserListPopupClick
      end
    end
  end
  object AvatarPopup: TPopupMenu
    Left = 53
    Top = 158
    object mGetAvatarFromFile: TMenuItem
      Caption = #1040#1074#1072#1090#1072#1088' '#1080#1079' '#1092#1072#1081#1083#1072
      OnClick = AvatarPopupClick
    end
    object mGetAvatarFromURL: TMenuItem
      Caption = #1040#1074#1072#1090#1072#1088' '#1080#1079' URL'
      OnClick = AvatarPopupClick
    end
    object mCheckCurrentUserAvatar: TMenuItem
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100' '#1072#1074#1072#1090#1072#1088' '#1102#1079#1077#1088#1072
      OnClick = AvatarPopupClick
    end
    object mCheckAllUsersAvatar: TMenuItem
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100' '#1072#1074#1072#1090#1072#1088' '#1074#1089#1077#1093' '#1102#1079#1077#1088#1086#1074
      OnClick = AvatarPopupClick
    end
  end
  object actlstChatFrame: TActionList
    Images = Form1.ImageList16
    OnExecute = actlstChatFrameExecute
    Left = 168
    Top = 160
    object actCopy: TAction
      Category = 'TextWindow'
      Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100' (Ctrl+C)'
      ImageIndex = 36
      ShortCut = 16451
      OnExecute = actDummyExecute
    end
    object actFreezeScrolling: TAction
      Category = 'TextWindow'
      AutoCheck = True
      Caption = #1054#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1087#1088#1086#1082#1088#1091#1090#1082#1091
      ImageIndex = 31
      OnExecute = actDummyExecute
    end
    object actHScroll: TAction
      Category = 'TextWindow'
      AutoCheck = True
      Caption = #1043#1086#1088#1080#1079#1086#1085#1090#1072#1083#1100#1085#1072#1103' '#1087#1088#1086#1082#1088#1091#1090#1082#1072
      ImageIndex = 32
      OnExecute = actDummyExecute
    end
    object actBold: TAction
      Category = 'ChatWindow'
      Hint = #1055#1086#1083#1091#1078#1080#1088#1085#1099#1081' '#1090#1077#1082#1089#1090
      ImageIndex = 10
      OnExecute = actDummyExecute
    end
    object actItalic: TAction
      Category = 'ChatWindow'
      Hint = #1053#1072#1082#1083#1086#1085#1085#1099#1081' '#1090#1077#1082#1089#1090
      ImageIndex = 11
      OnExecute = actDummyExecute
    end
    object actUnderline: TAction
      Category = 'ChatWindow'
      Caption = 'actUnderline'
      Hint = #1055#1086#1076#1095#1077#1088#1082#1085#1091#1090#1099#1081' '#1090#1077#1082#1089#1090
      ImageIndex = 12
      OnExecute = actDummyExecute
    end
    object actColor: TAction
      Category = 'ChatWindow'
      Hint = #1042#1099#1073#1086#1088' '#1094#1074#1077#1090#1072
      ImageIndex = 13
      OnExecute = actDummyExecute
    end
    object actSmiles: TAction
      Category = 'ChatWindow'
      Hint = #1057#1084#1072#1081#1083#1099
      ImageIndex = 14
      OnExecute = actDummyExecute
    end
    object actClearText: TAction
      Category = 'TextWindow'
      Caption = #1054#1095#1080#1089#1090#1080#1090#1100' '#1089#1090#1088#1072#1085#1080#1094#1091
      Hint = #1054#1095#1080#1089#1090#1080#1090#1100' '#1089#1090#1088#1072#1085#1080#1094#1091
      ImageIndex = 15
      OnExecute = actDummyExecute
    end
    object actTranslit: TAction
      Category = 'ChatWindow'
      AutoCheck = True
      Caption = 'Translit'
      Hint = #1058#1088#1072#1085#1089#1083#1080#1090
      ImageIndex = 38
      OnExecute = actDummyExecute
    end
  end
end
