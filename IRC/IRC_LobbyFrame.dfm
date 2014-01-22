object frmIRCLobby: TfrmIRCLobby
  Left = 0
  Top = 0
  Width = 747
  Height = 487
  TabOrder = 0
  object pgcIRCLobby: TPageControl
    Left = 0
    Top = 0
    Width = 747
    Height = 487
    ActivePage = tsNickServ
    Align = alClient
    TabOrder = 0
    object tsMain: TTabSheet
      Caption = 'Main'
      object cbDebugMode: TCheckBox
        Left = 40
        Top = 8
        Width = 97
        Height = 17
        Caption = 'cbDebugMode'
        TabOrder = 0
      end
    end
    object tsMOTD: TTabSheet
      Caption = 'MOTD'
      ImageIndex = 1
    end
    object tsConsole: TTabSheet
      Caption = 'Console'
      ImageIndex = 2
    end
    object tsChanServ: TTabSheet
      Caption = 'ChanServ'
      ImageIndex = 3
    end
    object tsNickServ: TTabSheet
      Caption = 'NickServ'
      ImageIndex = 4
      DesignSize = (
        739
        459)
      object rvNickServ: TRichView
        Left = 0
        Top = 0
        Width = 737
        Height = 281
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 0
        DoInPaletteMode = rvpaCreateCopies
      end
    end
    object tsOper: TTabSheet
      Caption = 'Oper'
      ImageIndex = 5
    end
  end
end
