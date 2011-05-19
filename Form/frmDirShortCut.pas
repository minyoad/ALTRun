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
    procedure btnOpenDirClick(Sender: TObject);
  private
    procedure search(dir: string);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DirShortCutForm: TDirShortCutForm;

implementation

{$R *.dfm}

procedure TDirShortCutForm.btnClearClick(Sender: TObject);
begin
  lvShortCut.Items.Clear;
end;

procedure TDirShortCutForm.btnDeleteClick(Sender: TObject);
begin
  lvShortCut.Items.Delete(lvShortCut.ItemIndex);
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

procedure TDirShortCutForm.search(dir: string);
var
  targetpath: string; {Ŀ��·����}
  sr: TsearchRec;
  strDir, strShortDir, strFileName, strShortFileName: string;
begin

     {��һ�׶�:�ҳ���ʼdirĿ¼�µ������ļ�,����dir����ֵ��edit1��Text����ȷ��}
  targetpath := extractfilepath(dir); {�ֽ��Ŀ��·����}
  if findfirst(dir, faanyfile, sr) = 0 then
    repeat
      if ExtractFileExt(sr.Name) = '.exe' then

//      if ((sr.name <> '.') and (sr.name <> '..') {�ų���Ŀ¼�ͱ�Ŀ¼�������ļ�}
//        and ((filegetattr(targetpath + sr.name) and fadirectory) <> fadirectory)) {ֻȡ�ļ�}
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
      if ((sr.name <> '.') and (sr.name <> '..')) {�ų���Ŀ¼�ͱ�Ŀ¼�������ļ�}
        and ((filegetattr(targetpath + sr.name) and fadirectory) = fadirectory) {�ų��ļ�}
        then
      begin
        search(targetpath + sr.name + '\*.*'); {�ݹ����}
//        form1.memo1.Lines.Add(targetpath + sr.name);
//
//        countd := countd + 1;
      end
    until findnext(sr) <> 0;
end;

end.

