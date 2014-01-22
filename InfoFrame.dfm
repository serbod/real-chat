object FrameInfo: TFrameInfo
  Left = 0
  Top = 0
  Width = 571
  Height = 340
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object panCenter: TPanel
    Left = 0
    Top = 0
    Width = 571
    Height = 340
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 197
      Top = 0
      Height = 340
    end
    object tvContents: TTreeView
      Left = 0
      Top = 0
      Width = 197
      Height = 340
      Align = alLeft
      Indent = 19
      ReadOnly = True
      TabOrder = 0
      OnClick = tvContentsClick
      OnKeyDown = tvContentsKeyDown
    end
    object rvMesText: TRichView
      Left = 200
      Top = 0
      Width = 371
      Height = 340
      Align = alClient
      TabOrder = 1
      DoInPaletteMode = rvpaCreateCopies
      RTFReadProperties.TextStyleMode = rvrsAddIfNeeded
      RTFReadProperties.ParaStyleMode = rvrsAddIfNeeded
      RVFOptions = [rvfoSavePicturesBody, rvfoSaveControlsBody, rvfoSaveBinary, rvfoSaveTextStyles, rvfoSaveParaStyles, rvfoSaveDocProperties, rvfoLoadDocProperties]
      Style = Form1.MessStyle
    end
  end
end
