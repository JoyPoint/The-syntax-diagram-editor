unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TDrawMode = (Draw, NoDraw, DrawLine);
  TEditMode = (NoEdit, Move, TSide, BSide, RSide, LSide, Vert1, Vert2, Vert3, Vert4);
  TType = (Def,MetaVar,MetaConst, Line);
  //TFigureType = (rect, line);

  // ������ ����� ������
  TPointsInfo = record
    id,x,y: integer;
  end;
  PPointsList = ^TPointsList;
  TPointsList = record
    Info: TPointsInfo;
    Adr:PPointsList;
  end;
  // ������ ����� �����

  // ������ ������������� �������� ������
  TRectInfo = record
    case tp:TType of
    Def, MetaConst, MetaVar: (Txt: string[255];x1,x2,y1,y2: integer);
    Line: (PointHead: PPointsList);
  end;
  PRectList = ^RectList;
  RectList = record
    Info: TRectInfo;
    Adr: PRectList;
  end;
  // ������ ������������� �������� �����





  TEditorForm = class(TForm)
    canv: TImage;
    Label1: TLabel;
    Timer1: TTimer;
    Label2: TLabel;
    edtRectText: TEdit;
    btnDef: TButton;
    btnMV: TButton;
    btnMC: TButton;
    btnLine: TButton;
    pnlOptions: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure clearScreen;
    procedure canvMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure canvMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure canvMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure btnDefClick(Sender: TObject);
    procedure btnMVClick(Sender: TObject);
    procedure btnMCClick(Sender: TObject);
    procedure btnLineClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);  private
  public
    { Public declarations }
  end;

var
  EditorForm: TEditorForm;
  RectHead: PRectList;
  CurrType: TType;
  CurrFigure, ClickFigure: PRectList;
  tempX, tempY: integer;
  DM: TDrawMode;
  EM: TEditMode;
  currPointAdr: PPointsList;
  //FT: TFigureType;
const
  Tolerance = 5; // ���-�� ��������, �� ������� ����� ����� "������������"
  VertRad = 3; // ������ ������


implementation

{$R *.dfm}

procedure addNewPoint(var head: PPointsList; x,y:integer);
var
  tmp :PPointsList;
  id :integer;
begin
  tmp := head;
  while tmp^.adr <> nil do
    tmp := tmp^.Adr;
  id := tmp^.Info.id + 1;
  new(tmp^.adr);
  tmp := tmp^.adr;
  tmp^.Info.x := x;
  tmp^.Info.y := y;
  tmp^.Info.id := id;
  tmp^.Adr := nil;
end;

function getClickFigure(x,y:integer; head: PRectList):PRectList;
var
  tmp:PRectList;
begin
  tmp := head^.adr;
  while tmp <> nil do
  begin

    if (x > tmp^.Info.x1)
        and
        (x < tmp^.Info.x2)
        and
        (y > tmp^.Info.y1)
        and
        (y < tmp^.Info.y2)
        then
    begin
      result := tmp;
      exit;
    end;
    tmp := tmp^.Adr;
  end;
  Result := nil;
end;

// ��������� �����
function addLine(head: PRectList; x,y: integer):PRectList;
var
  tmp: PRectList;
  id: integer;
begin
  tmp := head;
  while tmp^.adr <> nil do
    tmp := tmp^.Adr;
  new(tmp^.adr);
  tmp := tmp^.Adr;
  tmp^.Adr := nil;
  tmp^.Info.tp := line;
  new(tmp^.Info.PointHead);
  tmp^.Info.PointHead^.Adr := nil;
  tmp^.Info.PointHead^.Info.id := 0;
  addNewPoint(tmp^.Info.PointHead, x,y);

  result := tmp;
end;


// ��������� ����� ������������� ������ � ���������� ������ �� ����!
function addRect(head: PRectList; x,y: integer; ftype: TType; Text:String = 'Kek'):PRectList;
var
  tmp: PRectList;
begin
  tmp := head;
  while tmp^.adr <> nil do
    tmp := tmp^.Adr;
  new(tmp^.adr);
  tmp := tmp^.Adr;
  tmp^.Adr := nil;
  with tmp^.Info do
  begin
    x1 := x;
    x2 := x;
    y1 := y;
    y2 := y;
    Txt := text;
    Tp := ftype;
  end;

  Result := tmp;
end;


// ������� ������ ������������� �����
procedure createRectList(var head: PRectList);
begin
  new(head);
  head.Adr := nil;
end;

procedure TEditorForm.btnDefClick(Sender: TObject);
begin
  CurrType := def;
end;

procedure TEditorForm.btnLineClick(Sender: TObject);
begin
  CurrType := Line;
end;

procedure TEditorForm.btnMCClick(Sender: TObject);
begin
  CurrType := MetaConst;
end;

procedure TEditorForm.btnMVClick(Sender: TObject);
begin
  CurrType := MetaVar;
end;



procedure TEditorForm.canvMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if dm = DrawLine then
  begin
    case button of
      TMouseButton.mbLeft: addNewPoint( CurrFigure^.Info.PointHead, x,y);
      TMouseButton.mbRight: dm:=NoDraw;
      TMouseButton.mbMiddle: dm:=NoDraw;
    end;

  end
  else
    DM := Draw; // �������� ���������

  if EM = NoEdit then
  begin
    if CurrType <> Line then
      CurrFigure := addRect(RectHead, x,y, CurrType, edtRectText.Text)
    else if (DM <> DrawLine) and (Button = mbLeft) then
    begin
      CurrFigure := addLine(RectHead, x,y);
      DM := DrawLine;
    end;
  end
  else
  begin
    tempx:= x;
    tempy:= y;
  end;
  ClickFigure := getClickFigure(x,y, RectHead);
end;

procedure changeCursor(Form:TForm; Mode: TEditMode);
begin
  case mode of
    NoEdit: Form.Cursor := crArrow;
    Move: Form.Cursor := crSizeAll;
    TSide: Form.Cursor := crSizeNS;
    BSide: Form.Cursor := crSizeNS;
    RSide: Form.Cursor := crSizeWE;
    LSide: Form.Cursor := crSizeWE;
    Vert1: Form.Cursor := crSizeNWSE;
    Vert2: Form.Cursor := crSizeNESW;
    Vert3: Form.Cursor := crSizeNESW;
    Vert4: Form.Cursor := crSizeNWSE;
  end;
end;

function getEditMode(status: TDrawMode; x,y: Integer; head: PRectList) :TEditMode;
var
  r:TRectInfo;
  temp: PRectList;
  tmpPoint: PPointsList;
begin
  temp := head;
  while temp <> nil do
  begin
    R := temp^.Info;
    if (status = nodraw) and (R.tp <> Line) then
    begin
      if ( (x > R.x1) and (x < R.x2) and (y > R.y1) and (y < R.y2)) then
      begin
        // ������ �������
        Result := Move;
      end
      else
      begin
        // �� ��������� �������
        Result := NoEdit;
      end;
      if ( (x > R.x1) and (x < R.x2) and ((abs(y - R.y1) < Tolerance) or (abs(y - R.y2) < Tolerance))) then
      begin
        // �������������� �������
        if (abs(y - R.y1) < Tolerance) then
          Result := TSide
        else
          Result:= BSide;
      end;
      if ( (y > R.y1) and (y < R.y2) and ((abs(x - R.x1) < Tolerance) or (abs(x - R.x2) < Tolerance))) then
      begin
        // ������������ �������
        if (abs(x - R.x1) < Tolerance) then
          Result := Lside
        else
          Result:= RSide;
      end;
      if ((abs(y-R.y1) < Tolerance) and (abs(x-R.x1) < Tolerance)) then
      begin
        // ����� ������� �������
        Result := Vert1;
      end;
      if (abs(y-R.y1) < Tolerance) and (abs(x-R.x2) < Tolerance) then
      begin
        // ������ ������� �������
        Result := Vert2;
      end;
      if (abs(y-R.y2) < Tolerance) and (abs(x-R.x1) < Tolerance) then
      begin
        // ����� ������ �������
        Result := Vert3;
      end;
      if (abs(y-R.y2) < Tolerance) and (abs(x-R.x2) < Tolerance) then
      begin
        // ������ ������ �������
        Result := Vert4;
        // ?? ?? ??? ?? ??? ?? ?? \\
      end;
      if result <> NoEdit then
      begin
        CurrFigure := temp;
        exit;
      end;
    end
    else if (status = nodraw) then
    begin
      tmpPoint := R.PointHead;
      while tmpPoint <> nil do
      begin
        if (abs(y-tmpPoint^.Info.y) < Tolerance) and (abs(x-tmpPoint^.Info.x) < Tolerance) then
        begin
          CurrFigure := temp;
          currPointAdr := tmpPoint;
          Result := Move;
          exit;
        end;
        tmpPoint := tmpPoint^.Adr;
      end;
    end;
    temp := temp^.Adr;
  end;
end;

procedure checkFigureCoord(R: PRectList);
var
  temp:integer;
begin
  with R^.Info do
  begin
    if x1 > x2 then
    begin
      temp := x1;
      x1 := x2;
      x2:=temp;
    end;
    if y1 > y2 then
    begin
      temp := y1;
      y1 := y2;
      y2:=temp;
    end;
  end;
end;

procedure ChangeCoords(F: PRectList; EM: TEditMode; x,y:integer; var TmpX, TmpY: integer);
var
  tmp: PPointsList;
begin
  if F <> nil then
  case EM of
    NoEdit:
    begin
      F^.Info.x2 := x;
      F^.Info.y2 := y;
    end;
    Move: // ���������� ������ :)
    begin
      if F^.Info.tp = Line then
      begin

        currPointAdr^.Info.x := currPointAdr^.Info.x - (TmpX - x);
        currPointAdr^.Info.y := currPointAdr^.Info.y - (Tmpy - y);
      end
      else
      begin
      // ������� ������
      // TmpX, TmpY - �������� ��������� ������������ �������� ������ �������
      F^.Info.x1 := F^.Info.x1 - (TmpX - x);
      F^.Info.x2 := F^.Info.x2 - (TmpX - x);
      F^.Info.y1 := F^.Info.y1 - (Tmpy - y);
      F^.Info.y2 := F^.Info.y2 - (TmpY - y);
      end;
    end;
    TSide:
    begin
      // ������� ������� �������
      F^.Info.y1 := F^.Info.y1 - (Tmpy - y);
    end;
    BSide:
    begin
      // ������� ������ �������
       F^.Info.y2 := F^.Info.y2 - (Tmpy - y);
    end;
    RSide:
    begin
      // ������� ������ �������
      F^.Info.x2 := F^.Info.x2 - (Tmpx - x);
    end;
    LSide:
    begin
      // ������� ����� �������
      F^.Info.x1 := F^.Info.x1 - (Tmpx - x);
    end;
    Vert1:
    begin
      F^.Info.x1 := F^.Info.x1 - (TmpX - x);
      F^.Info.y1 := F^.Info.y1 - (Tmpy - y);
    end;
    Vert2:
    begin
      F^.Info.x2 := F^.Info.x2 - (TmpX - x);
      F^.Info.y1 := F^.Info.y1 - (Tmpy - y);
    end;
    Vert3:
    begin
      F^.Info.x1 := F^.Info.x1 - (TmpX - x);
      F^.Info.y2 := F^.Info.y2 - (Tmpy - y);
    end;
    Vert4:
    begin
      F^.Info.x2 := F^.Info.x2 - (TmpX - x);
      F^.Info.y2 := F^.Info.y2 - (Tmpy - y);
    end;
  end;
end;

procedure drawLines(Canvas:TCanvas; head: PPointsList);
var
  tmp: PPointsList;
begin
  tmp := head;
  if tmp^.Adr <> nil then
  begin
    tmp := tmp^.Adr;
    canvas.MoveTo(tmp^.Info.x, tmp^.Info.y);
    canvas.Rectangle(tmp^.Info.x-VertRad,tmp^.Info.y-VertRad, tmp^.Info.x+VertRad, tmp^.Info.y+VertRad);
    tmp := tmp^.adr;
    while tmp <> nil do
    begin
      canvas.lineto(tmp^.Info.x, tmp^.Info.y);
      canvas.moveto(tmp^.Info.x, tmp^.Info.y);
      canvas.Rectangle(tmp^.Info.x-VertRad,tmp^.Info.y-VertRad, tmp^.Info.x+VertRad, tmp^.Info.y+VertRad);

      tmp:= tmp^.Adr;
    end;

  end;

end;

procedure drawRectFigure(Canvas:TCanvas; head:PRectList);
var
  temp:PRectList;
  TextW: Integer;
  TextH: Integer;
  TX, TY: integer;
  text:string;
begin
  temp := head;
  while temp <> nil do
  begin
    with temp^.Info do
    begin
      text := txt;
      case Tp of
        Def: Text := Text + ' ::= ';
        MetaVar: Text := '< ' + Text + ' >';
        MetaConst: ;
        line:
        begin
          drawLines(Canvas, temp^.Info.PointHead);
          temp := temp^.adr;
          continue;
        end;
      end;

      TextW := canvas.TextWidth(text);
      textH := Canvas.TextHeight(text);

      // ����������� ����������, ����� ����� ��� �� ��������
      TX := x1 + (x2 - x1) div 2 - TextW div 2;
      TY := y1 + (y2 - y1) div 2 - TextH div 2;

      // ���� ������ ��� ������ ����� ������, ��� ������, �� ��������� ��� ������ ������
      if (abs(x2 - x1) < TextW) then
      begin
        x1 := x1 - textw div 2 - 10;
        x2 := x2 + textw div 2 + 10;
      end;
      if (abs(y2 - y1) < TextH) then
      begin
        y1 := y1 - textH div 2 - 10;
        y2 := y2 + textH div 2 + 10;
      end;
      canvas.Pen.Color := clWhite;
      Canvas.Rectangle(x1, y1, x2, y2);
      canvas.Pen.Color := clBlack;

      // ������ �������
      canvas.Rectangle(x1-VertRad,y1-VertRad, x1+VertRad, y1+VertRad);
      canvas.Rectangle(x2-VertRad,y1-VertRad, x2+VertRad, y1+VertRad);
      canvas.Rectangle(x1-VertRad,y2-VertRad, x1+VertRad, y2+VertRad);
      canvas.Rectangle(x2-VertRad,y2-VertRad, x2+VertRad, y2+VertRad);

      Canvas.TextOut(TX,TY, text);
    end;

    temp := temp^.Adr;
  end;
end;

procedure selectFigure(canvas: TCanvas; head:PRectList);
var x1,x2,y1,y2: integer;
begin
  //ShowMessage('kek');
  canvas.Pen.Color := clGreen;
  canvas.Brush.Color := clGreen;
  x1 := head^.Info.x1;
  x2 := head^.Info.x2;
  y1 := head^.Info.y1;
  y2 := head^.Info.y2;
  // ������ �������
  canvas.Rectangle(x1-VertRad,y1-VertRad, x1+VertRad, y1+VertRad);
  canvas.Rectangle(x2-VertRad,y1-VertRad, x2+VertRad, y1+VertRad);
  canvas.Rectangle(x1-VertRad,y2-VertRad, x1+VertRad, y2+VertRad);
  canvas.Rectangle(x2-VertRad,y2-VertRad, x2+VertRad, y2+VertRad);

  //canvas.Pen.Color := clBlack;
  //showMessage('kek');
  canvas.Brush.Color := clWhite;
end;


procedure TEditorForm.canvMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

  if (CurrType <> Line) and (DM = DrawLine) then
    DM := nodraw;
  if dm = NoDraw then
  begin
    EM := getEditMode(DM, x,y,RectHead);
    changeCursor(Self, EM); // ������ ������ � ����������� �� ��������� ����

    if ClickFigure <> nil then
      selectFigure(canv.Canvas, ClickFigure);
  end;
  if (DM = draw) and (currfigure <> nil)  then
  begin
    ChangeCoords(CurrFigure, EM, x,y, tempX, tempY);
    TempX:= X; // ��������� ������� ����������
    TempY:= Y;
    clearScreen; // ������ �����
    drawRectFigure(canv.Canvas, RectHead);
  end;
end;


procedure TEditorForm.canvMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if DM <> DrawLine then
  begin
    DM := NoDraw; // ����������� ���������
    checkFigureCoord(CurrFigure);
  end;
  drawRectFigure(canv.Canvas, RectHead);
end;

procedure TEditorForm.clearScreen;
begin
  canv.Canvas.Rectangle(0,0,canv.Width,canv.Height);
end;

procedure TEditorForm.FormCreate(Sender: TObject);
begin
  createRectList(RectHead);
  CurrType := Def;
  EM := NoEdit;
  CurrFigure := nil;
  clearScreen;
end;

procedure removeFigure(head: PRectList; adr: PRectList);
var
  temp,temp2:PRectList;
begin
  temp := head;
  while temp^.adr <> nil do
  begin
    temp2 := temp^.adr;
    if temp2 = adr then
    begin
      temp^.adr := temp2^.adr;
      dispose(temp2);
    end
    else
      temp:= temp^.adr;
  end;
end;

procedure TEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = 46) and (ClickFigure <> nil) then
  begin
    removeFigure(RectHead, ClickFigure);
    clearScreen; // ������ �����
    drawRectFigure(canv.Canvas, RectHead);
    ClickFigure := nil;
  end;
end;

procedure TEditorForm.Timer1Timer(Sender: TObject);
begin
  case em of
    NoEdit: Label1.Caption := 'NoEdit';
    Move: Label1.Caption := 'Move' ;
    TSide: Label1.Caption := 'TSide' ;
    BSide: Label1.Caption := 'BSide' ;
    RSide: Label1.Caption := 'RSide' ;
    LSide: Label1.Caption := 'LSIde' ;
    Vert1: Label1.Caption := 'Vert1' ;
    Vert2: Label1.Caption := 'Vert2' ;
    Vert3: Label1.Caption := 'Vert3' ;
    Vert4: Label1.Caption := 'Vert4' ;
  end;
  case dm of
    Draw: Label2.Caption := 'Draw';
    NoDraw: Label2.Caption := 'Nodraw';
    DrawLine: Label2.Caption := 'DrawLine';
  end;
end;

end.
