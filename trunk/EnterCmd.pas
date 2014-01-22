unit EnterCmd;

interface

uses
  SysUtils, Controls, Forms, StdCtrls, Core, Classes;

type
  TfrmEnterCmd = class(TForm)
    edText: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure edTextKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    template: string;
    default: string;
    PageID: integer;
    modal: boolean;
  end;

var
  frmEnterCmd: TfrmEnterCmd;

implementation

uses Main;

{$R *.dfm}

procedure TfrmEnterCmd.btnOKClick(Sender: TObject);
var s: string;
begin
  if modal then Exit;
  if Trim(edText.Text)<>'' then
  begin
    s:=StringReplace(template, '&s', Trim(edText.Text),[]);
  end
  else
  begin
    s:=StringReplace(template, '&s', default,[]);
  end;
  //Say('/RAW LIST *'+Trim(edChanMask.Text)+'*');
  Core.Say(s, PageID);
  Close;
end;

procedure TfrmEnterCmd.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmEnterCmd.edTextKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if key=13 then btnOK.Click;
end;

procedure TfrmEnterCmd.FormCreate(Sender: TObject);
begin
  template:='';
  default:='';
  modal:=false;
end;

end.
