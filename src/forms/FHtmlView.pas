unit FHtmlView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, SHDocVw, Vcl.Menus;

type
  TFHtml = class(TForm)
    WebBrowser1: TWebBrowser;
    pmHtmlMenu: TPopupMenu;
    pmiClose: TMenuItem;
    procedure pmiCloseClick(Sender: TObject);
  private
    procedure WMMouseActivate(var Msg: TMessage); message WM_MOUSEACTIVATE;
  public
    procedure showHTML(title, htmlres: WideString);
  end;

var
  FHtml: TFHtml;


implementation

{$R *.dfm}

// ������� ����������� ����������� ���� TWebBrowser � ����������
// ����
procedure TFHtml.WMMouseActivate(var Msg: TMessage);
begin

	try
	  inherited;
	  //�����������, ����� ������ ���� ������
	  if Msg.LParamHi = 516 then // ���� ������
	  // ���������� ���� ����
	  pmHtmlMenu.Popup(Mouse.CursorPos.x, Mouse.CursorPos.y);
	  Msg.Result := 0;
	except

	end;
end;

procedure TFHtml.pmiCloseClick(Sender: TObject);
begin
  Self.Close;
end;

// ����������� HTML �������� �� ��������.
procedure TFHtml.showHTML(title, htmlres: WideString);
var
  s: WideString;
  Flags, TargetFrameName, PostData, Headers: OleVariant;
begin
  Self.Caption := title;
  WebBrowser1.Navigate('res://' + Application.ExeName + '/' + htmlres,
  Flags, TargetFrameName, PostData, Headers);
  Self.ShowModal;
end;

end.
