unit Smiles;

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, RVScroll, RichView, ExtCtrls, ComCtrls, GifImage, RVGifAnimate, CRVFData,
  RVStyle, StdCtrls, IniFiles, Masks;

type
  TfrmSmiles = class(TForm)
    fldrView: TTreeView;
    Splitter1: TSplitter;
    smlView: TRichView;
    RVStyle1: TRVStyle;
    panLeft: TPanel;
    cbCloseAfterSelect: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure fldrViewChange(Sender: TObject; Node: TTreeNode);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure smlViewJump(Sender: TObject; id: Integer);
    procedure smlViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbCloseAfterSelectClick(Sender: TObject);
  private
    { Private declarations }
    CurNode: TTreeNode;
  public
    { Public declarations }
  end;
  	function ExtractFileNameEx(FileName: string; ShowExtension: Boolean): string;
    //procedure FindFiles(StartFolder, Mask: string);

procedure LoadSmilesIni();

var
  frmSmiles: TfrmSmiles;
  smPath: string;
  smList: TStringList;

const
  MAX_SMILES_ON_PAGE=500;

implementation
uses
	Core, Misc;
{$R *.dfm}

procedure LoadSmilesIni();
var
  ini: TIniFile;
begin
  if smList <> nil then Exit;
  smList:=TStringList.Create;
  // Стандартный TIniFile не позволяет читать параметры с одинаковыми названиями,
  // но разными значениями в пределах одной секции..
  //
	//ini := TIniFile.Create(conf.SettingsFile);
	ini := TIniFile.Create(Core.glHomePath+'\smiles.ini');
  try
    ini.ReadSectionValues('Smiles', smList);
  finally
  	ini.Free;
  end;
end;

procedure FindFiles(StartFolder, Mask: string; sl: TStringList);
var
  SearchRec: TSearchRec;
  FindResult: Integer;
begin
  StartFolder := IncludeTrailingPathDelimiter(StartFolder);
  FindResult := FindFirst(StartFolder + '*.*', faAnyFile, SearchRec);
  try
    while FindResult = 0 do
      with SearchRec do
      begin
        if (Attr and faDirectory) <> 0 then
        begin
          if (Name <> '.') and (Name <> '..') then
          begin
            FindFiles(StartFolder + Name, Mask, sl);
          end;
        end
        else
        begin
          if MatchesMask(Name, Mask) then
          begin
            sl.Add(StartFolder + Name);
          end;
        end;
        FindResult := FindNext(SearchRec);
      end;
  finally
    FindClose(SearchRec);
  end;
end;

procedure TfrmSmiles.FormCreate(Sender: TObject);
var
	i, k, n : integer;
 	tmpName : String;
  sl: TStringList;
begin
  smPath := IncludeTrailingPathDelimiter(Core.glHomePath+MainConf['SmilesPath']);
  tmpName := '';

  // Folders list (переписать!!!)
  sl:=TStringList.Create();
  FindFiles(smPath, '*.gif', sl);
	for i := 0 to sl.Count-1 do
	begin
   	k := TailPos(sl[i], '\', Length(smPath));
    n := TailPos(sl[i], '\', k+1);
    if tmpName <> copy(sl[i], k+1, n-k-1) then
   	begin
     	tmpName := copy(sl[i], k+1, n-k-1);
	 		fldrView.Items.Add(nil, tmpName);
    end;
  end;
  sl.Free();
  cbCloseAfterSelect.Checked:=MainConf.GetBool('SmilesCloseAfterSelect');
end;

function ExtractFileNameEx(FileName: string; ShowExtension: Boolean): string;
var
  s: string;
begin
  s:=ExtractFileName(FileName);
  if not ShowExtension then s:=ChangeFileExt(s, '');
  Result:=s;
end;

function ExtractFileNameEx2(FileName: string; ShowExtension: Boolean): string;
//Функция возвращает имя файла, без или с его расширением.
var
  I: Integer;
  S, S1: string;
begin
  //Определяем длину полного имени файла
  I := Length(FileName);
  if I <> 0 then
  begin
    //С конца имени параметра FileName ищем символ "\"
    while (FileName[i] <> '\') and (i > 0) do
      i := i - 1;
    // Копируем в переменную S параметр FileName начиная после последнего
    // "\", таким образом переменная S содержит имя файла с расширением, но без
    // полного пути доступа к нему
    S := Copy(FileName, i + 1, Length(FileName) - i);
    i := Length(S);
    //Если полученная S = '' то фукция возвращает ''
    if i = 0 then
    begin
      Result := '';
      Exit;
    end;
    //Иначе, получаем имя файла без расширения
    while (S[i] <> '.') and (i > 0) do
      i := i - 1;
    //... и сохраням это имя файла в переменную s1
    S1 := Copy(S, 1, i - 1);
    //если s1='' то , возвращаем s1=s
    if s1 = '' then
      s1 := s;
    //Если было передано указание функции возвращать имя файла с его
    // расширением, то Result = s,
    //если без расширения, то Result = s1
    if ShowExtension = TRUE then
      Result := s
    else
      Result := s1;
  end
    //Иначе функция возвращает ''
  else
    Result := '';
end;


procedure TfrmSmiles.fldrViewChange(Sender: TObject; Node: TTreeNode);
var
	i,n: 		integer;
  gif: 	TGifImage;
  sl: TStringList;
  //gif: TPicture;
begin
  if CurNode = Node then Exit;
  CurNode:=Node;
  sl:=TStringList.Create();
	FindFiles(smPath+Node.Text+'\', '*.gif', sl);
  smlView.Clear;
  smlView.Format;
  n:=sl.Count;
  if n>MAX_SMILES_ON_PAGE then n:=MAX_SMILES_ON_PAGE;
	for i := 0 to n-1 do
  begin
   	gif := TGIFImage.Create();
		gif.LoadFromFile(sl[i]);
  	smlView.AddHotPictureTag(ExtractFileNameEx(sl[i], False), gif, -1, rvvaMiddle, i);
   	{gif := TPicture.Create;
		gif.LoadFromFile(ResArray[i]);
  	smlView.AddHotPictureTag(ExtractFileNameEx(ResArray[i], False), gif.Graphic, -1, rvvaMiddle, i);}
    smlView.AddNL('  ', 0, -1);
  end;
  smlView.Format;
  sl.Free();
end;

procedure TfrmSmiles.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  smlView.Clear;
  //smlView.Format;
  FreeAndNil(smList);
  Self.Release();
  frmSmiles:=nil;
end;

procedure TfrmSmiles.FormShow(Sender: TObject);
begin
  if fldrView.Items.Count>0 then
  begin
    fldrView.Items[0].Selected := True;
    fldrViewChange(self, fldrView.Selected);
  end;
end;


procedure TfrmSmiles.smlViewJump(Sender: TObject; id: Integer);
var
	ItemNo, n: Integer;
  RVData: TCustomRVFormattedData;
  SmileName, SmileText: string;
begin
  if not Assigned(PagesManager) then Exit;
  //if not (Core.PagesManager.GetActivePage.Frame is TChatFrame) then Exit;
  smlView.GetJumpPointLocation(id, RVData, ItemNo);
  SmileName := smlView.GetItemTextW(ItemNo);
	//if Form1.PageControl1.ActivePage.Caption = csDebugTabName then exit;

  // ищем соответствующий смайл
  if not Assigned(smList) then LoadSmilesIni();
  n:=smList.IndexOfName(SmileName);
  if n < 0 then
  begin
    SmileText:=':'+SmileName+':';
  end
  else
  begin
    SmileText:=smList.ValueFromIndex[n];
  end;
  (Core.PagesManager.GetActivePage).InsertText(SmileText);
  if MainConf.GetBool('SmilesCloseAfterSelect') then frmSmiles.Close();
end;

procedure TfrmSmiles.smlViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    13 :    // Enter
    begin
      frmSmiles.Close;
    end;
  end;

end;

procedure TfrmSmiles.cbCloseAfterSelectClick(Sender: TObject);
begin
  MainConf.SetBool('SmilesCloseAfterSelect', cbCloseAfterSelect.Checked);
end;

end.
