unit frmDirShortCut;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, FileCtrl, untALTRunOption;

type
  TDirShortCutForm = class(TForm)
    lvShortCut: TListView;
    pnlRight: TPanel;
    btnOpenDir: TBitBtn;
    btnEdit: TBitBtn;
    btnDelete: TBitBtn;
    btnCancel: TBitBtn;
    btnOK: TBitBtn;
    btnClear: TBitBtn;
    chkRecurve: TCheckBox;
    edtDepth: TEdit;
    ud1: TUpDown;
    procedure FormCreate(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnOpenDirClick(Sender: TObject);
    procedure chkRecurveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lvShortCutDblClick(Sender: TObject);
    procedure lvShortCutKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lvShortCutMouseDown(Sender: TObject; Button: TMouseButton; Shift:
        TShiftState; X, Y: Integer);
  private
    FCurrDepth: Integer;
    procedure search(dir: string);
    { Private declarations }
  public
    function GetDirDepth(ADirName: string): Integer;
    { Public declarations }
  end;

var
  DirShortCutForm: TDirShortCutForm;

implementation
uses
  frmShortCut, untShortCutMan;

{$R *.dfm}

procedure TDirShortCutForm.FormCreate(Sender: TObject);
begin
  Self.Caption := resDirShortCutFormCaption;

  btnOpenDir.Caption := resBtnOpenDir;
  btnEdit.Caption := resBtnEdit;
  btnDelete.Caption := resBtnDelete;
  btnCancel.Caption := resBtnCancel;
  btnClear.Caption := resBtnClear;

//  btnAdd.Hint := resBtnAddHint;
  btnEdit.Hint := resBtnEditHint;
  btnDelete.Hint := resBtnDeleteHint;
  btnCancel.Hint := resBtnCancelHint;

  chkRecurve.Caption := resChkRecurve;
  chkRecurve.Hint := resChkRecurveHint;

  chkRecurve.Checked:=Recurve;
  ud1.Position:=RecurveDepth;
  
  lvShortCut.Columns.Items[0].Caption := resShortCut;
  lvShortCut.Columns.Items[1].Caption := resName;
  lvShortCut.Columns.Items[2].Caption := resParamType;
  lvShortCut.Columns.Items[3].Caption := resCommandLine;
end;

procedure TDirShortCutForm.btnClearClick(Sender: TObject);
begin
  lvShortCut.Items.Clear;
end;

procedure TDirShortCutForm.btnDeleteClick(Sender: TObject);
var
  i:integer;
begin
  lvShortCut.DeleteSelected;
end;

procedure TDirShortCutForm.btnEditClick(Sender: TObject);
var
  ShortCutForm: TShortCutForm;
  itm: TListItem;
  ParamType: TParamType;
  ShortCutItem: TShortCutItem;
begin
  if lvShortCut.ItemIndex < 0 then Exit;
  if lvShortCut.Selected.ImageIndex <> Ord(siItem) then Exit;

  try
    ShortCutForm := TShortCutForm.Create(Self);
    with ShortCutForm do
    begin
      lbledtShortCut.Text := lvShortCut.Selected.Caption;
      lbledtName.Text := lvShortCut.Selected.SubItems[0];
      lbledtCommandLine.Text := lvShortCut.Selected.SubItems[2];
      ShortCutMan.StringToParamType(lvShortCut.Selected.SubItems[1], ParamType);
      rgParam.ItemIndex := Ord(ParamType);

      ShowModal;

      if ModalResult = mrCancel then Exit;

      try
        itm := TListItem.Create(lvShortCut.Items);

        if (Trim(lbledtShortCut.Text) <> '') and (Trim(lbledtCommandLine.Text) <> '') then
        begin
          itm.Caption := lbledtShortCut.Text;
          itm.SubItems.Add(lbledtName.Text);
          itm.SubItems.Add(ShortCutMan.ParamTypeToString(TParamType(rgParam.ItemIndex)));
          itm.SubItems.Add(lbledtCommandLine.Text);
          itm.ImageIndex := Ord(siItem);
        end
        else
        begin
          itm.Caption := '';
          itm.SubItems.Add('');
          itm.SubItems.Add('');
          itm.SubItems.Add('');
          itm.ImageIndex := Ord(siInfo);
        end;

        //若有重复，则报错
//        if ExistListItem(itm) then
//        begin
//          Application.MessageBox('This ShortCut has already existed!', PChar(resInfo),
//            MB_OK + MB_ICONINFORMATION + MB_TOPMOST);
//
//          Exit;
//        end;

        lvShortCut.Selected.Caption := itm.Caption;
        lvShortCut.Selected.SubItems[0] := itm.SubItems[0];
        lvShortCut.Selected.SubItems[1] := itm.SubItems[1];
        lvShortCut.Selected.SubItems[2] := itm.SubItems[2];
        lvShortCut.Selected.ImageIndex := itm.ImageIndex;

        //使其可见
        lvShortCut.Selected.MakeVisible(True);
      finally
        itm.Free;
      end;
    end;
  finally
    ShortCutForm.Free;
  end;

end;

procedure TDirShortCutForm.btnOpenDirClick(Sender: TObject);
var
  strDir, strShortDir, strFileName, strShortFileName: string;
  sr: TSearchRec;
begin
  SelectDirectory(PChar(resSelectDir), '', strDir,
    [sdNewFolder, sdShowShares, sdNewUI, sdValidateDir]);

//  lvShortCut.Items.Clear;
  if chkRecurve.Checked then
  begin
    FCurrDepth := GetDirDepth(strDir);
    search(strDir);
  end
  else
    if FindFirst(strDir + '\*.exe', faAnyFile + faArchive, sr) = 0 then
    begin
      repeat
        strFileName := ExtractFileName(sr.Name);
        strShortFileName := Copy(strFileName, 1, Length(strFileName) - Length(ExtractFileExt(strFileName)));

        with lvShortCut.Items.Add do
        begin
          Caption := strShortFileName;
          SubItems.Add(strShortFileName);
          SubItems.Add('');
          SubItems.Add(strDir + '\' + sr.Name);
          ImageIndex := Ord(0);
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;

end;

procedure TDirShortCutForm.chkRecurveClick(Sender: TObject);
begin
  edtDepth.Enabled := chkRecurve.Checked;
end;

procedure TDirShortCutForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Recurve:=chkRecurve.Checked;
  RecurveDepth:=ud1.Position;
end;

function TDirShortCutForm.GetDirDepth(ADirName: string): Integer;
begin
  Result := 0;
  with TStringList.Create do
  try
    Delimiter := '\';
    DelimitedText := ADirName;
    Result := Count;
  finally
    free;
  end;
end;

procedure TDirShortCutForm.lvShortCutDblClick(Sender: TObject);
begin
  btnEdit.Click;
end;

procedure TDirShortCutForm.lvShortCutKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_DELETE: btnDeleteClick(nil);
    VK_RETURN: btnEditClick(nil);
  end;
end;

procedure TDirShortCutForm.lvShortCutMouseDown(Sender: TObject; Button:
    TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
//  if Button=mbRight then
//  begin
//    lvShortCut.GetItemAt(x,y).Selected:=not lvShortCut.GetItemAt(x,y).Selected;
//  end;  
end;

procedure TDirShortCutForm.search(dir: string);
var
  targetpath: string; {目标路径名}
  sr: TsearchRec;
  strFileName, strShortFileName: string;
begin
//  Inc(FCurrDepth);

  if GetDirDepth(dir) - FCurrDepth >= StrToInt(edtDepth.Text) then
    exit;

     {第一阶段:找出初始dir目录下的所有文件,其中dir变量值由edit1的Text属性确定}
  targetpath := extractfilepath(dir); {分解出目标路径名}
  if findfirst(dir, faanyfile, sr) = 0 then
    repeat
      if ExtractFileExt(sr.Name) = '.exe' then

//      if ((sr.name <> '.') and (sr.name <> '..') {排除父目录和本目录两个假文件}
//        and ((filegetattr(targetpath + sr.name) and fadirectory) <> fadirectory)) {只取文件}
//        then
      begin
        strFileName := ExtractFileName(sr.Name);
        strShortFileName := Copy(strFileName, 1, Length(strFileName) - Length(ExtractFileExt(strFileName)));

        with lvShortCut.Items.Add do
        begin
          Caption := strShortFileName;
          SubItems.Add(strShortFileName);
          SubItems.Add('');
          SubItems.Add(ExtractFilePath(dir) + sr.Name);
          ImageIndex := Ord(0);
        end;
      end
    until findnext(sr) <> 0;

  if findfirst(dir, faanyfile, sr) = 0 then
    repeat
      if ((sr.name <> '.') and (sr.name <> '..')) {排除父目录和本目录两个假文件}
        and ((filegetattr(targetpath + sr.name) and fadirectory) = fadirectory) {排除文件}
        then
      begin
        search(targetpath + sr.name + '\*.*'); {递归调用}
//        form1.memo1.Lines.Add(targetpath + sr.name);
//
//        countd := countd + 1;
      end
    until findnext(sr) <> 0;
end;

end.

