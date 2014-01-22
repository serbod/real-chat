{ ѕри использовании данных исходников или их фрагментов, ссылка на источник
  об€зательна.
  http://irchat.ru

  ‘орма настроек.

  —одержит предопределенную универсальную страницу отображени€ и
  редактировани€ списка настроек, котора€ используетс€, если панель
  страницы настроек не назначена.

  ¬ качестве основного конфига используетс€ глобальный conf.
}
unit OptionsForm;

interface

uses
  SysUtils, Classes, Controls, Forms,
  StdCtrls, ExtCtrls, ComCtrls, Configs, Buttons;

type
  TfrmOptions = class(TForm)
    tvConfTree: TTreeView;
    panOptionsPanel: TPanel;
    btOk: TButton;
    btnApply: TButton;
    btnCancel: TButton;
    panValuesList: TPanel;
    lvItemsList: TListView;
    panelModValue: TPanel;
    lbValueName: TLabel;
    cbValue: TCheckBox;
    edValueString: TEdit;
    btnSetValue: TButton;
    memoValue: TMemo;
    bbtnFold: TBitBtn;
    bbtnUnfold: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure lvItemsListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btnSetValueClick(Sender: TObject);
    procedure tvConfTreeChange(Sender: TObject; Node: TTreeNode);
    procedure FormDestroy(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bbtnFoldClick(Sender: TObject);
    procedure bbtnUnfoldClick(Sender: TObject);
  private
    { Private declarations }
    CurConfItem: TConfItem;
    CurConfItems: TConfItems;
    CurConfNode: TConfNode;
  public
    { Public declarations }
    procedure RefreshConfTree();
    procedure RefreshAllOptions();
    procedure RefreshItemsList(SaveSelected: boolean = false);
    procedure SaveOptions();
    procedure LoadOptions();
    procedure ChangeLanguage();
    procedure SelectItemByOwner(AOwner: TObject);
  end;

type
  TConfListItem = class(TListItem)
  public
    ConfItem: TConfItem;
  end;

  TConfTreeNode = class(TTreeNode)
  public
    ConfNode: TConfNode;
  end;

var
  frmOptions: TfrmOptions;
  VisualConf: TConf;

implementation
uses IRC_Options, MainOptions, Core, Plugins;
{$R *.dfm}

procedure TfrmOptions.RefreshConfTree();
var
  i: integer;
  NewTreeNode: TConfTreeNode;

procedure FillTreeNode(TreeNode: TConfTreeNode; ConfNode: TConfNode);
var
  i: integer;
  NewTreeNode: TConfTreeNode;
begin
  TreeNode.Text:=ConfNode.FullName;
  TreeNode.ConfNode:=ConfNode;

  if ConfNode.ChildCount = 0 then Exit;
  for i:=0 to ConfNode.ChildCount-1 do
  begin
    NewTreeNode:=TConfTreeNode.Create(TreeNode.Owner);
    TreeNode.Owner.AddNode(NewTreeNode, TreeNode, '', nil, naAddChild);
    FillTreeNode(NewTreeNode, ConfNode.ChildNodes[i]);
  end;
end;

begin
  tvConfTree.Items.BeginUpdate();
  tvConfTree.Items.Clear();
  NewTreeNode:=TConfTreeNode.Create(tvConfTree.Items);
  FillTreeNode(NewTreeNode, VisualConf.RootNode);
  tvConfTree.Items.EndUpdate();
  if tvConfTree.Items.Count <= 20 then tvConfTree.FullExpand();
end;

procedure TfrmOptions.tvConfTreeChange(Sender: TObject; Node: TTreeNode);
var
  stdListVisible: boolean;
begin
  if Assigned(CurConfNode) and Assigned(CurConfNode.Panel) then
  begin
    CurConfNode.Panel.Visible:=false;
  end;
  CurConfNode:=TConfTreeNode(Node).ConfNode;
  CurConfItems:=CurConfNode.ConfItems;
  stdListVisible:=true;
  if Assigned(CurConfNode.Panel) then
  begin
    CurConfNode.Panel.Parent:=panOptionsPanel;
    CurConfNode.Panel.Visible:=true;
    stdListVisible:=false;
  end;
  panValuesList.Visible:=stdListVisible;
  //lvItemsList.Visible:=stdListVisible;
  //panelModValue.Visible:=stdListVisible;

  RefreshItemsList();
end;

//================================
// Items list
//================================
procedure TfrmOptions.RefreshItemsList(SaveSelected: boolean = false);
var
  i: integer;
  NewItem: TConfListItem;
  SelIndex: integer;
begin
  SelIndex:=0;
  if SaveSelected then
  begin
    SelIndex:=lvItemsList.ItemIndex;
  end;
  lvItemsList.Clear();

  if Assigned(CurConfItems) then
  begin
    for i:=0 to CurConfItems.Count-1 do
    begin
      NewItem:=TConfListItem.Create(lvItemsList.Items);
      NewItem.ConfItem:=CurConfItems.Items[i];
      //NewItem.Caption:=IntToStr(NewItem.ConfItem.ID);
      NewItem.SubItems.Add(NewItem.ConfItem.Name);
      NewItem.SubItems.Add(NewItem.ConfItem.FullName);
      NewItem.SubItems.Add(NewItem.ConfItem.ValueString);
      lvItemsList.Items.AddItem(NewItem);
      NewItem.Caption:=IntToStr(NewItem.ConfItem.ID);
    end;
  end;

  if SaveSelected then
  begin
    lvItemsList.ItemIndex:=SelIndex;
    Exit;
  end;
  CurConfItem:=nil;
  edValueString.Text:='';
end;

procedure TfrmOptions.lvItemsListSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  edValueString.Visible := false;
  lbValueName.Visible := false;
  cbValue.Visible := false;
  memoValue.Visible := false;

  if not Assigned(Item) then
  begin
    CurConfItem:=nil;
    Exit;
  end;
  CurConfItem:=TConfListItem(Item).ConfItem;

  if CurConfItem.ValueType = 'B' then
  begin
    cbValue.Visible := true;
    cbValue.Caption := CurConfItem.FullName;
    if CurConfItem.ValueString = '1' then
      cbValue.Checked:=true
    else
      cbValue.Checked:=false;
  end

  else if CurConfItem.ValueType = 'T' then
  begin
    lbValueName.Visible := true;
    lbValueName.Caption := CurConfItem.FullName;
    memoValue.Visible := true;
    memoValue.Text:=CurConfItem.ValueString;
  end

  else
  begin
    lbValueName.Visible := true;
    lbValueName.Caption := CurConfItem.FullName;
    edValueString.Visible := true;
    edValueString.Text:=CurConfItem.ValueString;
  end;
end;

procedure TfrmOptions.btnSetValueClick(Sender: TObject);
begin
  if not Assigned(CurConfItem) then Exit;

  if CurCOnfItem.ValueType = 'S' then
  begin
    CurConfItem.ValueString:=edValueString.Text;
  end

  else if CurCOnfItem.ValueType = 'T' then
  begin
    CurConfItem.ValueString:=memoValue.Text;
  end

  else if CurCOnfItem.ValueType = 'B' then
  begin
    if cbValue.Checked then
      CurConfItem.ValueString:='1'
    else
      CurConfItem.ValueString:='0';
  end

  else
  begin
    CurConfItem.ValueString:=edValueString.Text;
  end;

  RefreshItemsList(true);
end;

procedure TfrmOptions.SaveOptions();
var
  i: integer;
  Conf: TConf;
begin
  // Apply main conf
  MainConf.ApplySettings();
  MainConf.Save();
  // Apply clients conf
  if not Assigned(ClientsManager) then Exit;
  for i:=0 to Core.ClientsManager.ClientsCount-1 do
  begin
    Conf:=Core.ClientsManager.GetClient(i).GetConf();
    if Assigned(Conf) then
    begin
      Conf.ApplySettings();
      Conf.Save();
    end;
  end;
  // Apply plugins conf
  if Assigned(PluginsManager) then
  begin
    for i:=0 to PluginsManager.Count-1 do
    begin
      Conf:=TPlugin(PluginsManager[i]).Conf;
      if Assigned(Conf) then
      begin
        Conf.ApplySettings();
        //Conf.Save();
      end;
    end;
    PluginsManager.BroadcastMsg('OPTIONS_CHANGED');
  end;
end;

procedure TfrmOptions.LoadOptions();
var
  i: integer;
  Conf: TConf;
begin
  MainConf.Load();
  MainConf.RefreshItemsList();
  if not Assigned(ClientsManager) then Exit;
  for i:=0 to Core.ClientsManager.ClientsCount-1 do
  begin
    Conf:=Core.ClientsManager.GetClient(i).GetConf();
    if Assigned(Conf) then
    begin
      Conf.Load();
      Conf.RefreshItemsList();
    end;
  end;
end;

procedure TfrmOptions.RefreshAllOptions();
var
  i: integer;
  Conf: TConf;
begin
  MainConf.RefreshItemsList();
  if not Assigned(ClientsManager) then Exit;
  for i:=0 to Core.ClientsManager.ClientsCount-1 do
  begin
    Conf:=Core.ClientsManager.GetClient(i).GetConf();
    if Assigned(Conf) then
    begin
      Conf.RefreshItemsList();
    end;
  end;
end;

procedure TfrmOptions.FormCreate(Sender: TObject);
begin
  VisualConf:=TConf.Create();
  //Conf.FileName:=ExtractFilePath(ParamStr(0))+'\test.ini';
  // Root node
  VisualConf.RootNode:=TConfNode.Create(nil);
  VisualConf.RootNode.Name:='Root';
  VisualConf.RootNode.FullName:='Root node';
end;

procedure TfrmOptions.FormDestroy(Sender: TObject);
begin
  FreeAndNil(VisualConf);
end;

procedure TfrmOptions.SelectItemByOwner(AOwner: TObject);
var
  i: Integer;
  TreeNode: TConfTreeNode;
begin
  for i:=0 to tvConfTree.Items.Count-1 do
  begin
    TreeNode:=(tvConfTree.Items[i] as TConfTreeNode);
    if TreeNode.ConfNode.Owner=AOwner then
    begin
      tvConfTree.Selected:=TreeNode;
      TreeNode.Expand(true);
      Exit;
    end;  
  end;
end;

procedure TfrmOptions.btnCancelClick(Sender: TObject);
begin
  Close();
end;

procedure TfrmOptions.btnApplyClick(Sender: TObject);
begin
  SaveOptions();
end;

procedure TfrmOptions.btOkClick(Sender: TObject);
begin
  SaveOptions();
  Close();
end;

procedure TfrmOptions.FormShow(Sender: TObject);
begin
  //LoadOptions();
  RefreshAllOptions();
  RefreshConfTree();
end;

procedure TfrmOptions.bbtnFoldClick(Sender: TObject);
begin
  tvConfTree.FullCollapse();
end;

procedure TfrmOptions.bbtnUnfoldClick(Sender: TObject);
begin
  tvConfTree.FullExpand();
end;

procedure TfrmOptions.ChangeLanguage();

function GetStr(Name: string; s: string): string;
begin
  result:=Core.LangIni.ReadString('MainOptions', Name, s);
end;

begin
  if not Assigned(Core.LangIni) then Exit;
  try
    btnApply.Caption:=GetStr('btnApply.Caption', btnApply.Caption);
    btnCancel.Caption:=GetStr('btnCancel.Caption', btnCancel.Caption);
    btOk.Caption:=GetStr('btOk.Caption', btOk.Caption);

    bbtnFold.Hint:=GetStr('bbtnFold.Hint', bbtnFold.Hint);
    bbtnUnfold.Hint:=GetStr('bbtnUnfold.Hint', bbtnUnfold.Hint);
    //.Caption:=GetStr('.Caption', .Caption);
    //:=GetStr('', );
  finally
  end;
end;


end.
