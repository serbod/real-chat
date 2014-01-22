object frmEnterCmd: TfrmEnterCmd
  Left = 578
  Top = 494
  ActiveControl = edText
  BorderStyle = bsDialog
  Caption = #1059#1082#1072#1078#1080#1090#1077' '#1095#1072#1089#1090#1100' '#1080#1084#1077#1085#1080' '#1082#1072#1085#1072#1083#1072
  ClientHeight = 66
  ClientWidth = 256
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object edText: TEdit
    Left = 8
    Top = 8
    Width = 241
    Height = 21
    TabOrder = 0
    OnKeyDown = edTextKeyDown
  end
  object btnOK: TButton
    Left = 8
    Top = 36
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 168
    Top = 36
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 2
    OnClick = btnCancelClick
  end
end
