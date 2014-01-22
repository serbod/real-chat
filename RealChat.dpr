program RealChat;

uses
  Forms,
  ComObj,
  ActiveX,
  Main in 'main.pas' {Form1},
  Core in 'Core.pas',
  OptionsForm in 'OptionsForm.pas' {frmOptions},
  MainOptions in 'MainOptions.pas' {frmMainOptions},
  Misc in 'Misc.pas',
  Configs in 'Configs.pas',
  colors in 'colors.pas' {frmColors},
  Smiles in 'Smiles.pas' {frmSmiles},
  Base64 in 'Base64.pas',
  RC4 in 'RC4.pas',
  Timer in 'Timer.pas',
  EnterCmd in 'EnterCmd.pas' {frmEnterCmd},
  ChangeLanguage in 'ChangeLanguage.pas',
  Sounds in 'Sounds.pas',
  ChatPage in 'ChatPage.pas' {ChatFrame: TFrame},
  Plugins in 'Plugins.pas',
  PluginsFunc in 'PluginsFunc.pas',
  TextDecoder in 'TextDecoder.pas' {frmTextDecoder},
  ClientsFrame in 'ClientsFrame.pas' {FrameClients: TFrame},
  FilesFrame in 'FilesFrame.pas' {FrameFiles: TFrame},
  iChatUnit in 'iChat\iChatUnit.pas',
  iChatOptions in 'iChat\iChatOptions.pas',
  IRC in 'IRC\IRC.pas',
  IRC_Options in 'IRC\IRC_Options.pas' {frmIrcOptions},
  DCC in 'IRC\DCC.pas',
  DCC_FileAccept in 'IRC\DCC_FileAccept.pas' {DCCFileAccept},
  ChanListFrame in 'IRC\ChanListFrame.pas' {FrameChanList: TFrame},
  PluginClient in 'PluginClient.pas',
  InfoFrame in 'InfoFrame.pas' {FrameInfo: TFrame},
  StartupWizard in 'StartupWizard.pas' {frmStartupWizard},
  AsyncSock in 'AsyncSock.pas',
  IRC_ChanOptions in 'IRC\IRC_ChanOptions.pas' {frmChanOptions},
  IRC_LobbyFrame in 'IRC\IRC_LobbyFrame.pas' {frmIRCLobby: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'RealChat';
  Application.CreateForm(TForm1, Form1);
  //Application.CreateForm(TfrmChanOptions, frmChanOptions);
  //Application.CreateForm(TfrmiChatOptions, frmiChatOptions);
  //Application.CreateForm(TfrmStartupWizard, frmStartupWizard);
  //Application.CreateForm(TfrmIrcOptions, frmIrcOptions);
  //Application.CreateForm(TfrmMainOptions, frmMainOptions);
  Application.CreateForm(TfrmOptions, frmOptions);
  //Application.CreateForm(TfrmTextDecoder, frmTextDecoder);
  //Application.CreateForm(TfrmPrivates, frmPrivates);
  //Application.CreateForm(TDCCFileAccept, DCCFileAccept);
  //Application.CreateForm(TfrmChanMaskEnter, frmChanMaskEnter);
  //Application.CreateForm(TForm2, Form2);
  //Application.CreateForm(TfrmColors, frmColors);
  //Application.CreateForm(TfrmSmiles, frmSmiles);
  //Application.ShowMainForm := False;
  CoreStart();
  Application.Run;
end.
