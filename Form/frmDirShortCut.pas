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
    procedure btnClearClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnOpenDirClick(Sender: TObject);
    procedure lvShortCutDblClick(Sender: TObject);
  private
    procedure search(dir: string);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DirShortCutForm: TDirShortCutForm;

implementation
uses
  frmShortCut,untShortCutMan;

{$R *.dfm}

procedure TDirShortCutForm.btnClearClick(Sender: TObject);
begin
  lvShortCut.Items.Clear;
end;

procedure TDirShortCutForm.btnDeleteClick(Sender: TObject);
begin
  lvShortCut.Items.Delete(lvShortCut.ItemIndex);
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
    search(strDir)
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

procedure TDirShortCutForm.lvShortCutDblClick(Sender: TObject);
begin
  btnEdit.Click;
end;

procedure TDirShortCutForm.search(dir: string);
var
  targetpath: string; {目标路径名}
  sr: TsearchRec;
  strDir, strShortDir, strFileName, strShortFileName: string;
begin

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

