{
   Configs unit - Sergey Bodrov 2008

   TConfItem - single config item, that store some data in string form.
     ValueType - type of stored value:
       S - string
       B - boolean (0, 1)
       I - integer
       T - text (multilines string)
     ID - unique for each item identifier.

   TConfItems - list of config items.

   TConfNode - single config tree node. Can have child nodes and parent node.
   Contain list of config items;

   TConf - Config object, have tree of config nodes (from root node)
   and list of all config items from all child nodes.

}
unit Configs;

interface

uses Contnrs, IniFiles, Classes, SysUtils, Controls;

type
  TConfItem = class(TObject)
  private
    //function GetLine(Index: integer): string;
    //procedure SetLine(Index: integer; Value: string);
  public
    Name: string;
    ID: integer;
    FullName: string;
    ValueType: AnsiChar;
    ValueString: string;
    StringList: TStringList;
    Changed: boolean;
    //property Lines[Index: integer]: string read GetLine write SetLine;
    destructor Destroy(); override;
  end;

  TConfItems = class(TObjectList)
  private
    FIniFileName: string;
    FSectionName: string;
    //FChanged: boolean;
    //FLastID: integer;
    function GetItem(Index: integer): TConfItem;
    function GetValue(Name: string): string;
    procedure SetItem(Index: integer; Value: TConfItem);
    procedure SetValue(Name: string; Value: string);
  public
    constructor Create(SectionName: string);
    property Items[Index: integer]: TConfItem read GetItem write SetItem;
    property Values[Name: string]: string read GetValue write SetValue; default;
    function AddItem(Item: TConfItem): integer;
    function Add(Name, FullName, Value: string; ValueType: AnsiChar = 'S'): integer;
    function GetItemByID(ID: integer): TConfItem;
    function GetItemByName(Name: string): TConfItem;
    procedure SaveToIni(ini: TMemIniFile);
    procedure LoadFromIni(ini: TMemIniFile);
  end;

  TConfNode = class(TObject)
  // Single config tree node. Can have child nodes and parent node.
  // Contain list of config items;
  private
    FChildCount: integer;
    FOnApplySettings: TNotifyEvent;
    FOnRefreshSettings: TNotifyEvent;
    function FGetChildCount(): integer;
  public
    // Internal name of node. Must contain only letters and digits. Used as
    // name for INI section in INI file
    Name: string;
    // Visible name of node
    FullName: string;
    // Owner of config node
    Owner: TObject;
    // Config items list
    ConfItems: TConfItems;
    ChildNodes: array of TConfNode;
    ParentNode: TConfNode;
    // Some visual control, used as visual representation of node
    Panel: TControl;
    constructor Create(ParentNode: TConfNode);
    // Add child node
    procedure AddChild(ChildNode: TConfNode);
    // Remove child node
    procedure RemoveChild(ChildNode: TConfNode);
    // Returns child node by it's name
    function GetChildByName(sName: string): TConfNode;
    // Create OnApplySettings event
    procedure ApplySettings();
    // Create OnRefreshSettings event
    procedure RefreshSettings();
    // number of child nodes
    property ChildCount: integer read FGetChildCount;
    property OnApplySettings: TNotifyEvent read FOnApplySettings write FOnApplySettings;
    property OnRefreshSettings: TNotifyEvent read FOnRefreshSettings write FOnRefreshSettings;
  end;

  TConf = class(TObject)
  // Config object, have tree of config nodes (from root node)
  // and list of all config items from all child nodes.
  private
    //FChanged: boolean;
    FOnApplySettings: TNotifyEvent;
    function GetValue(Name: string): string;
    procedure SetValue(Name: string; Value: string);
  public
    // Name for INI file
    FileName: string;
    // List of all config items from all subnodes. This list not saved and loaded
    // on Save() and Load() methods. Do RefreshItemsList() for fill list from
    // subnodes
    AllConfItems: TConfItems;
    // Tree root node.
    RootNode: TConfNode;
    // Values from AllConfItems
    property Values[Name: string]: string read GetValue write SetValue; default;
    // Returns TStringList form of value
    function GetStrings(Name: string): TStringList;
    // Return boolean form of value
    function GetBool(Name: string): boolean;
    procedure SetBool(Name: string; B: boolean);
    function GetInteger(Name: string): integer;
    procedure SetInteger(Name: string; I: integer);
    // Add all config items from all subnodes to AllConfItems items list,
    // do RefreshSettings() for all subnodes
    procedure RefreshItemsList();
    // Do ApplySettings() for all subnodes
    procedure ApplySettings();
    // Save items lists from all subnodes to INI file
    procedure Save();
    // Load items lists from all subnodes from INI file
    procedure Load();
    property OnApplySettings: TNotifyEvent read FOnApplySettings write FOnApplySettings;
  end;

var
  LastID: integer;

implementation

//=============================
// TConf
procedure TConf.RefreshItemsList();

procedure ReadListFromNode(CurNode: TConfNode; AllConfItems: TConfItems);
var
  i: integer;
begin
  CurNode.RefreshSettings();
  if Assigned(CurNode.ConfItems) then
  begin
    for i:=0 to CurNode.ConfItems.Count-1 do
    begin
      AllConfItems.AddItem(CurNode.ConfItems.Items[i]);
    end;
  end;

  for i:=0 to CurNode.ChildCount-1 do
  begin
    ReadListFromNode(CurNode.ChildNodes[i], AllConfItems);
  end;
end;

begin
  // refresh full items list from all child nodes
  if not Assigned(self.AllConfItems) then
    self.AllConfItems:=TConfItems.Create('');

  self.AllConfItems.OwnsObjects:=false;
  self.AllConfItems.Clear();
  ReadListFromNode(self.RootNode, self.AllConfItems);
end;

procedure TConf.Save();
var
  n: integer;
  ini: TMemIniFile;
  FChanged: boolean;

procedure SaveNode(CurNode: TConfNode);
var
  i: integer;
begin
  if Assigned(CurNode.ConfItems) then
  begin
    CurNode.ConfItems.SaveToIni(ini);
  end;

  for i:=0 to CurNode.ChildCount-1 do SaveNode(CurNode.ChildNodes[i]);
end;

begin
  FChanged:=false;
  for n:=0 to self.AllConfItems.Count-1 do
  begin
    if self.AllConfItems.Items[n].Changed then
    begin
      FChanged:=true;
      Break;
    end;
  end;
  if FChanged then
  begin
    ini:=TMemIniFile.Create(FileName);
    SaveNode(self.RootNode);
    ini.UpdateFile();
    ini.Free();
  end;
end;

procedure TConf.Load();
var
  ini: TMemIniFile;

procedure LoadNode(CurNode: TConfNode);
var
  i: integer;
begin
  if Assigned(CurNode.ConfItems) then
  begin
    CurNode.ConfItems.LoadFromIni(ini);
  end;

  for i:=0 to CurNode.ChildCount-1 do LoadNode(CurNode.ChildNodes[i]);
end;

begin
  ini:=TMemIniFile.Create(FileName);
  LoadNode(self.RootNode);
  //ini.UpdateFile();
  ini.Free();
end;

function TConf.GetValue(Name: string): string;
begin
  if Assigned(self.AllConfItems) then
    result:=self.AllConfItems.Values[Name]
  else
    result:='';
end;

procedure TConf.SetValue(Name: string; Value: string);
begin
  if Assigned(self.AllConfItems) then
  begin
    self.AllConfItems.Values[Name]:=Value;
  end;
end;

function TConf.GetStrings(Name: string): TStringList;
var
  Item: TConfItem;
begin
  result:=nil;
  Item:=self.AllConfItems.GetItemByName(Name);
  if not Assigned(Item) then Exit;
  if not Assigned(Item.StringList) then Item.StringList:=TStringList.Create();
  Item.StringList.Text:=Item.ValueString;
  result:=Item.StringList;
end;

function TConf.GetBool(Name: string): boolean;
begin
  result:=false;
  if Assigned(self.AllConfItems) then
    result:=(self.AllConfItems.Values[Name]='1');
end;

procedure TConf.SetBool(Name: string; B: boolean);
var
  C: Char;
begin
  if not Assigned(self.AllConfItems) then Exit;
  C:='0';
  if B then C:='1';
  self.AllConfItems.Values[Name]:=C;
end;

function TConf.GetInteger(Name: string): integer;
begin
  result:=0;
  if Assigned(self.AllConfItems) then
    result:=StrToIntDef(self.AllConfItems.Values[Name], 0);
end;

procedure TConf.SetInteger(Name: string; I: integer);
begin
  if not Assigned(self.AllConfItems) then Exit;
  self.AllConfItems.Values[Name]:=IntToStr(I);
end;

procedure TConf.ApplySettings();

procedure ApplySettingsNode(CurNode: TConfNode);
var
  i: integer;
begin
  CurNode.ApplySettings();
  for i:=0 to CurNode.ChildCount-1 do ApplySettingsNode(CurNode.ChildNodes[i]);
end;

begin
  ApplySettingsNode(self.RootNode);
  if Assigned(FOnApplySettings) then FOnApplySettings(self);
end;


//=============================
// TConfItem
destructor TConfItem.Destroy();
begin
  if Assigned(self.StringList) then FreeAndNil(self.StringList);
end;

//=============================
// TConfItems
constructor TConfItems.Create(SectionName: string);
begin
  inherited Create(true);
  self.FSectionName:=SectionName;
end;

function TConfItems.GetItem(Index: integer): TConfItem;
begin
  result:=TConfItem(inherited Items[Index]);
end;

procedure TConfItems.SetItem(Index: integer; Value: TConfItem);
begin
  inherited Items[Index]:=Value;
end;

function TConfItems.GetItemByID(ID: integer): TConfItem;
var
  i: integer;
begin
  result:=nil;
  for i:=0 to self.Count-1 do
  begin
    if Items[i].ID=ID then
    begin
      result:=Items[i];
      Exit;
    end;
  end;
end;

function TConfItems.GetItemByName(Name: string): TConfItem;
var
  i: integer;
begin
  result:=nil;
  for i:=0 to self.Count-1 do
  begin
    if Items[i].Name=Name then
    begin
      result:=Items[i];
      Exit;
    end;
  end;
end;

function TConfItems.GetValue(Name: string): string;
var
  i: integer;
begin
  result:='';
  for i:=0 to self.Count-1 do
  begin
    if Items[i].Name=Name then
    begin
      result:=Items[i].ValueString;
      Exit;
    end;
  end;
end;

procedure TConfItems.SetValue(Name: string; Value: string);
var
  i: integer;
begin
  for i:=0 to self.Count-1 do
  begin
    if Items[i].Name=Name then
    begin
      if Items[i].ValueString <> Value then
      begin
        Items[i].ValueString:=Value;
        Items[i].Changed:=true;
      end;
      Exit;
    end;
  end;
  //  if Name not found
  Add(Name, Name, Value);
end;

function TConfItems.AddItem(Item: TConfItem): integer;
begin
  if Item.ID < 1 then
  begin
    Inc(LastID);
    Item.ID:=LastID;
    Item.Changed:=true;
  end;
  inherited Add(Item);
  result:=Item.ID;
end;

function TConfItems.Add(Name, FullName, Value: string; ValueType: AnsiChar = 'S'): integer;
var
  NewItem: TConfItem;
begin
  NewItem:=TConfItem.Create();
  NewItem.Changed:=true;
  NewItem.Name:=Name;
  NewItem.FullName:=FullName;
  NewItem.ValueType:=ValueType;
  NewItem.ValueString:=Value;
  result:=AddItem(NewItem);
end;

procedure TConfItems.SaveToIni(ini: TMemIniFile);
var
  i,n: integer;
  sl: TStringList;
  FChanged: boolean;
begin
  FChanged:=false;
  for i:=0 to Count-1 do
  begin
    if Items[i].Changed then
    begin
      FChanged:=true;
      Break;
    end;
  end;
  if (not FChanged) or (Count=0) then Exit;
  for i:=0 to Count-1 do
  begin
    if Items[i].ValueType = 'T' then
    begin
      // strings list
      sl:=TStringList.Create();
      sl.Text:=Items[i].ValueString;
      for n:=0 to sl.Count-1 do
      begin
        ini.WriteString(FSectionName, Items[i].Name+IntToStr(n), sl.Strings[n]);
      end;
      // Delete remaining keys
      n:=sl.Count;
      while ini.ValueExists(FSectionName, Items[i].Name+IntToStr(n)) do
      begin
        ini.DeleteKey(FSectionName, Items[i].Name+IntToStr(n));
        Inc(n);
      end;
      FreeAndNil(sl);
    end
    else
    begin
      ini.WriteString(FSectionName, Items[i].Name, Items[i].ValueString);
    end;
    Items[i].Changed:=true;
  end;
end;

procedure TConfItems.LoadFromIni(ini: TMemIniFile);
var
  i,n: integer;
  sl: TStringList;
begin
  if Count=0 then Exit;
  for i:=0 to Count-1 do
  begin
    if Items[i].ValueType = 'T' then
    begin
      sl:=TStringList.Create();
      n:=0;
      while ini.ValueExists(FSectionName, Items[i].Name+IntToStr(n)) do
      begin
        sl.Add(ini.ReadString(FSectionName, Items[i].Name+IntToStr(n), ''));
        Inc(n);
      end;
      if Trim(sl.Text)<>'' then Items[i].ValueString:=sl.Text;
      FreeAndNil(sl);
    end
    else
    begin
      Items[i].ValueString:=ini.ReadString(FSectionName, Items[i].Name, Items[i].ValueString);
    end;
    Items[i].Changed:=false;
  end;
end;


//=============================
// TConfNode
constructor TConfNode.Create(ParentNode: TConfNode);
begin
  self.ParentNode:=ParentNode;
  self.FChildCount:=0;
  SetLength(self.ChildNodes, self.FChildCount);
  if Assigned(ParentNode) then ParentNode.AddChild(self);
end;

function TConfNode.FGetChildCount(): integer;
begin
  result:=self.FChildCount;
end;

procedure TConfNode.AddChild(ChildNode: TConfNode);
begin
  Inc(self.FChildCount);
  SetLength(self.ChildNodes, self.FChildCount);
  self.ChildNodes[self.FChildCount-1]:=ChildNode;
end;

procedure TConfNode.RemoveChild(ChildNode: TConfNode);
var
  i: integer;
  Found: boolean;
begin
  Found:=false;
  for i:=0 to self.FChildCount-1 do
  begin
    if Found then self.ChildNodes[i-1]:=self.ChildNodes[i];
    if self.ChildNodes[i]=ChildNode then
    begin
      Found:=true;
      Continue;
    end;
  end;
  Dec(self.FChildCount);
  SetLength(self.ChildNodes, self.FChildCount);
end;

function TConfNode.GetChildByName(sName: string): TConfNode;
var
  i: integer;
begin
  result:=nil;
  for i:=0 to self.FChildCount-1 do
  begin
    if self.ChildNodes[i].Name=sName then
    begin
      result:=self.ChildNodes[i];
      Exit;
    end;
    if self.ChildNodes[i].ChildCount>0 then result:=self.ChildNodes[i].GetChildByName(sName);
    if result <> nil then Exit;
  end;
end;

procedure TConfNode.ApplySettings();
begin
  if Assigned(FOnApplySettings) then FOnApplySettings(self);
end;

procedure TConfNode.RefreshSettings();
begin
  if Assigned(FOnRefreshSettings) then FOnRefreshSettings(self);
end;


end.
