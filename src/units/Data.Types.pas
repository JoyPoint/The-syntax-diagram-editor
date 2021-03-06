unit Data.Types;

interface
type
  TDrawMode = (Draw, NoDraw, DrawLine, ResizeCanvas);  // ����� ���������
  TFileMode = (FSvg, FBrakh, FBmp, FPng); // ����� ��������/���������� �����
  TLineType = (LLine);
  TEditMode = (NoEdit, Move, TSide, BSide, RSide, LSide, Vert1, Vert2, Vert3, Vert4, LineMove);
  // ����� ��������������
  TType = (Def,MetaVar,MetaConst, Line, None);
  // ����� ������

  // ������ ����� ������
  TPointsInfo = record
    x,y: integer;
  end;
  PPointsList = ^TPointsList;
  TPointsList = record
    Info: TPointsInfo;
    Adr:PPointsList;
  end;
  // ������ ����� �����

  // ������  ����� ������
  TFigureInfo = record
    case tp:TType of
    Def, MetaConst, MetaVar: (x1,x2,y1,y2: integer;Txt: string[255];);
    Line: (PointHead: PPointsList; LT: TLineType);
    None: (Check:string[5];Width, Height: Integer;);
  end;
  PFigList = ^FigList;
  FigList = record
    Info: TFigureInfo;
    Adr: PFigList;
  end;
  // ������ ����� �����


  // ������������� ����� � �����
  TFigureInFile = record
    case tp:TType of
    Def, MetaConst, MetaVar: (Txt: string[255];x1,x2,y1,y2: integer);
    Line: (Point:String[255]; LT: TLineType);
    None: (Check:string[5];Width, Height: Integer;);
  end;

  // ������ ���������� �����
  PSelectFigure = ^TSelectFigure;
  TSelectFigure = record
    Figure: PFigList;
    Adr: PSelectFigure;
  end;

  // UNDO STACK
  TChangeType = (chDelete, chInsert, chAddPoint,  chFigMove, chPointMove, chChangeText,  chCanvasSize, NonDeleted);
  TUndoStackInfo = record
    adr: PFigList;
  Case ChangeType : TChangeType of
    chDelete: (PrevFigure: PFigList); // �������� ������
    chAddPoint: (PrevPointAdr: PPointsList); // ���������� ����� � �����
    chInsert: (); // ���������� ������
    chFigMove: (PrevInfo: TFigureInfo); // �����������/��������� �������� �����. PrevInfo - ���������� "������"
    chPointMove: (st: string[255]);
    chChangeText: (text: string[255]);
    chCanvasSize: (w,h: Cardinal);
    NonDeleted: (); // ������������ ��� ����������� ��������� ������ �����, ������� ������ pop
  end;

  PUndoStack = ^TUndoStack;
  TUndoStack = record
    Inf: TUndoStackInfo;
    Prev: PUndoStack;
  end;

implementation

end.




