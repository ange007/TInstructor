# TInstructor
> FMX component for a better way for new feature introduction and step-by-step users guide in your program. 

![](ScreenShoot.png)

## Example
```delphi
uses
... Instructor ...

type
  TForm1 = class(TForm)
    instructor: TInstructor;
....

var
  scenaries: TDictionary<TFmxObject, string>;
begin
  scenaries := TDictionary<TFmxObject, string>.Create;
  scenaries.Add(btn_1, '1 Button');
  scenaries.Add(btn_2, '2 Button');
  scenaries.Add(btn_3, '3 Button');
  scenaries.Add(rctngl, 'Rectangle'#13#10'Rectangle'#13#10'Rectangle'#13#10'Rectangle'#13#10'Rectangle'#13#10'Rectangle'#13#10'Rectangle');
  scenaries.Add(pnl_1, 'Panel Panel Panel Panel Panel Panel Panel Panel Panel Panel'#13#10'Panel');
  scenaries.Add(nil, 'Msg without target control!');

  try
    instructor.LoadSteps(scenaries);
  finally
    FreeAndNil(scenaries);
  end;
```
