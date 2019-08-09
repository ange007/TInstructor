unit Instructor;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.UITypes,
  System.UIConsts, System.Types, System.Math, FMX.Forms,
  FMX.Types, FMX.Controls, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects,
  FMX.Graphics, FMX.TextLayout, FMX.Layouts;

type
  TInstructorPanelOption = (PrevButton, NextButton, StopButton);
  TInstructorPanelOptions = set of TInstructorPanelOption;

  TInstructor = class(TControl)
  private
    {Controls}
    FPaintBox: TShape;
    FCalloutPanel: TCalloutPanel;
    FLabel: TLabel;
    FButtonPrev: TButton;
    FButtonNext: TButton;
    FButtonStop: TButton;
    {Steps}
    FSteps: TDictionary<TFmxObject, string>;
    FActiveStep: Integer;
    {Style}
    FBackground: TBrush;
    FControlBorder: TStrokeBrush;
    FCaptionBackground: TAlphaColor;
    {}
    FCircle: Boolean;
    FNextAfterClick: Boolean;
    FAutoStop: Boolean;
    {Panel Options}
    FPanelOptions: TInstructorPanelOptions;
    FPrevButtonText: string;
    FNextButtonText: string;
    FStopButtonText: string;
    FButtonHeight: Single;
    {Callback`s}
    FOnStart: TProc;
    FOnNextStep: TProc<Integer>;
    FOnStop: TProc;
    {Create controls}
    procedure CreatePaintBox;
    procedure CreateCalloutPanel;
    {Main Style}
    procedure SetOpacity(const Value: Single);
    procedure SetBackground(const Value: TBrush);
    procedure SetBorder(const Value: TStrokeBrush);
    {Set Font Style}
    procedure SetLabelFont(const Value: TFont);
    procedure SetLabelFontColor(const Value: TAlphaColor);
    procedure SetLabelStyledSettings(const Value: TStyledSettings);
    procedure SetButtonFont(const Value: TFont);
    procedure SetButtonFontColor(const Value: TAlphaColor);
    procedure SetButtonStyledSettings(const Value: TStyledSettings);
    {Get Font Style}
    function GetLabelFont: TFont;
    function GetLabelFontColor: TAlphaColor;
    function GetLabelStyledSettings: TStyledSettings;
    function GetButtonFont: TFont;
    function GetButtonFontColor: TAlphaColor;
    function GetButtonStyledSettings: TStyledSettings;
    {Button actions}
    procedure UpdateButtonState;
    procedure OnPrevButtonClick(Sender: TObject);
    procedure OnNextButtonClick(Sender: TObject);
    procedure OnStopButtonClick(Sender: TObject);
  protected
    procedure Paint; override;
    procedure Click; override;
  public
    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(AOwner: TComponent; const Steps: TDictionary<TFmxObject, string>); overload; dynamic;
    destructor Destroy; override;
    {}
    procedure LoadSteps(const Steps: TDictionary<TFmxObject, string>; const AutoStart: Boolean = True);
    {Actions}
    procedure Prev;
    procedure Next;
    procedure Start;
    procedure Stop;
  published
    property Visible;
    property Background: TBrush read FBackground write SetBackground;
    property ControlBorder: TStrokeBrush read FControlBorder write SetBorder;
    property LabelFont: TFont read GetLabelFont write SetLabelFont;
    property LabelFontColor: TAlphaColor read GetLabelFontColor write SetLabelFontColor;
    property LabelStyledSettings: TStyledSettings read GetLabelStyledSettings write SetLabelStyledSettings;
    property ButtonFont: TFont read GetButtonFont write SetButtonFont;
    property ButtonFontColor: TAlphaColor read GetButtonFontColor write SetButtonFontColor;
    property ButtonStyledSettings: TStyledSettings read GetButtonStyledSettings write SetButtonStyledSettings;
    {}
    property Circle: Boolean read FCircle write FCircle default False;
    property NextAfterClick: Boolean read FNextAfterClick write FNextAfterClick default True;
    property AutoStop: Boolean read FAutoStop write FAutoStop default True;
    property ActiveStep: Integer read FActiveStep write FActiveStep;
    {Panel Options}
    property PanelOptions: TInstructorPanelOptions read FPanelOptions write FPanelOptions default [PrevButton, NextButton, StopButton];
    property ButtonPrevText: string read FPrevButtonText write FPrevButtonText;
    property ButtonNextText: string read FNextButtonText write FNextButtonText;
    property ButtonStopText: string read FStopButtonText write FStopButtonText;
    property ButtonHeight: Single read FButtonHeight write FButtonHeight;
    {Callback`s}
    property OnStart: TProc read FOnStart write FOnStart;
    property OnNextStep: TProc<Integer> read FOnNextStep write FOnNextStep;
    property OnStop: TProc read FOnStop write FOnStop;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TInstructor]);
end;

constructor TInstructor.Create(AOwner: TComponent);
begin
  inherited;

  {Default params}
  Visible := False;
  Align := TAlignLayout.Contents;

  {Translate}
  FPrevButtonText := 'Prev';
  FNextButtonText := 'Next';
  FStopButtonText := 'Stop';

  {Background&Panel}
  CreatePaintBox;
  CreateCalloutPanel;

  {Style}
  FBackground := TBrush.Create(TBrushKind.Solid, TAlphaColor($AAB3B2B2));
  FControlBorder := TStrokeBrush.Create(TBrushKind.Solid, TAlphaColorRec.Black);
  FCaptionBackground := TAlphaColorRec.Darkgray;

  {}
  FActiveStep := -1;
  FButtonHeight := 30;
  FNextAfterClick := True;
  FAutoStop := True;
  FPanelOptions := [PrevButton, NextButton, StopButton];
end;

constructor TInstructor.Create(AOwner: TComponent; const Steps: TDictionary<TFmxObject, string>);
begin
  Create(AOwner);

  {LoadSteps}
  LoadSteps(Steps);
end;

destructor TInstructor.Destroy;
begin
  FPaintBox.Free;
  FCalloutPanel.Free; {FLabel, FButton*}
  FSteps.Free;
  FBackground.Free;

  inherited;
end;

{

}

procedure TInstructor.CreatePaintBox;
begin
  FPaintBox := TShape.Create(Self);
  with FPaintBox do
  begin
    Parent := Self;
    Stored := False;
    HitTest := False;
    Align := TAlignLayout.Contents;
    SendToBack;
  end;
end;

procedure TInstructor.CreateCalloutPanel;
var
  useButtons: Boolean;
begin
  useButtons := (PrevButton in FPanelOptions)
                or (NextButton in FPanelOptions)
                or (StopButton in FPanelOptions);

  FCalloutPanel := TCalloutPanel.Create(Self);
  with FCalloutPanel do
  begin
    Parent := Self;
    Stored := False;
    BringToFront;
  end;

  FLabel := TLabel.Create(FCalloutPanel);
  with FLabel do
  begin
    Parent := FCalloutPanel;
    Align := TAlignLayout.MostTop;
    Text := '...';
    VertTextAlign := TTextAlign.Center;
    AutoSize := True;
    Margins.Top := 5;
    Margins.Bottom := IfThen(useButtons, 10, 5);
  end;

  FButtonPrev := TButton.Create(FCalloutPanel);
  with FButtonPrev do
  begin
    Parent := FCalloutPanel;
    Text := FPrevButtonText;
    Align := TAlignLayout.Left;
    Height := FButtonHeight;
    Width := 60;
    Margins.Top := 5;
    Margins.Right := 5;
    OnClick := OnPrevButtonClick;
  end;

  FButtonStop := TButton.Create(FCalloutPanel);
  with FButtonStop do
  begin
    Parent := FCalloutPanel;
    Text := FStopButtonText;
    Align := TAlignLayout.Client;
    Height := FButtonHeight;
    Width := 30;
    Margins.Top := 5;
    OnClick := OnStopButtonClick;
  end;

  FButtonNext := TButton.Create(FCalloutPanel);
  with FButtonNext do
  begin
    Parent := FCalloutPanel;
    Text := FNextButtonText;
    Align := TAlignLayout.Right;
    Height := FButtonHeight;
    Width := 60;
    Margins.Top := 5;
    Margins.Left := 5;
    OnClick := OnNextButtonClick;
  end;
end;

{


}

procedure TInstructor.SetOpacity(const Value: Single);
begin
  FOpacity := Value;

  Repaint;
end;

procedure TInstructor.SetBackground(const Value: TBrush);
begin
  FBackground.Assign(Value);

  Repaint;
end;

procedure TInstructor.SetBorder(const Value: TStrokeBrush);
begin
  FControlBorder.Assign(Value);

  Repaint;
end;

procedure TInstructor.SetLabelFont(const Value: TFont);
begin
  FLabel.Font := Value;
  FLabel.StyledSettings := FLabel.StyledSettings - [TStyledSetting.Family,
                                                    TStyledSetting.Size,
                                                    TStyledSetting.Style];

  Repaint;
end;

procedure TInstructor.SetLabelFontColor(const Value: TAlphaColor);
begin
  if Value = 0 then Exit;

  FLabel.FontColor := Value;
  Repaint;
end;

procedure TInstructor.SetLabelStyledSettings(const Value: TStyledSettings);
begin
  FLabel.StyledSettings := Value;

  Repaint;
end;

procedure TInstructor.SetButtonFont(const Value: TFont);
begin
  FButtonPrev.Font := Value;
  FButtonPrev.StyledSettings := FButtonPrev.StyledSettings - [TStyledSetting.Family,
                                                              TStyledSetting.Size,
                                                              TStyledSetting.Style];

  FButtonNext.Font := Value;
  FButtonNext.StyledSettings := FButtonNext.StyledSettings - [TStyledSetting.Family,
                                                              TStyledSetting.Size,
                                                              TStyledSetting.Style];

  FButtonStop.Font := Value;
  FButtonStop.StyledSettings := FButtonStop.StyledSettings - [TStyledSetting.Family,
                                                              TStyledSetting.Size,
                                                              TStyledSetting.Style];

  Repaint;
end;

procedure TInstructor.SetButtonFontColor(const Value: TAlphaColor);
begin
  if Value = 0 then Exit;

  FButtonPrev.FontColor := Value;
  FButtonNext.FontColor := Value;
  FButtonStop.FontColor := Value;

  Repaint;
end;

procedure TInstructor.SetButtonStyledSettings(const Value: TStyledSettings);
begin
  FButtonPrev.StyledSettings := Value;
  FButtonNext.StyledSettings := Value;
  FButtonStop.StyledSettings := Value;

  Repaint;
end;


function TInstructor.GetLabelFont: TFont;
begin
  Result := FLabel.Font;
end;

function TInstructor.GetLabelFontColor: TAlphaColor;
begin
  Result := FLabel.FontColor;
end;

function TInstructor.GetLabelStyledSettings: TStyledSettings;
begin
  Result := FLabel.StyledSettings;
end;

function TInstructor.GetButtonFont: TFont;
begin
  Result := FButtonPrev.Font;
end;

function TInstructor.GetButtonFontColor: TAlphaColor;
begin
  Result := FButtonPrev.FontColor;
end;


function TInstructor.GetButtonStyledSettings: TStyledSettings;
begin
  Result := FButtonPrev.StyledSettings;
end;

{ ============
  Steps
 =============}

procedure TInstructor.LoadSteps(const Steps: TDictionary<TFmxObject, string>; const AutoStart: Boolean);
begin
  if Assigned(FSteps) then FreeAndNil(FSteps);

  {Load steps}
  if Assigned(Steps) then FSteps := TDictionary<TFmxObject, string>.Create(Steps)
  else FSteps := TDictionary<TFmxObject, string>.Create;

  {AutoStart}
  if AutoStart then Start;
end;

{Previos scenario}
procedure TInstructor.Prev;
begin
  if FSteps.Count <= 0 then Exit;

  {}
  if not (FCircle) and (FActiveStep = 0) then Exit;

  {}
  if (FCircle) and (FActiveStep = 0) then FActiveStep := FSteps.Count - 1
  else Dec(FActiveStep);

  {Update}
  Repaint;
end;

{Next scenario}
procedure TInstructor.Next;
begin
  if FSteps.Count <= 0 then Exit;

  {}
  if not (FCircle) and (FActiveStep >= FSteps.Count - 1) then
  begin
    if FAutoStop then Stop;
    Exit;
  end;

  {}
  if (FCircle) and (FActiveStep >= FSteps.Count - 1) then FActiveStep := 0
  else Inc(FActiveStep);

  {Callback}
  if Assigned(FOnNextStep) then FOnNextStep(FActiveStep);

  {Update}
  Repaint;
end;

{Start work}
procedure TInstructor.Start;
begin
  if FSteps.Count <= 0 then Exit;

  {Clear}
  FActiveStep := 0;

  {Show}
  Visible := True;

  {Callback}
  if Assigned(FOnStart) then FOnStart;

  {Update}
  Repaint;
end;

{Stop work}
procedure TInstructor.Stop;
begin
  {Clear}
  FActiveStep := 0;
  FSteps.Clear;

  {Callback}
  if Assigned(FOnStop) then FOnStop;

  {Hide}
  Visible := False;
end;

{ ============
  Paint
 =============}

{Paint}
procedure TInstructor.Paint;

  function calculateCaptionSize(const targetCaption: string; const maxWidth: Single): TRectF;
  begin
    with TTextLayoutManager.DefaultTextLayout.Create do
    begin
      BeginUpdate;
      try
        MaxSize := PointF(maxWidth, Self.Height);
        Text := targetCaption;
        WordWrap := True;
        HorizontalAlign := TTextAlign.Center;
        VerticalAlign := TTextAlign.Center;
        Font := FLabel.Font;
      finally
        EndUpdate;
      end;

      Result := TextRect;
      Free;
    end;
  end;

  procedure setCalloutPanelPosition(const targetRect: TRectF; const X, Y: Single);
  var
    centerCoordinate: TRectF;
  begin
    with FCalloutPanel do
    begin
      {Calculate Center}
      centerCoordinate := AbsoluteRect.CenterAt(targetRect);

      {Set position}
      Position.X := IfThen(X = -999, centerCoordinate.Location.X, X);
      Position.Y := IfThen(Y = -999, centerCoordinate.Location.Y, Y);

      {Bottom shift}
      if (Position.Y + Height) > (Self.AbsoluteRect.Bottom - 10) then Position.Y := Self.AbsoluteRect.Bottom - Height - 10;
      {Left shift}
      if Position.X < 10 then Position.X := 10;
      {Top shift}
      if Position.Y < 10 then Position.Y := 10;
      {Right shift}
      if (Position.X + Width) > (Self.AbsoluteRect.Right - 10) then Position.X := Self.AbsoluteRect.Right - Width - 10;
    end;
  end;

  function calloutPanelManipulation(const targetRect: TRectF; const targetCaption: string): TRectF;
  var
   captionSize: TRectF;
   useButtons: Boolean;
  begin
    useButtons := (PrevButton in FPanelOptions)
                  or (NextButton in FPanelOptions)
                  or (StopButton in FPanelOptions);

    with FCalloutPanel do
    begin
      BeginUpdate;
      try
        FLabel.Text := targetCaption;

        {Update Buttons}
        UpdateButtonState;
        FButtonPrev.Visible := (PrevButton in FPanelOptions);
        FButtonNext.Visible := (NextButton in FPanelOptions);
        FButtonStop.Visible := (StopButton in FPanelOptions);

        {Width}
        Width := (Self.Width / 2);
        if Width > FLabel.Width then Width := FLabel.Width;
        if Width < 200 then Width := IfThen(Self.Width <= 200, Self.Width, 200);
        if Width > 400 then Width := 500;

        {Calculate caption Size}
        captionSize := calculateCaptionSize(targetCaption, Width - (Margins.Left + Margins.Right + Padding.Left + Padding.Right) - 10);

        {Height}
        Height := captionSize.Height
                  + FLabel.Margins.Top + FLabel.Margins.Bottom
                  + IfThen(useButtons, FButtonHeight, 0);

        {Reset Paddings}
        Padding.Top := 10;
        Padding.Bottom := 10;
        Padding.Left := 10;
        Padding.Right := 10;

        {Если не указан целевой контрол}
        if targetRect.Height = 0 then
        begin
          CalloutPosition := TCalloutPosition.Bottom;
          Padding.Bottom := 20;
          Height := Height + Padding.Top + Padding.Bottom;

          setCalloutPanelPosition(Self.AbsoluteRect, -999, -999);

          Exit;
        end;

        {Show in Bottom}
        if Height < (Self.AbsoluteRect.Bottom - targetRect.Bottom - 35) then
        begin
          CalloutPosition := TCalloutPosition.Top;
          Padding.Top := 20;
          Height := Height + Padding.Top + Padding.Bottom;

          setCalloutPanelPosition(targetRect, -999, targetRect.Bottom + 5);
        end
        {Show in Left}
        else if Width < targetRect.Left then
        begin
          CalloutPosition := TCalloutPosition.Right;
          Padding.Right := 20;
          Height := Height + Padding.Top + Padding.Bottom;

          setCalloutPanelPosition(targetRect, targetRect.Left - Width - 5, -999);
        end
        {Show in Top}
        else if Height <= (targetRect.Top + 35) then
        begin
          CalloutPosition := TCalloutPosition.Bottom;
          Padding.Bottom := 20;
          Height := Height + Padding.Top + Padding.Bottom;

          setCalloutPanelPosition(targetRect, -999, targetRect.Top - Height - 5);
        end
        {Show in Right}
        else if Width < (Self.AbsoluteRect.Right - targetRect.Right) then
        begin
          CalloutPosition := TCalloutPosition.Left;
          Padding.Left := 20;
          Height := Height + Padding.Top + Padding.Bottom;

          setCalloutPanelPosition(targetRect, targetRect.Right + 5, -999);
        end;
      finally
        FCalloutPanel.EndUpdate;
      end;
    end;
  end;

var
  targetControl: TControl;
  targetCaption: string;
  targetRect: TRectF;
  lPath: TPathData;
begin
  inherited;

  {BringToFront}
  BringToFront;

  {Check Scenaries}
  if FSteps.Count <= 0 then Exit;

  BeginUpdate;
  try
    {Set Style}
    if Assigned(FBackground) then FPaintBox.Canvas.Fill := FBackground;

    {Control Data}
    targetControl := FSteps.Keys.ToArray[FActiveStep] as TControl;
    targetCaption := FSteps.Values.ToArray[FActiveStep];

    {Show Panel}
    if not Assigned(targetControl) then
    begin
      calloutPanelManipulation(TRect.Empty, targetCaption);

      {If you don’t need to do anything, just fill the background}
      FPaintBox.Canvas.FillRect(FPaintBox.ShapeRect, 0, 0, [], 1);
      Exit;
    end
    else
    begin
      if Self.Parent is TForm then targetRect := targetControl.AbsoluteRect
      else targetRect := targetControl.BoundsRect;

      calloutPanelManipulation(targetRect, targetCaption);
    end;

    {Background}
    with FPaintBox.Canvas do
    begin
      BeginScene;
      try
        lPath := TPathData.Create;
        try
          lPath.AddRectangle(FPaintBox.ShapeRect, 0,0, []);
          lPath.AddRectangle(targetRect, 0,0, []);

          FillPath(lPath, 1);
        finally
          FreeAndNil(lPath);
        end;

        {Stroke}
        DrawRect(targetRect, 0, 0,
                [TCorner.TopLeft, TCorner.TopRight, TCorner.BottomLeft, TCorner.BottomRight],
                1, FControlBorder, TCornerType.Round);
      finally
        EndScene;
      end;
    end;
  finally
    EndUpdate;
  end;
end;

{ ============
  Buttons
 =============}

{Update state}
procedure TInstructor.UpdateButtonState;
begin
  if not (FCircle) then
  begin
    FButtonPrev.Enabled := (FSteps.Count > 0) and (FActiveStep > 0);
    FButtonNext.Enabled := (FSteps.Count > 0) and (FActiveStep < FSteps.Count - 1);
    FButtonStop.Enabled := (FSteps.Count > 0);
  end;
end;

procedure TInstructor.Click;
begin
  inherited;

  if FNextAfterClick then Next;
end;

procedure TInstructor.OnPrevButtonClick(Sender: TObject);
begin
  Prev;
end;

procedure TInstructor.OnNextButtonClick(Sender: TObject);
begin
  Next;
end;

procedure TInstructor.OnStopButtonClick(Sender: TObject);
begin
  Stop;
end;

end.

