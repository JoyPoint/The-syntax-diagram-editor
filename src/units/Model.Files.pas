unit Model.Files;

interface
uses Data.Types;
function readFile(var head:PFigList; filedir:string):boolean;
procedure saveToFile(Head: PFigList; filedir: string);
function pointsToStr(tmpPoints: PPointsList):string;
implementation

uses System.SysUtils, Data.InitData, Main, vcl.dialogs;

// ������ �����
// ��������!
// � ������ �������� ������ �������� �������� �� ����������
// � ������� �������, ����������� ������������s�
function readFile(var head:PFigList; filedir:string):boolean;
var
  f: file of TFigureInFile;
  OTemp: PFigList;
  tmp: TFigureInFile;
  ptemp: PPointsList;
  xy: string;
begin
  Result := false;
  AssignFile(f, filedir);
  if fileExists(filedir) then
  begin
    Reset(f);

    OTemp := Head;
    if Eof(f) then Raise Exception.Create(rsTrashFile);

    read(f, tmp);
    if tmp.Check <> 'BRAKH' then // �������� ���������� �����
    begin
      close(f);
      Raise Exception.Create(rsInvalidFile);
      exit;
    end;

    // ��������� ���������:
    EditorForm.changeCanvasSize(tmp.Width,tmp.Height);
    head^.Adr := nil;

    try
      while not EOF(f) do
      begin
        new(OTemp^.adr);
        OTemp:=OTemp^.adr;
        OTemp^.adr:=nil;

          read(f, tmp);
          OTemp^.Info.tp := tmp.tp;
          if tmp.tp = line then
          begin
            OTemp^.Info.tp := line;
            Otemp^.Info.LT := tmp.LT;
            new(OTemp^.Info.PointHead);
            ptemp := OTemp^.Info.PointHead;
            ptemp^.Adr := nil;
            // ������� ������ ������� "X1/Y1""X2/Y2""X3/Y3"
            if tmp.Point <> '' then
            begin
              Delete(tmp.Point,1,1);
              tmp.Point := tmp.Point + '"';
            end;
            while (length(tmp.Point) <> 0) and (tmp.Point <> '"') do
            begin
              xy := copy(tmp.point,1, pos('"', tmp.Point)-1);
              Delete(tmp.point,1, pos('"', tmp.Point)+1);
              if (tmp.Point <> '') or (xy <> '') then
              begin
                new(ptemp^.Adr);
                ptemp := ptemp^.Adr;
                ptemp^.Adr := nil;
                ptemp^.Info.x := strtoint(copy(xy, 1,pos('/', xy)-1));
                ptemp^.Info.y := strtoint(copy(xy, pos('/', xy)+1, length(xy)));
              end;
            end;
            result := true;
          end
          else
          begin
            OTemp^.info.txt := tmp.Txt;
            otemp^.info.x1 := tmp.x1;
            otemp^.info.x2 := tmp.x2;
            otemp^.info.y1 := tmp.y1;
            otemp^.info.y2 := tmp.y2;
            result := true;
          end;

      end;
      except on E: Exception do
        MessageDlg(rsTrashFile, mtWarning, [mbOk], 0);
      end;
  end
  else
  begin
    Rewrite(f); // ���� ���� �� ������ - ���� �������
    result := true;
  end;
  close(f);
  EditorForm.SD_Resize;
end;

// �������� ���������� ������������� ������ ����� (������: "X1/Y1""X2/Y2""X3/Y3"...)
function pointsToStr(tmpPoints: PPointsList):string;
begin
  Result := '';
  while tmpPoints <> nil do
  begin
    Result := Result + ShortString('"' + IntToStr(tmpPoints.Info.x) + '/' + IntToStr(tmpPoints.Info.y) +'"');
    tmpPoints := tmpPoints^.Adr;
  end;
end;

// ���������� �����
// ��������!
// � ������ �������� ������ �������� �������� �� ����������
// � ������� �������, ����������� �������������
procedure saveToFile(Head: PFigList; filedir: string);
var f: file of TFigureInFile;
  temp: PFigList;
  tmpPoints: PPointsList;
  tempRec: TFigureInFile;
  st: string[255];
begin
  AssignFile(f, filedir);
  rewrite(f);
  tempRec.tp := TTYPE(4);
  EditorForm.getCanvasSize(tempRec.Width,tempRec.Height); // ���������� ��������
  tempRec.Check := 'BRAKH'; // ���������� ������-�������� ����������
  Write(f, tempRec);
  temp := head^.adr;
  while temp <> nil do
  begin
    tempRec.tp := temp^.Info.tp;
    if tempRec.tp = Line then
    begin
      tmpPoints := temp^.Info.PointHead^.adr;
      st := pointsToStr(tmpPoints);
      tempRec.Point := st;
      tempRec.LT := temp^.Info.LT;
      tempRec.tp := Line;
    end
    else
    begin
      tempRec.txt := temp^.Info.Txt;
      tempRec.x1 := temp^.Info.x1;
      tempRec.x2 := temp^.Info.x2;
      tempRec.y1 := temp^.Info.y1;
      tempRec.y2 := temp^.Info.y2;
    end;

    write(f, tempRec);
    temp:=temp^.adr;
  end;
  close(F);
end;

end.
