unit MainForm;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.IniFiles,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.DialogService.Sync,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Edit,
  FMX.Controls.Presentation,
  FMX.Layouts,
  FMX.Effects
  {$IFDEF MSWINDOWS}
  , Winapi.Windows
  {$ENDIF}
  ;

type
  // 타이머 모드 정의 (집중, 짧은 휴식, 긴 휴식, 빠른 테스트)
  TTimerMode = (tmWork, tmShortBreak, tmLongBreak, tmTest);

  // 타이머 실행 상태 정의
  TTimerState = (tsIdle, tsRunning, tsPaused);

  // 테마 모드 정의 (크림 낮 파스텔, 밤하늘 라벤더)
  TAppTheme = (thLight, thDark);

  TfrmMain = class(TForm)
    // 배경
    rectBackground: TRectangle;

    // 헤더 영역
    lytHeader: TLayout;
    lblAppTitle: TLabel;
    lblSubtitle: TLabel;
    rectBtnGame: TRectangle;
    lblBtnGame: TLabel;
    rectBtnPin: TRectangle;
    lblBtnPin: TLabel;
    rectBtnSound: TRectangle;
    lblBtnSound: TLabel;
    rectThemeToggle: TRectangle;
    lblThemeToggle: TLabel;

    // 1. 오늘의 한 줄 집중 목표 입력 카드
    rectGoalCard: TRectangle;
    lblGoalPrefix: TLabel;
    edtFocusGoal: TEdit;

    // 모드 선택 탭 바
    rectModeBar: TRectangle;
    rectModeWork: TRectangle;
    lblModeWork: TLabel;
    rectModeShortBreak: TRectangle;
    lblModeShortBreak: TLabel;
    rectModeLongBreak: TRectangle;
    lblModeLongBreak: TLabel;
    rectModeTest: TRectangle;
    lblModeTest: TLabel;

    // 2. 퀵 시간 조절 영역 (-5m, -1m, +1m, +5m)
    lytQuickAdjust: TLayout;
    rectBtnMinus5: TRectangle;
    lblBtnMinus5: TLabel;
    rectBtnMinus1: TRectangle;
    lblBtnMinus1: TLabel;
    rectBtnPlus1: TRectangle;
    lblBtnPlus1: TLabel;
    rectBtnPlus5: TRectangle;
    lblBtnPlus5: TLabel;

    // 중앙 타이머 영역
    lytTimerCenter: TLayout;
    circleBack: TCircle;
    arcBackground: TArc;
    arcProgress: TArc;
    lytCenterText: TLayout;
    lblModeBadge: TLabel;
    lblTimeDisplay: TLabel;
    lblStatusMessage: TLabel;
    lblCheerQuote: TLabel; // 3. 힐링 응원 문구

    // 하단 제어 버튼
    lytControls: TLayout;
    rectBtnReset: TRectangle;
    lblBtnReset: TLabel;
    rectBtnStart: TRectangle;
    lblBtnStart: TLabel;
    rectBtnSkip: TRectangle;
    lblBtnSkip: TLabel;

    // 하단 수확 바구니 & 목표 달성도 카드
    rectStats: TRectangle;
    lblStatsTitle: TLabel;
    rectBtnResetBasket: TRectangle; // 4. 바구니 비우기
    lblBtnResetBasket: TLabel;
    lblHarvestIcons: TLabel;        // 5. 시각적 토마토 농장 수확 현황
    lblGoalText: TLabel;            // 6. 일일 목표 진행도
    rectGoalBarTrack: TRectangle;
    rectGoalBarFill: TRectangle;
    lblTotalFocusTime: TLabel;

    // 1초 주기 타이머
    TimerTick: TTimer;

    // 이벤트 핸들러
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure TimerTickTimer(Sender: TObject);
    procedure rectModeWorkClick(Sender: TObject);
    procedure rectModeShortBreakClick(Sender: TObject);
    procedure rectModeLongBreakClick(Sender: TObject);
    procedure rectModeTestClick(Sender: TObject);
    procedure rectBtnStartClick(Sender: TObject);
    procedure rectBtnResetClick(Sender: TObject);
    procedure rectBtnSkipClick(Sender: TObject);
    procedure rectThemeToggleClick(Sender: TObject);
    procedure rectBtnGameClick(Sender: TObject);
    procedure rectBtnPinClick(Sender: TObject);
    procedure rectBtnSoundClick(Sender: TObject);
    procedure rectBtnMinus5Click(Sender: TObject);
    procedure rectBtnMinus1Click(Sender: TObject);
    procedure rectBtnPlus1Click(Sender: TObject);
    procedure rectBtnPlus5Click(Sender: TObject);
    procedure rectBtnResetBasketClick(Sender: TObject);
    procedure lblCheerQuoteClick(Sender: TObject);
  private
    FCurrentMode: TTimerMode;
    FTimerState: TTimerState;
    FCurrentTheme: TAppTheme;
    FAlwaysOnTop: Boolean;
    FSoundEnabled: Boolean;
    FDailyGoalCount: Integer;
    FQuoteIndex: Integer;

    FTotalSeconds: Integer;
    FRemainingSeconds: Integer;
    FCompletedPomodoros: Integer;
    FTotalFocusMinutes: Integer;

    procedure InitAllControlsTextAndFont;
    procedure ApplyTheme(const ATheme: TAppTheme);
    procedure SetMode(const AMode: TTimerMode);
    procedure UpdateTimerDisplay;
    procedure UpdateProgressArc;
    procedure UpdateUIForState;
    procedure UpdateModeButtonStyles;
    procedure UpdateHarvestGarden;
    procedure CycleCheerQuote;
    procedure AdjustTime(const ADeltaSec: Integer);
    procedure OnTimerCompleted;
    procedure PlayMelodicFinishSound;
    procedure SaveData;
    procedure LoadData;

    function FormatTime(const ASec: Integer): string;
    function ModeDurationSeconds(const AMode: TTimerMode): Integer;
    function ModeAccentColor(const AMode: TTimerMode): TAlphaColor;
    function ModeDisplayName(const AMode: TTimerMode): string;
    function ModeBadgeName(const AMode: TTimerMode): string;
  public
  end;

var
  frmMain: TfrmMain;

implementation

uses
  GameForm;

{$R *.fmx}

const
  CHEERING_QUOTES: array[0..6] of string = (
    '천천히 가도 괜찮아요, 중요한 건 멈추지 않는 것 🌱',
    '작은 토마토 하나가 모여 풍성한 숲을 이뤄요 🌳',
    '오늘도 충분히 멋지게 잘하고 있어요, 토닥토닥 💖',
    '집중한 시간만큼 스스로가 더 단단해지고 있어요 ✨',
    '숨 한 번 깊게 들이쉬고, 차근차근 해봐요 🐾',
    '포기하지 않는 당신의 오늘이 가장 반짝여요 🌟',
    '한 걸음 한 걸음이 모여 멋진 내일이 돼요 🍓'
  );

{ ============================================================================ }
{ 모든 컨트롤 한글 폰트 및 텍스트 100% 안전 초기화                            }
{ ============================================================================ }

procedure TfrmMain.InitAllControlsTextAndFont;
var
  I: Integer;
begin
  // 1. 폼 내 모든 라벨에 맑은 고딕 강제 지정 및 시스템 스타일링 덮어쓰기 해제
  for I := 0 to ComponentCount - 1 do
  begin
    if Components[I] is TLabel then
    begin
      TLabel(Components[I]).StyledSettings := [];
      TLabel(Components[I]).TextSettings.Font.Family := 'Malgun Gothic';
    end;
  end;

  // 2. 폼 텍스트 명시적 한글 할당 (DFM 인코딩 변환 문제 완전 차단)
  Caption := '🍓 몽글몽글 뽀모도로 - Delphi 12.3';
  lblAppTitle.Text := '🍓 몽글몽글 뽀모도로';
  lblSubtitle.Text := '차근차근 나만의 작은 시간 ✨';

  lblBtnGame.Text := '🎮';
  lblBtnPin.Text := '📍';
  lblBtnSound.Text := '🔔';
  lblThemeToggle.Text := '☀️';

  lblGoalPrefix.Text := '✏️ 집중 목표:';
  edtFocusGoal.TextPrompt := '오늘 집중할 목표를 적어보세요 (예: 델파이 공부 💻)';

  lblModeWork.Text := '🍓 집중 25m';
  lblModeShortBreak.Text := '☕ 휴식 5m';
  lblModeLongBreak.Text := '🌴 긴휴식 15m';
  lblModeTest.Text := '⚡ 10초 슝';

  lblBtnMinus5.Text := '- 5분';
  lblBtnMinus1.Text := '- 1분';
  lblBtnPlus1.Text := '+ 1분';
  lblBtnPlus5.Text := '+ 5분';

  lblBtnReset.Text := '🔄 다시하기';
  lblBtnStart.Text := '▶ 시작하기';
  lblBtnSkip.Text := '⏭ 퐁당 넘김';

  lblStatsTitle.Text := '🧺 오늘의 뽀모 수확 바구니';
  lblBtnResetBasket.Text := '🧹 비우기';
  lblTotalFocusTime.Text := '누적 집중 시간: 🌱 0분 달성';
end;

{ ============================================================================ }
{ 폼 생성 및 초기화                                                            }
{ ============================================================================ }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  // 컨트롤 폰트 및 텍스트 한글 세팅
  InitAllControlsTextAndFont;

  // 기본 상태 변수 설정
  FCompletedPomodoros := 0;
  FTotalFocusMinutes := 0;
  FTimerState := tsIdle;
  FAlwaysOnTop := False;
  FSoundEnabled := True;
  FDailyGoalCount := 4; // 하루 목표: 4개 뽀모도로
  FQuoteIndex := 0;

  // 기본 테마 및 모드 적용
  ApplyTheme(thLight);
  SetMode(tmWork);

  // 로컬 영구 저장 데이터 로드
  LoadData;
  UpdateHarvestGarden;
  CycleCheerQuote;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // 앱 종료 시 데이터 자동 저장
  SaveData;
end;

{ ============================================================================ }
{ 데이터 영구 저장 및 복원 (INI 파일)                                          }
{ ============================================================================ }

procedure TfrmMain.SaveData;
var
  Ini: TIniFile;
  IniPath: string;
begin
  try
    IniPath := ChangeFileExt(ParamStr(0), '_data.ini');
    Ini := TIniFile.Create(IniPath);
    try
      Ini.WriteInteger('Stats', 'CompletedPomodoros', FCompletedPomodoros);
      Ini.WriteInteger('Stats', 'TotalFocusMinutes', FTotalFocusMinutes);
      Ini.WriteString('Goal', 'FocusGoalText', edtFocusGoal.Text);
      Ini.WriteBool('Settings', 'AlwaysOnTop', FAlwaysOnTop);
      Ini.WriteBool('Settings', 'SoundEnabled', FSoundEnabled);
      Ini.WriteInteger('Settings', 'Theme', Ord(FCurrentTheme));
    finally
      Ini.Free;
    end;
  except
    // 저장 실패 시 무시
  end;
end;

procedure TfrmMain.LoadData;
var
  Ini: TIniFile;
  IniPath: string;
  SavedTheme: Integer;
begin
  try
    IniPath := ChangeFileExt(ParamStr(0), '_data.ini');
    if not FileExists(IniPath) then Exit;

    Ini := TIniFile.Create(IniPath);
    try
      FCompletedPomodoros := Ini.ReadInteger('Stats', 'CompletedPomodoros', 0);
      FTotalFocusMinutes := Ini.ReadInteger('Stats', 'TotalFocusMinutes', 0);
      edtFocusGoal.Text := Ini.ReadString('Goal', 'FocusGoalText', '');
      FAlwaysOnTop := Ini.ReadBool('Settings', 'AlwaysOnTop', False);
      FSoundEnabled := Ini.ReadBool('Settings', 'SoundEnabled', True);
      SavedTheme := Ini.ReadInteger('Settings', 'Theme', 0);

      // 항상 위에 고정 복원
      if FAlwaysOnTop then
      begin
        FormStyle := TFormStyle.StayOnTop;
        lblBtnPin.Text := '📌';
      end
      else
      begin
        FormStyle := TFormStyle.Normal;
        lblBtnPin.Text := '📍';
      end;

      // 소리 토글 복원
      if FSoundEnabled then
        lblBtnSound.Text := '🔔'
      else
        lblBtnSound.Text := '🔕';

      ApplyTheme(TAppTheme(SavedTheme));
    finally
      Ini.Free;
    end;
  except
    // 로드 실패 시 기본값 유지
  end;
end;

{ ============================================================================ }
{ 키보드 단축키 지원 (Space, R, S, P, M)                                       }
{ ============================================================================ }

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  // 목표 입력 중일 때는 타이핑 방해 금지
  if edtFocusGoal.IsFocused then Exit;

  case Key of
    vkSpace:
      begin
        rectBtnStartClick(Self);
        Key := 0;
      end;
    Ord('R'), Ord('r'):
      begin
        rectBtnResetClick(Self);
        Key := 0;
      end;
    Ord('S'), Ord('s'):
      begin
        rectBtnSkipClick(Self);
        Key := 0;
      end;
    Ord('G'), Ord('g'):
      begin
        rectBtnGameClick(Self);
        Key := 0;
      end;
    Ord('P'), Ord('p'):
      begin
        rectBtnPinClick(Self);
        Key := 0;
      end;
    Ord('M'), Ord('m'):
      begin
        rectBtnSoundClick(Self);
        Key := 0;
      end;
  end;
end;

{ ============================================================================ }
{ 테마 전환 (크림 낮 / 밤하늘 라벤더)                                          }
{ ============================================================================ }

procedure TfrmMain.ApplyTheme(const ATheme: TAppTheme);
begin
  FCurrentTheme := ATheme;

  if FCurrentTheme = thLight then
  begin
    rectBackground.Fill.Color          := $FFFFFAF4; // 부드러운 우유빛 바닐라
    rectGoalCard.Fill.Color            := $FFFFFFFF;
    rectGoalCard.Stroke.Color          := $FFF2E2D6;
    rectModeBar.Fill.Color             := $FFFFFFFF;
    rectModeBar.Stroke.Color           := $FFF2E2D6;
    circleBack.Fill.Color              := $FFFFFFFF;
    arcBackground.Stroke.Color         := $FFFCE7EB;
    rectStats.Fill.Color               := $FFFFFFFF;
    rectStats.Stroke.Color             := $FFF2E2D6;

    rectBtnGame.Fill.Color             := $FFFFFFFF;
    rectBtnGame.Stroke.Color           := $FFF2E2D6;
    lblBtnGame.TextSettings.FontColor  := $FF4A3E3D;
    rectBtnPin.Fill.Color              := $FFFFFFFF;
    rectBtnPin.Stroke.Color            := $FFF2E2D6;
    rectBtnSound.Fill.Color            := $FFFFFFFF;
    rectBtnSound.Stroke.Color          := $FFF2E2D6;
    rectThemeToggle.Fill.Color         := $FFFFFFFF;
    rectThemeToggle.Stroke.Color       := $FFF2E2D6;
    lblThemeToggle.Text                := '☀️';

    rectBtnMinus5.Fill.Color           := $FFFFFFFF;
    rectBtnMinus5.Stroke.Color         := $FFF2E2D6;
    rectBtnMinus1.Fill.Color           := $FFFFFFFF;
    rectBtnMinus1.Stroke.Color         := $FFF2E2D6;
    rectBtnPlus1.Fill.Color            := $FFFFFFFF;
    rectBtnPlus1.Stroke.Color          := $FFF2E2D6;
    rectBtnPlus5.Fill.Color            := $FFFFFFFF;
    rectBtnPlus5.Stroke.Color          := $FFF2E2D6;

    rectBtnReset.Fill.Color            := $FFFFFFFF;
    rectBtnReset.Stroke.Color          := $FFF2E2D6;
    lblBtnReset.TextSettings.FontColor := $FF6B5B59;
    rectBtnSkip.Fill.Color             := $FFFFFFFF;
    rectBtnSkip.Stroke.Color           := $FFF2E2D6;
    lblBtnSkip.TextSettings.FontColor  := $FF6B5B59;

    rectGoalBarTrack.Fill.Color        := $FFF7F2EE;
    rectBtnResetBasket.Fill.Color      := $FFF7F2EE;
    lblBtnResetBasket.TextSettings.FontColor := $FF8C7A78;

    lblAppTitle.TextSettings.FontColor := $FF4A3E3D;
    lblSubtitle.TextSettings.FontColor := $FF8C7A78;
    lblGoalPrefix.TextSettings.FontColor := $FFFF758F;
    lblTimeDisplay.TextSettings.FontColor := $FF4A3E3D;
    lblStatusMessage.TextSettings.FontColor := $FF8C7A78;
    lblCheerQuote.TextSettings.FontColor := $FFA6928F;
    lblStatsTitle.TextSettings.FontColor := $FFFF758F;
    lblHarvestIcons.TextSettings.FontColor := $FF4A3E3D;
    lblGoalText.TextSettings.FontColor := $FF6B5B59;
    lblTotalFocusTime.TextSettings.FontColor := $FF8C7A78;
  end
  else
  begin
    rectBackground.Fill.Color          := $FF2B2438; // 몽환적인 밤하늘
    rectGoalCard.Fill.Color            := $FF383049;
    rectGoalCard.Stroke.Color          := $FF4F4466;
    rectModeBar.Fill.Color             := $FF383049;
    rectModeBar.Stroke.Color           := $FF4F4466;
    circleBack.Fill.Color              := $FF241E30;
    arcBackground.Stroke.Color         := $FF423854;
    rectStats.Fill.Color               := $FF383049;
    rectStats.Stroke.Color             := $FF4F4466;

    rectBtnGame.Fill.Color             := $FF383049;
    rectBtnGame.Stroke.Color           := $FF4F4466;
    lblBtnGame.TextSettings.FontColor  := $FFFFF5EA;
    rectBtnPin.Fill.Color              := $FF383049;
    rectBtnPin.Stroke.Color            := $FF4F4466;
    rectBtnSound.Fill.Color            := $FF383049;
    rectBtnSound.Stroke.Color          := $FF4F4466;
    rectThemeToggle.Fill.Color         := $FF383049;
    rectThemeToggle.Stroke.Color       := $FF4F4466;
    lblThemeToggle.Text                := '🌙';

    rectBtnMinus5.Fill.Color           := $FF383049;
    rectBtnMinus5.Stroke.Color         := $FF4F4466;
    rectBtnMinus1.Fill.Color           := $FF383049;
    rectBtnMinus1.Stroke.Color         := $FF4F4466;
    rectBtnPlus1.Fill.Color            := $FF383049;
    rectBtnPlus1.Stroke.Color          := $FF4F4466;
    rectBtnPlus5.Fill.Color            := $FF383049;
    rectBtnPlus5.Stroke.Color          := $FF4F4466;

    rectBtnReset.Fill.Color            := $FF383049;
    rectBtnReset.Stroke.Color          := $FF4F4466;
    lblBtnReset.TextSettings.FontColor := $FFD1C8E0;
    rectBtnSkip.Fill.Color             := $FF383049;
    rectBtnSkip.Stroke.Color           := $FF4F4466;
    lblBtnSkip.TextSettings.FontColor  := $FFD1C8E0;

    rectGoalBarTrack.Fill.Color        := $FF423854;
    rectBtnResetBasket.Fill.Color      := $FF423854;
    lblBtnResetBasket.TextSettings.FontColor := $FFB8AEC8;

    lblAppTitle.TextSettings.FontColor := $FFFFF5EA;
    lblSubtitle.TextSettings.FontColor := $FFB8AEC8;
    lblGoalPrefix.TextSettings.FontColor := $FFFF8FA3;
    lblTimeDisplay.TextSettings.FontColor := $FFFFF5EA;
    lblStatusMessage.TextSettings.FontColor := $FFB8AEC8;
    lblCheerQuote.TextSettings.FontColor := $FF9F94B0;
    lblStatsTitle.TextSettings.FontColor := $FFFF8FA3;
    lblHarvestIcons.TextSettings.FontColor := $FFFFF5EA;
    lblGoalText.TextSettings.FontColor := $FFD1C8E0;
    lblTotalFocusTime.TextSettings.FontColor := $FFB8AEC8;
  end;

  UpdateModeButtonStyles;
  UpdateProgressArc;
  UpdateHarvestGarden;
end;

procedure TfrmMain.rectThemeToggleClick(Sender: TObject);
begin
  if FCurrentTheme = thLight then
    ApplyTheme(thDark)
  else
    ApplyTheme(thLight);
  SaveData;
end;

{ ============================================================================ }
{ 뽀모 서바이벌 미니게임 실행 (Vampire Survivors 스타일 로그라이크)              }
{ ============================================================================ }

procedure TfrmMain.rectBtnGameClick(Sender: TObject);
begin
  if Assigned(frmGame) then
    frmGame.StartGameSession;
end;

{ ============================================================================ }
{ 기능 1: 항상 위에 표시 (Always on Top)                                       }
{ ============================================================================ }

procedure TfrmMain.rectBtnPinClick(Sender: TObject);
begin
  FAlwaysOnTop := not FAlwaysOnTop;
  if FAlwaysOnTop then
  begin
    FormStyle := TFormStyle.StayOnTop;
    lblBtnPin.Text := '📌';
  end
  else
  begin
    FormStyle := TFormStyle.Normal;
    lblBtnPin.Text := '📍';
  end;
  SaveData;
end;

{ ============================================================================ }
{ 기능 2: 사운드 토글 & 상큼한 4음 팡파레 멜로디                               }
{ ============================================================================ }

procedure TfrmMain.rectBtnSoundClick(Sender: TObject);
begin
  FSoundEnabled := not FSoundEnabled;
  if FSoundEnabled then
  begin
    lblBtnSound.Text := '🔔';
    PlayMelodicFinishSound;
  end
  else
  begin
    lblBtnSound.Text := '🔕';
  end;
  SaveData;
end;

procedure TfrmMain.PlayMelodicFinishSound;
begin
  {$IFDEF MSWINDOWS}
  if not FSoundEnabled then Exit;

  // 비동기 스레드로 재생되는 경쾌한 4음 멜로디 (도 - 미 - 솔 - 높은 도)
  TThread.CreateAnonymousThread(
    procedure
    begin
      Winapi.Windows.Beep(523, 110); // C5
      Sleep(35);
      Winapi.Windows.Beep(659, 110); // E5
      Sleep(35);
      Winapi.Windows.Beep(784, 130); // G5
      Sleep(35);
      Winapi.Windows.Beep(1046, 260); // C6
    end
  ).Start;
  {$ENDIF}
end;

{ ============================================================================ }
{ 기능 3: 퀵 시간 조절 (-5분, -1분, +1분, +5분)                                }
{ ============================================================================ }

procedure TfrmMain.AdjustTime(const ADeltaSec: Integer);
begin
  Inc(FRemainingSeconds, ADeltaSec);
  if FRemainingSeconds < 5 then
    FRemainingSeconds := 5; // 최소 5초

  if FRemainingSeconds > FTotalSeconds then
    FTotalSeconds := FRemainingSeconds;

  UpdateTimerDisplay;
  UpdateProgressArc;
end;

procedure TfrmMain.rectBtnMinus5Click(Sender: TObject);
begin
  AdjustTime(-5 * 60);
end;

procedure TfrmMain.rectBtnMinus1Click(Sender: TObject);
begin
  AdjustTime(-1 * 60);
end;

procedure TfrmMain.rectBtnPlus1Click(Sender: TObject);
begin
  AdjustTime(1 * 60);
end;

procedure TfrmMain.rectBtnPlus5Click(Sender: TObject);
begin
  AdjustTime(5 * 60);
end;

{ ============================================================================ }
{ 기능 4 & 5: 시각적 토마토 농장 & 일일 목표 달성도 게이지                     }
{ ============================================================================ }

procedure TfrmMain.UpdateHarvestGarden;
var
  I: Integer;
  HarvestStr: string;
  Percent: Integer;
  GoalRatio: Single;
begin
  // 1. 실제 수확된 토마토 이모지 나열
  if FCompletedPomodoros = 0 then
    HarvestStr := '바구니가 아직 비어있어요. 첫 수확을 향해 달려볼까요? 🌱'
  else
  begin
    HarvestStr := '';
    for I := 1 to FCompletedPomodoros do
    begin
      HarvestStr := HarvestStr + '🍅 ';
      if (I mod 10 = 0) and (I < FCompletedPomodoros) then
        HarvestStr := HarvestStr + sLineBreak;
    end;
  end;
  lblHarvestIcons.Text := HarvestStr;

  // 2. 일일 목표 달성도 퍼센티지 계산
  if FDailyGoalCount > 0 then
    Percent := Round((FCompletedPomodoros / FDailyGoalCount) * 100)
  else
    Percent := 0;

  if FCompletedPomodoros >= FDailyGoalCount then
    lblGoalText.Text := Format('🎉 오늘의 목표 달성 완료! (%d개 완수, %d%%)', [FCompletedPomodoros, Percent])
  else
    lblGoalText.Text := Format('오늘의 목표: %d개 중 %d개 수확 달성 (%d%%)', [FDailyGoalCount, FCompletedPomodoros, Percent]);

  // 3. 프로그레스 바 너비 조절
  if FDailyGoalCount > 0 then
    GoalRatio := FCompletedPomodoros / FDailyGoalCount
  else
    GoalRatio := 0.0;

  if GoalRatio > 1.0 then GoalRatio := 1.0;
  rectGoalBarFill.Width := rectGoalBarTrack.Width * GoalRatio;
  rectGoalBarFill.Fill.Color := ModeAccentColor(tmWork);

  // 4. 누적 집중 시간 텍스트
  lblTotalFocusTime.Text := Format('누적 집중 시간: 🌱 %d분 달성', [FTotalFocusMinutes]);
end;

procedure TfrmMain.rectBtnResetBasketClick(Sender: TObject);
begin
  if TDialogServiceSync.MessageDialog(
    '🧺 오늘 수확한 토마토 바구니와 집중 시간을 초기화할까요?',
    TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
    TMsgDlgBtn.mbNo,
    0
  ) = mrYes then
  begin
    FCompletedPomodoros := 0;
    FTotalFocusMinutes := 0;
    UpdateHarvestGarden;
    SaveData;
  end;
end;

{ ============================================================================ }
{ 기능 6: 포근한 힐링 응원 문구 롤링                                           }
{ ============================================================================ }

procedure TfrmMain.CycleCheerQuote;
begin
  lblCheerQuote.Text := CHEERING_QUOTES[FQuoteIndex];
  Inc(FQuoteIndex);
  if FQuoteIndex > High(CHEERING_QUOTES) then
    FQuoteIndex := 0;
end;

procedure TfrmMain.lblCheerQuoteClick(Sender: TObject);
begin
  CycleCheerQuote;
end;

{ ============================================================================ }
{ 모드별 속성 및 포근한 파스텔 색상 정의                                       }
{ ============================================================================ }

function TfrmMain.ModeDurationSeconds(const AMode: TTimerMode): Integer;
begin
  case AMode of
    tmWork:       Result := 25 * 60;
    tmShortBreak: Result := 5 * 60;
    tmLongBreak:  Result := 15 * 60;
    tmTest:       Result := 10;
  else
    Result := 25 * 60;
  end;
end;

function TfrmMain.ModeAccentColor(const AMode: TTimerMode): TAlphaColor;
begin
  case AMode of
    tmWork:       Result := $FFFF758F; // 사랑스러운 스트로베리 핑크
    tmShortBreak: Result := $FF52B788; // 싱그러운 피스타치오 민트
    tmLongBreak:  Result := $FF7B7CDB; // 몽환적인 라벤더 블루
    tmTest:       Result := $FFE09F3E; // 달콤한 바나나 버터 옐로우
  else
    Result := $FFFF758F;
  end;
end;

function TfrmMain.ModeDisplayName(const AMode: TTimerMode): string;
begin
  case AMode of
    tmWork:       Result := '🍓 집중 시간';
    tmShortBreak: Result := '☕ 차 한잔 휴식';
    tmLongBreak:  Result := '🌴 꿀휴식';
    tmTest:       Result := '⚡ 10초 슝';
  else
    Result := '';
  end;
end;

function TfrmMain.ModeBadgeName(const AMode: TTimerMode): string;
begin
  case AMode of
    tmWork:       Result := '♥ 몰입할 시간이에요';
    tmShortBreak: Result := '☕ 기지개 펴고 꿀휴식';
    tmLongBreak:  Result := '🌴 포근하게 푹 쉬어요';
    tmTest:       Result := '⚡ 10초 슝! 테스트';
  else
    Result := '';
  end;
end;

procedure TfrmMain.SetMode(const AMode: TTimerMode);
begin
  TimerTick.Enabled := False;
  FTimerState := tsIdle;

  FCurrentMode := AMode;
  FTotalSeconds := ModeDurationSeconds(AMode);
  FRemainingSeconds := FTotalSeconds;

  UpdateModeButtonStyles;
  UpdateTimerDisplay;
  UpdateProgressArc;
  UpdateUIForState;
end;

procedure TfrmMain.UpdateModeButtonStyles;
var
  ColInactiveFill, ColInactiveText: TAlphaColor;
begin
  if FCurrentTheme = thLight then
  begin
    ColInactiveFill := $FFF7F2EE;
    ColInactiveText := $FF8C7A78;
  end
  else
  begin
    ColInactiveFill := $FF383049;
    ColInactiveText := $FFB8AEC8;
  end;

  rectModeWork.Fill.Color := ColInactiveFill;
  lblModeWork.TextSettings.FontColor := ColInactiveText;
  lblModeWork.TextSettings.Font.Style := [];

  rectModeShortBreak.Fill.Color := ColInactiveFill;
  lblModeShortBreak.TextSettings.FontColor := ColInactiveText;
  lblModeShortBreak.TextSettings.Font.Style := [];

  rectModeLongBreak.Fill.Color := ColInactiveFill;
  lblModeLongBreak.TextSettings.FontColor := ColInactiveText;
  lblModeLongBreak.TextSettings.Font.Style := [];

  rectModeTest.Fill.Color := ColInactiveFill;
  lblModeTest.TextSettings.FontColor := ColInactiveText;
  lblModeTest.TextSettings.Font.Style := [];

  case FCurrentMode of
    tmWork:
      begin
        rectModeWork.Fill.Color := ModeAccentColor(tmWork);
        lblModeWork.TextSettings.FontColor := $FFFFFFFF;
        lblModeWork.TextSettings.Font.Style := [TFontStyle.fsBold];
      end;
    tmShortBreak:
      begin
        rectModeShortBreak.Fill.Color := ModeAccentColor(tmShortBreak);
        lblModeShortBreak.TextSettings.FontColor := $FFFFFFFF;
        lblModeShortBreak.TextSettings.Font.Style := [TFontStyle.fsBold];
      end;
    tmLongBreak:
      begin
        rectModeLongBreak.Fill.Color := ModeAccentColor(tmLongBreak);
        lblModeLongBreak.TextSettings.FontColor := $FFFFFFFF;
        lblModeLongBreak.TextSettings.Font.Style := [TFontStyle.fsBold];
      end;
    tmTest:
      begin
        rectModeTest.Fill.Color := ModeAccentColor(tmTest);
        lblModeTest.TextSettings.FontColor := $FFFFFFFF;
        lblModeTest.TextSettings.Font.Style := [TFontStyle.fsBold];
      end;
  end;

  rectBtnStart.Fill.Color := ModeAccentColor(FCurrentMode);
  lblBtnStart.TextSettings.FontColor := $FFFFFFFF;

  lblModeBadge.Text := ModeBadgeName(FCurrentMode);
  lblModeBadge.TextSettings.FontColor := ModeAccentColor(FCurrentMode);
end;

function TfrmMain.FormatTime(const ASec: Integer): string;
var
  Min, Sec: Integer;
begin
  Min := ASec div 60;
  Sec := ASec mod 60;
  Result := Format('%.2d:%.2d', [Min, Sec]);
end;

{ ============================================================================ }
{ 화면 렌더링 및 UI 업데이트                                                   }
{ ============================================================================ }

procedure TfrmMain.UpdateTimerDisplay;
var
  GoalPrefix: string;
begin
  lblTimeDisplay.Text := FormatTime(FRemainingSeconds);

  if Trim(edtFocusGoal.Text) <> '' then
    GoalPrefix := '[' + Trim(edtFocusGoal.Text) + '] '
  else
    GoalPrefix := '';

  Caption := Format('%s[%s] %s - 몽글몽글 뽀모도로', [GoalPrefix, lblTimeDisplay.Text, ModeDisplayName(FCurrentMode)]);
end;

procedure TfrmMain.UpdateProgressArc;
var
  Ratio: Single;
begin
  if FTotalSeconds > 0 then
    Ratio := FRemainingSeconds / FTotalSeconds
  else
    Ratio := 0.0;

  arcProgress.EndAngle := 360.0 * Ratio;
  arcProgress.Stroke.Color := ModeAccentColor(FCurrentMode);
end;

procedure TfrmMain.UpdateUIForState;
begin
  case FTimerState of
    tsIdle:
      begin
        lblBtnStart.Text := '▶ 시작하기';
        lblStatusMessage.Text := '시작 버튼을 톡 눌러주세요 ✨';
        rectBtnReset.Opacity := 0.45;
        rectBtnReset.HitTest := False;
        rectBtnSkip.Opacity := 1.0;
        rectBtnSkip.HitTest := True;
      end;
    tsRunning:
      begin
        lblBtnStart.Text := '⏸ 잠깐 멈춤';
        if FCurrentMode in [tmWork, tmTest] then
        begin
          if Trim(edtFocusGoal.Text) <> '' then
            lblStatusMessage.Text := Format('"%s" 몰입 중! 파이팅 🍓', [Trim(edtFocusGoal.Text)])
          else
            lblStatusMessage.Text := '포근하게 집중해볼까요? 파이팅 🍓';
        end
        else
          lblStatusMessage.Text := '기지개 펴고 차 한잔 마셔요 ☕';
        rectBtnReset.Opacity := 1.0;
        rectBtnReset.HitTest := True;
        rectBtnSkip.Opacity := 1.0;
        rectBtnSkip.HitTest := True;
      end;
    tsPaused:
      begin
        lblBtnStart.Text := '▶ 다시 시작';
        lblStatusMessage.Text := '잠깐 숨 고르는 중... ☕';
        rectBtnReset.Opacity := 1.0;
        rectBtnReset.HitTest := True;
        rectBtnSkip.Opacity := 1.0;
        rectBtnSkip.HitTest := True;
      end;
  end;
end;

{ ============================================================================ }
{ 타이머 완료 처리                                                             }
{ ============================================================================ }

procedure TfrmMain.OnTimerCompleted;
var
  CompletedMsg: string;
  TaskDoneMsg: string;
begin
  TimerTick.Enabled := False;
  FTimerState := tsIdle;
  PlayMelodicFinishSound;

  if FCurrentMode in [tmWork, tmTest] then
  begin
    Inc(FCompletedPomodoros);
    Inc(FTotalFocusMinutes, FTotalSeconds div 60);

    if Trim(edtFocusGoal.Text) <> '' then
      TaskDoneMsg := Format('목표 "%s" 완수!', [Trim(edtFocusGoal.Text)])
    else
      TaskDoneMsg := '멋진 집중 세션 완수!';

    CompletedMsg := Format(
      '🎉 퐁당! %s' + sLineBreak +
      '바구니에 담긴 토마토: 🍅 %d개' + sLineBreak + sLineBreak +
      '달콤한 차 한 잔 마시며 쉬어갈까요? ☕',
      [TaskDoneMsg, FCompletedPomodoros]
    );

    UpdateUIForState;
    UpdateHarvestGarden;
    CycleCheerQuote;
    SaveData;

    if TDialogServiceSync.MessageDialog(CompletedMsg, TMsgDlgType.mtInformation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbYes, 0) = mrYes then
    begin
      if (FCompletedPomodoros mod 4) = 0 then
        SetMode(tmLongBreak)
      else
        SetMode(tmShortBreak);
      Exit;
    end;
  end
  else
  begin
    TDialogServiceSync.ShowMessage('✨ 푹 쉬었나요? 다시 씩씩하게 시작해봐요! 🍓');
    SetMode(tmWork);
    CycleCheerQuote;
    Exit;
  end;

  UpdateUIForState;
end;

{ ============================================================================ }
{ 타이머 틱(1초 주기) 이벤트                                                   }
{ ============================================================================ }

procedure TfrmMain.TimerTickTimer(Sender: TObject);
begin
  if FRemainingSeconds > 0 then
  begin
    Dec(FRemainingSeconds);
    UpdateTimerDisplay;
    UpdateProgressArc;
  end;

  if FRemainingSeconds <= 0 then
  begin
    OnTimerCompleted;
  end;
end;

{ ============================================================================ }
{ 컨트롤 버튼 핸들러                                                           }
{ ============================================================================ }

procedure TfrmMain.rectBtnStartClick(Sender: TObject);
begin
  case FTimerState of
    tsIdle, tsPaused:
      begin
        FTimerState := tsRunning;
        TimerTick.Enabled := True;
      end;
    tsRunning:
      begin
        FTimerState := tsPaused;
        TimerTick.Enabled := False;
      end;
  end;

  UpdateUIForState;
end;

procedure TfrmMain.rectBtnResetClick(Sender: TObject);
begin
  TimerTick.Enabled := False;
  FTimerState := tsIdle;
  FRemainingSeconds := FTotalSeconds;

  UpdateTimerDisplay;
  UpdateProgressArc;
  UpdateUIForState;
end;

procedure TfrmMain.rectBtnSkipClick(Sender: TObject);
begin
  if FCurrentMode in [tmWork, tmTest] then
    SetMode(tmShortBreak)
  else
    SetMode(tmWork);
end;

procedure TfrmMain.rectModeWorkClick(Sender: TObject);
begin
  SetMode(tmWork);
end;

procedure TfrmMain.rectModeShortBreakClick(Sender: TObject);
begin
  SetMode(tmShortBreak);
end;

procedure TfrmMain.rectModeLongBreakClick(Sender: TObject);
begin
  SetMode(tmLongBreak);
end;

procedure TfrmMain.rectModeTestClick(Sender: TObject);
begin
  SetMode(tmTest);
end;

end.
