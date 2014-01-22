unit DCC_FileAccept;

interface

uses
  Controls, Forms, StdCtrls, Classes, Dialogs, SysUtils, DCC;

type
  TDCCFileAccept = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lbSenderName: TLabel;
    lbSenderAddress: TLabel;
    lbSenderIP: TLabel;
    GroupBox2: TGroupBox;
    lbFileName: TLabel;
    edPathName: TEdit;
    btnSelectDirectory: TButton;
    Label4: TLabel;
    btnAccept: TButton;
    btnCancel: TButton;
    Label5: TLabel;
    lbFileSize: TLabel;
    procedure btnSelectDirectoryClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnAcceptClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ConnInfo: TConnInfo;
  end;

var
  DCCFileAccept: TDCCFileAccept;

implementation

{$R *.dfm}

procedure TDCCFileAccept.btnSelectDirectoryClick(Sender: TObject);
var
  SaveDialog: TSaveDialog;
begin
  SaveDialog:=TSaveDialog.Create(self);
  SaveDialog.InitialDir:=edPathName.Text;
  SaveDialog.FileName:=lbFileName.Caption;
  SaveDialog.Title:='Сохранить как:';
  if not SaveDialog.Execute then Exit;
  ConnInfo.sFileName:=SaveDialog.FileName;
  FormShow(nil);
end;

procedure TDCCFileAccept.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TDCCFileAccept.btnAcceptClick(Sender: TObject);
begin
  DCC_OpenDCCFileConn(ConnInfo);
  Close;
end;

procedure TDCCFileAccept.FormShow(Sender: TObject);
begin
  lbSenderName.Caption:=ConnInfo.sClientNick;
  lbSenderAddress.Caption:=ConnInfo.sClientHost;
  lbSenderIP.Caption:=ConnInfo.sClientIP;
  lbFileName.Caption:=ExtractFilename(ConnInfo.sFileName);
  lbFileSize.Caption:=IntToStr(ConnInfo.FileSize);
  edPathName.Text:=ExtractFilePath(ConnInfo.sFileName);
end;

end.
