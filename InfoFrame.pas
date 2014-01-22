{ При использовании данных исходников или их фрагментов, ссылка на источник
  обязательна.
  http://irchat.ru

  TFrameInfo - страница справочной информации.

}
unit InfoFrame;

interface

uses
  SysUtils, Controls, Forms, RVScroll, RichView, Core,
  ComCtrls, Classes, ExtCtrls, Contnrs;

type
  TFrameInfo = class(TFrame)
    panCenter: TPanel;
    tvContents: TTreeView;
    Splitter1: TSplitter;
    rvMesText: TRichView;
    procedure tvContentsClick(Sender: TObject);
    procedure tvContentsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    ol: TObjectList;
    procedure AddItem(FileName, NodeName: string; ImgIndex: integer; ParentNode: TTreeNode = nil);
    function FindFiles(StartFolder, Mask: string; ParentNode: TTreeNode): boolean;
    procedure ReadInfoFile(FileName: string);
    procedure ShowAbout();
  public
    { Public declarations }
    Page: TChatPage;
    constructor Create(APage: TChatPage); reintroduce;
    destructor Destroy(); override;
    procedure Refresh();
    procedure ClearMesText();
  end;

implementation
uses Main;

type
  TDataTreeNode = class(TObject)
  public
    FileName: string;
  end;

{$R *.dfm}

constructor TFrameInfo.Create(APage: TChatPage);
begin
  inherited Create(APage.TabSheet);
  //self.Parent:=TWinControl(APage.TabSheet);
  self.Page:=APage;
  //APage.OnActivate:=OnActivateHandler;
  rvMesText.Style:=Form1.MessStyle;
  self.tvContents.Images:=Form1.ImageList16;
  ol:=TObjectList.Create(true);
  Refresh();
end;

destructor TFrameInfo.Destroy();
begin
  ol.Destroy();
  inherited Destroy();
end;

procedure TFrameInfo.AddItem(FileName, NodeName: string; ImgIndex: integer; ParentNode: TTreeNode = nil);
var
  tmpSubnode: TTreeNode;
  Data: TDataTreeNode;
begin
  if not FileExists(FileName) then Exit;
  Data:=TDataTreeNode.Create();
  ol.Add(Data);
  Data.FileName:=FileName;

  tmpSubnode:=TTreeNode.Create(tvContents.Items);
  tmpSubnode.ImageIndex:=ImgIndex;
  tmpSubnode.SelectedIndex:=ImgIndex;
  //tmpSubnode.FileName:=FileName;
  tmpSubnode.Data:=Data;
  tvContents.Items.AddNode(tmpSubnode, ParentNode, NodeName, Data, naAddChild);
  tmpSubnode.MakeVisible;
end;

function TFrameInfo.FindFiles(StartFolder, Mask: string; ParentNode: TTreeNode): boolean;
var
  SearchRec: TSearchRec;
  FindResult, i: Integer;
  tmpNode: TTreeNode;
begin
  result:=false;
  i:=0;
  StartFolder := IncludeTrailingPathDelimiter(StartFolder);
  FindResult := FindFirst(StartFolder+'*.*', faAnyFile, SearchRec);
  try
    while FindResult = 0 do
      //with SearchRec do
      begin
        if (SearchRec.Attr and faDirectory) <> 0 then
        begin
          if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
          begin
            tmpNode:=ParentNode.Owner.AddChild(ParentNode, SearchRec.Name);
            tmpNode.ImageIndex:=9;
            tmpNode.SelectedIndex:=9;
            if not FindFiles(StartFolder + SearchRec.Name, Mask, tmpNode) then tmpNode.Free()
            else Inc(i);
          end;
        end
        else
        begin
          if (ExtractFileExt(SearchRec.Name)=Mask) then
          begin
            Inc(i);
            //FilesList.Add(StartFolder + Name);
            AddItem(StartFolder+SearchRec.Name, ChangeFileExt(SearchRec.Name, ''), 3, ParentNode);
          end;
        end;
        FindResult := FindNext(SearchRec);
      end;
  finally
    SysUtils.FindClose(SearchRec);
  end;
  result:=(i>0);
end;

procedure TFrameInfo.Refresh();
var
  i: integer;
  tmpNode: TTreeNode;
begin
  self.tvContents.Items.Clear;
  // добавляем верховный узел
  tmpNode:=TTreeNode.Create(tvContents.Items);
  //tmpNode:=tvClientsList.Items.Add(nil, 'RealChat');
  tmpNode.ImageIndex:=0;
  tmpNode.SelectedIndex:=0;
  //tmpNode.Data:=tmpNode;
  tvContents.Items.AddNode(tmpNode, nil, 'Help', nil, naAdd);

  self.FindFiles(glHomePath+'Docs\', '.txt', tmpNode);

  ShowAbout();
  {// RealChat.txt
  AddItem(glHomePath+'RealChat.txt', 'Readme', 1, tmpNode);

  // Changes.txt
  AddItem(glHomePath+'changes.txt', 'Changes', 1, tmpNode);

  // license.txt
  AddItem(glHomePath+'license.txt', 'License', 1, tmpNode);}

  //tvContents.FullCollapse();
end;

procedure TFrameInfo.ClearMesText();
begin
  rvMesText.Clear;
  rvMesText.Format;
end;

{procedure TFrameInfo.ReadInfoFile(FileName: string);
begin
  if (Length(FileName)=0) or (not FileExists(FileName)) then Exit;
  rvMesText.Clear();
  rvMesText.LoadText(FileName, 0, 0, true);
  rvMesText.Format();
end;}

procedure TFrameInfo.ReadInfoFile(FileName: string);
var
  sl: TStringList;
  i: integer;
begin
  if (Length(FileName)=0) or (not FileExists(FileName)) then Exit;
  sl:=TStringList.Create();
  sl.LoadFromFile(FileName);
  rvMesText.Clear();
  for i:=0 to sl.Count-1 do
  begin
    MainForm.ParseBBTextToRV(rvMesText, sl[i]);
  end;
  rvMesText.Format();

  //MainForm.ParseBBTextToRV(rvMesText, sl.Text);
  sl.Free();
  //rvMesText.Format();
end;

procedure TFrameInfo.tvContentsClick(Sender: TObject);
begin
  if not Assigned(tvContents.Selected) then Exit;
  if not Assigned(tvContents.Selected.Data) then
  begin
    ShowAbout();
    Exit;
  end;
  ReadInfoFile(TDataTreeNode(tvContents.Selected.Data).FileName);
end;

procedure TFrameInfo.tvContentsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key <> 13 then Exit; // VK_RETURN
  if not Assigned(tvContents.Selected) then Exit;
  if not Assigned(tvContents.Selected.Data) then
  begin
    ShowAbout();
    Exit;
  end;
  ReadInfoFile(TDataTreeNode(tvContents.Selected.Data).FileName);
end;

procedure TFrameInfo.ShowAbout();
var
  text, caption: string;
  //index, i : integer;
begin
  text:=''+#13
  +'удобный IRC клиент'+#13+#13
  +'авторы:'+#13
  +'Сергей Бодров (Hunter)'+#13
  +' - разработка, отладка'+#13+#13
  +'xa0c'+#13
  +' - разработка, дизайн'+#13+#13
  +'программа некоммерческая (бесплатная)'+#13
  +'использование в коммерческих целях'+#13
  +'недопустимо'+#13
  +#13
  +'http://irchat.ru'+#13
  ;
  caption:=''+sRealVersion;
  //Application.MessageBox(PChar(text), PChar(caption),  MB_OK or MB_ICONINFORMATION);

  ClearMesText();
  rvMesText.Add(caption, 1);
  rvMesText.AddTextBlockNL(text, 0, 0);
  rvMesText.Format();
end;


end.
