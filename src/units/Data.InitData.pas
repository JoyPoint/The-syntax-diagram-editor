unit Data.InitData;

interface
const
  Tolerance = 5; // ���-�� ��������, �� ������� ����� ����� "������������"
  NearFigure = 20; // ���������� ��������, ��� ������� ���� "�������������" ������;
  step_round = 20; // "��� �����"
  Default_LineSVG_Width = 2; // ������ ����� � SVG
  Font_Size = 8; // ������ ������

resourcestring // ������ � �������:
  rsNewFileDlg = '�� �������? ��� ������������� ������ ����� �������. ����������?';
  rsNewFile = '����� ����';
  rsExitDlg = '�� ������ ���������.. � �� ������ �� �� ����������� ����� ���, ��� �����?';
  rsInvalidFile = '�� ��������� ������� �����-�� ���������� ����. ����������, ����������� ������ �����, ��������� ���� ����������!';
  rsTrashFile = '���� ���������!';
resourcestring // ������ ������
  rsHelpHowIsSD_Caption = '��� ����� �������������� ���������?';
  rsHelp_Caption = '������';
  // �������� ��������
  rsHelpHowIsSD_ResName = 'help1';
  rsHelp_ResName = 'help2';
 const // ����� �����
  SRuChangeLangMsg = '���� �������. ��� ����, ����� �� ���������, ������������� ����������';
  SEnChangeLangMsg = 'The language is changed. In order for it to be updated, restart the application';


  // ### VIEW PART CONSTANTS ###
const
  VertRad = 3; // ������ �������

  Arrow_Width = 20; // ������ "�����" �������
  Arrow_Height = 10; // ������ �������

  Lines_Width = 2; // ������ ����� �������
  Lines_Deg = 15; // ������ ������������� "�����"
  Lines_DegLenght = 15; // ������ ������������� "�����"
implementation

end.
