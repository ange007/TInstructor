unit Form;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Instructor,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, System.Generics.Collections,
  FMX.Layouts;

type
  TForm1 = class(TForm)
    pnl_main: TPanel;
    btn_1: TButton;
    btn_2: TButton;
    instructor: TInstructor;
    btn_instructor: TButton;
    grdpnlyt1: TGridPanelLayout;
    pnl_1: TPanel;
    rctngl: TRectangle;
    btn_3: TButton;
    procedure btn_instructorClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.btn_instructorClick(Sender: TObject);
var
  steps: TDictionary<TFmxObject, string>;
begin
  steps := TDictionary<TFmxObject, string>.Create;
  steps.Add(btn_1, '1 Button');
  steps.Add(btn_2, '2 Button');
  steps.Add(btn_3, '3 Button');
  steps.Add(rctngl, 'Rectangle'#13#10'Rectangle'#13#10'Rectangle'#13#10'Rectangle'#13#10'Rectangle'#13#10'Rectangle'#13#10'Rectangle');
  steps.Add(pnl_1, 'Panel Panel Panel Panel Panel Panel Panel Panel Panel Panel'#13#10'Panel');
  steps.Add(nil, 'Msg without target control!');

  try
    instructor.LoadSteps(steps);
  finally
    FreeAndNil(steps);
  end;
end;

end.
