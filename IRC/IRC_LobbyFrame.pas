unit IRC_LobbyFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, RVScroll, RichView, StdCtrls, ComCtrls;

type
  TfrmIRCLobby = class(TFrame)
    pgcIRCLobby: TPageControl;
    tsMain: TTabSheet;
    tsMOTD: TTabSheet;
    tsConsole: TTabSheet;
    tsChanServ: TTabSheet;
    tsNickServ: TTabSheet;
    cbDebugMode: TCheckBox;
    tsOper: TTabSheet;
    rvNickServ: TRichView;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
