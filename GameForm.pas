unit GameForm;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Math,
  System.IniFiles,
  System.Diagnostics,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Layouts
  {$IFDEF MSWINDOWS}
  , Winapi.Windows, FMX.Controls.Presentation
  {$ENDIF}
  ;

type
  // 게임 진행 상태
  TGameState = (gsReady, gsPlaying, gsPaused, gsLevelUp, gsGameOver);

  // 캐릭터 종류 (4종 디저트 영웅)
  TCharacterType = (ctStrawberry, ctEspresso, ctBunny, ctTomato);

  // 로그라이크 업그레이드 스킬 종류 (기본 8종 + 최종 진화 4종)
  TUpgradeType = (
    utSeedCount,          // 🍓 씨앗 뿅뿅포 (+1개 발사)
    utAttackSpeed,        // ⚡ 공격 속도 (+20% 가속)
    utOrbitStrawberry,    // 🪐 가디언 딸기 위성 (+1개 추가)
    utCoffeePulse,        // ☕ 에스프레소 파동 (360도 넉백 충격파)
    utVitaminZap,         // ⚡ 비타민 번개 (적 정밀 타격)
    utMoveSpeed,          // 👟 푹신한 토끼 덧신 (+15% 이동속도)
    utMaxHPHeal,          // 💖 딸기 조각 케이크 (최대 체력 +25 & 즉시 회복)
    utMagnetRadius,       // 🧲 달콤한 자석 (보석 흡수 범위 +40%)
    utEvoSeedGatling,     // ✨🍓 [진화] 메가 딸기 개틀링 (폭풍 탄막 연사)
    utEvoGalacticOrbit,   // ✨🪐 [진화] 은하계 딸기 결계 (초거대 분쇄 궤도)
    utEvoDarkRoast,       // ✨☕ [진화] 다크 로스트 허리케인 (화면 광역 흡입 넉백)
    utEvoPlasmaZap        // ✨⚡ [진화] 메가 비타민 플라즈마 (연쇄 벼락 폭풍)
  );

  TUpgradeOption = record
    UpgradeType: TUpgradeType;
    Icon: string;
    Title: string;
    Desc: string;
    Badge: string;
  end;

  // 적 몬스터 종류 (몰려오는 잡생각들)
  TEnemyType = (etDust, etSleepy, etPhone, etBoss);

  TEnemy = record
    Active: Boolean;
    X, Y: Single;
    Radius: Single;
    Speed: Single;
    HP, MaxHP: Single;
    EnemyType: TEnemyType;
    Damage: Single;
    FlashTimer: Single;
  end;

  // 투사체 (씨앗 총알 등)
  TProjectile = record
    Active: Boolean;
    X, Y: Single;
    VX, VY: Single;
    Radius: Single;
    LifeTime: Single;
    Damage: Single;
    Pierce: Integer;
  end;

  // 경험치 보석 / 아이템 (보석, 케이크, 자석, 토마토 폭탄, 황금 보물상자)
  TGemType = (gtGreen, gtBlue, gtPink, gtCake, gtMagnet, gtBomb, gtChest);

  TGem = record
    Active: Boolean;
    X, Y: Single;
    Radius: Single;
    ExpValue: Integer;
    GemType: TGemType;
  end;

  // 대미지 텍스트 팝업
  TFloatingText = record
    Active: Boolean;
    X, Y: Single;
    Text: string;
    Color: TAlphaColor;
    LifeTime: Single;
    MaxLife: Single;
  end;

  // 파티클
  TParticle = record
    Active: Boolean;
    X, Y: Single;
    VX, VY: Single;
    LifeTime: Single;
    MaxLife: Single;
    Color: TAlphaColor;
    Size: Single;
  end;

  TfrmGame = class(TForm)
    rectRoot: TRectangle;
    pbGame: TPaintBox;
    lytTopHUD: TLayout;
    rectExpTrack: TRectangle;
    rectExpFill: TRectangle;
    lytHUDLabels: TLayout;
    lblLevelBadge: TLabel;
    lblSurvivalTime: TLabel;
    lblKillScore: TLabel;
    rectBtnPause: TRectangle;
    lblBtnPause: TLabel;
    rectBtnCloseGame: TRectangle;
    lblBtnCloseGame: TLabel;

    // 레벨업 모달 UI
    lytLevelUpModal: TLayout;
    rectLevelUpDim: TRectangle;
    rectLevelUpBox: TRectangle;
    lblLevelUpTitle: TLabel;
    lblLevelUpSubtitle: TLabel;

    rectCard1: TRectangle;
    lblCardIcon1: TLabel;
    lblCardTitle1: TLabel;
    lblCardBadge1: TLabel;
    lblCardDesc1: TLabel;

    rectCard2: TRectangle;
    lblCardIcon2: TLabel;
    lblCardTitle2: TLabel;
    lblCardBadge2: TLabel;
    lblCardDesc2: TLabel;

    rectCard3: TRectangle;
    lblCardIcon3: TLabel;
    lblCardTitle3: TLabel;
    lblCardBadge3: TLabel;
    lblCardDesc3: TLabel;

    // 게임오버 모달 UI
    lytGameOverModal: TLayout;
    rectGameOverDim: TRectangle;
    rectGameOverBox: TRectangle;
    lblGameOverTitle: TLabel;
    lblGameOverStats: TLabel;
    lblGameOverBest: TLabel;
    rectBtnRestart: TRectangle;
    lblBtnRestart: TLabel;
    rectBtnReturnTimer: TRectangle;
    lblBtnReturnTimer: TLabel;

    GameTimer: TTimer;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure GameTimerTick(Sender: TObject);
    procedure pbGamePaint(Sender: TObject; Canvas: TCanvas);
    procedure pbGameMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure pbGameMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);

    procedure rectBtnPauseClick(Sender: TObject);
    procedure rectBtnCloseGameClick(Sender: TObject);
    procedure rectCard1Click(Sender: TObject);
    procedure rectCard2Click(Sender: TObject);
    procedure rectCard3Click(Sender: TObject);
    procedure rectBtnRestartClick(Sender: TObject);
    procedure rectBtnReturnTimerClick(Sender: TObject);
  private
    FGameState: TGameState;

    // 플레이어 스탯
    FPlayerX, FPlayerY: Single;
    FPlayerRadius: Single;
    FPlayerHP, FPlayerMaxHP: Single;
    FPlayerSpeed: Single;
    FPlayerLevel: Integer;
    FPlayerEXP, FPlayerNextEXP: Single;
    FKills: Integer;
    FSurvivalSeconds: Single;
    FInvincibleTimer: Single;

    // 입력 상태
    FKeyLeft, FKeyRight, FKeyUp, FKeyDown: Boolean;
    FMouseControlActive: Boolean;
    FMouseTargetX, FMouseTargetY: Single;

    // 뱀파이어 서바이벌 무기 및 스킬 레벨
    FSeedLevel: Integer;        // 씨앗 발사 레벨
    FSeedCooldownTimer: Single;
    FOrbitLevel: Integer;       // 가디언 딸기 위성 레벨
    FOrbitAngle: Single;
    FCoffeeLevel: Integer;      // 에스프레소 파동 레벨
    FCoffeeCooldownTimer: Single;
    FCoffeeWaveRadius: Single;  // 시각 효과용
    FCoffeeWaveActive: Boolean;
    FVitaminLevel: Integer;     // 비타민 번개 레벨
    FVitaminCooldownTimer: Single;
    FMoveSpeedLevel: Integer;
    FMaxHPLevel: Integer;
    FMagnetLevel: Integer;
    FAttackSpeedLevel: Integer;
    FAttackSpeedMultiplier: Single;

    // 최종 무기 진화 (Evolved Weapons) 플래그
    FSeedEvolved: Boolean;
    FOrbitEvolved: Boolean;
    FCoffeeEvolved: Boolean;
    FVitaminEvolved: Boolean;

    // 캐릭터 & 뽀모도로 수확 연동 & 부활
    FSelectedChar: TCharacterType;
    FTomatoHarvestCount: Integer;
    FHasRevive: Boolean;
    FReviveUsed: Boolean;

    // 딸기 대시 (Dash) 시스템
    FDashTimer: Single;
    FDashCooldownTimer: Single;
    FDashMaxCooldown: Single;

    // 엔티티 풀 (대량 몬스터 서바이벌 웨이브를 위한 대폭 확장)
    FEnemies: array[0..399] of TEnemy;
    FProjectiles: array[0..199] of TProjectile;
    FGems: array[0..499] of TGem;
    FFloatingTexts: array[0..59] of TFloatingText;
    FParticles: array[0..119] of TParticle;

    // 레벨업 옵션
    FCardOptions: array[1..3] of TUpgradeOption;

    // 스테이지 및 보스 관리
    FStage: Integer;
    FStageKills: Integer;
    FStageTargetKills: Integer;
    FBossActive: Boolean;
    FBossSpawnedThisStage: Boolean;

    // 스폰 타이머 & 대규모 웨이브 관리
    FSpawnTimer: Single;
    FLastWaveTriggerSec: Integer;

    // 최고 기록
    FBestSurvivalSeconds: Integer;
    FBestKills: Integer;
    FBestLevel: Integer;
    FBestStage: Integer;

    // 초정밀 프레임 타이머 및 HUD 갱신 캐시
    FStopwatch: TStopwatch;
    FLastDisplaySec: Integer;
    FLastDisplayKills: Integer;
    FLastDisplayHP: Integer;
    FLastDisplayLevel: Integer;
    FLastDisplayStage: Integer;
    FLastDisplayStageKills: Integer;
    FLastDisplayBossActive: Boolean;

    procedure InitAllControlsTextAndFont;
    procedure UpdateHUDLabels;
    procedure StartNewGame;
    procedure UpdateGame(const DT: Single);
    procedure SpawnEnemy(const AType: TEnemyType);
    procedure SpawnEnemiesBatch(const ACount: Integer; const AType: TEnemyType);
    procedure FireSeedGun;
    procedure TriggerCoffeePulse;
    procedure TriggerVitaminZap;
    procedure PerformDash;
    procedure TriggerTomatoBomb;
    procedure OpenTreasureChest;
    procedure SelectCharacter(const AChar: TCharacterType);
    procedure LoadPomodoroHarvestData;
    procedure AddGem(const X, Y: Single; const AType: TGemType; const AExp: Integer);
    procedure AddFloatingText(const X, Y: Single; const AText: string; const ACol: TAlphaColor);
    procedure AddParticles(const X, Y: Single; const ACol: TAlphaColor; const ACount: Integer);
    procedure CheckLevelUp;
    procedure ShowLevelUpModal;
    procedure ApplyUpgrade(const AType: TUpgradeType);
    procedure OnGameOver;
    procedure PlaySoundBeep(const AFreq, ADur: Cardinal);
    procedure LoadBestScores;
    procedure SaveBestScores;
  public
    procedure StartGameSession;
  end;

var
  frmGame: TfrmGame;

implementation

{$R *.fmx}

{$IFDEF MSWINDOWS}
function timeBeginPeriod(uPeriod: Cardinal): Cardinal; stdcall; external 'winmm.dll';
function timeEndPeriod(uPeriod: Cardinal): Cardinal; stdcall; external 'winmm.dll';
{$ENDIF}

{ ============================================================================ }
{ 폼 초기화 및 폰트 강제 지정                                                 }
{ ============================================================================ }

procedure TfrmGame.FormCreate(Sender: TObject);
begin
  Randomize;
  {$IFDEF MSWINDOWS}
  timeBeginPeriod(1); // 윈도우 OS 스케줄러를 1ms 초정밀 모드로 전환
  {$ENDIF}
  InitAllControlsTextAndFont;
  LoadBestScores;
  FGameState := gsReady;
end;

procedure TfrmGame.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  GameTimer.Enabled := False;
  {$IFDEF MSWINDOWS}
  timeEndPeriod(1);
  {$ENDIF}
  SaveBestScores;
end;

procedure TfrmGame.InitAllControlsTextAndFont;
var
  I: Integer;
begin
  Caption := '🍓 몽글몽글 뽀모 서바이벌 (Pomo Survivors)';

  for I := 0 to ComponentCount - 1 do
  begin
    if Components[I] is TLabel then
    begin
      TLabel(Components[I]).StyledSettings := [];
      TLabel(Components[I]).TextSettings.Font.Family := 'Malgun Gothic';
    end;
  end;

  // 카드 자식 라벨들이 클릭 이벤트를 가로채지 못하도록 HitTest := False 강제 지정
  lblCardIcon1.HitTest := False;
  lblCardTitle1.HitTest := False;
  lblCardBadge1.HitTest := False;
  lblCardDesc1.HitTest := False;

  lblCardIcon2.HitTest := False;
  lblCardTitle2.HitTest := False;
  lblCardBadge2.HitTest := False;
  lblCardDesc2.HitTest := False;

  lblCardIcon3.HitTest := False;
  lblCardTitle3.HitTest := False;
  lblCardBadge3.HitTest := False;
  lblCardDesc3.HitTest := False;

  lblLevelBadge.Text := 'Lv.1 🌱  💖 100/100';
  lblSurvivalTime.Text := '00:00';
  lblKillScore.Text := '👾 0마리';
  lblBtnPause.Text := '⏸';
  lblBtnCloseGame.Text := '✕';

  lblLevelUpTitle.Text := '✨ 레벨 업! 보너스 선택 ✨';
  lblLevelUpSubtitle.Text := '방해꾼들을 물리칠 귀여운 스킬을 하나 골라주세요!';

  lblGameOverTitle.Text := '🍓 뽀모 서바이벌 세션 완료!';
  lblBtnRestart.Text := '🔄 다시 도전하기';
  lblBtnReturnTimer.Text := '🍓 타이머로 돌아가기';
end;

procedure TfrmGame.UpdateHUDLabels;
var
  CurHP: Integer;
  ReviveStr, CharIcon: string;
begin
  CurHP := Max(0, Round(FPlayerHP));
  if FHasRevive and (not FReviveUsed) then
    ReviveStr := ' 👼'
  else
    ReviveStr := '';

  case FSelectedChar of
    ctStrawberry: CharIcon := '🍓';
    ctEspresso:   CharIcon := '☕';
    ctBunny:      CharIcon := '🐰';
    ctTomato:     CharIcon := '🍅';
  end;

  if (FPlayerLevel <> FLastDisplayLevel) or (CurHP <> FLastDisplayHP) then
  begin
    FLastDisplayLevel := FPlayerLevel;
    FLastDisplayHP := CurHP;
    lblLevelBadge.Text := Format('%s Lv.%d 💖 %d/%d%s', [CharIcon, FPlayerLevel, CurHP, Round(FPlayerMaxHP), ReviveStr]);
  end;

  if (FKills <> FLastDisplayKills) or (FStage <> FLastDisplayStage) or
     (FStageKills <> FLastDisplayStageKills) or (FBossActive <> FLastDisplayBossActive) then
  begin
    FLastDisplayKills := FKills;
    FLastDisplayStage := FStage;
    FLastDisplayStageKills := FStageKills;
    FLastDisplayBossActive := FBossActive;

    if FBossActive then
      lblKillScore.Text := Format('👑 STAGE %d BOSS 출현! (👾 %d)', [FStage, FKills])
    else
      lblKillScore.Text := Format('STAGE %d [%d/%d]  👾 %d', [FStage, FStageKills, FStageTargetKills, FKills]);
  end;
end;

{ ============================================================================ }
{ 최고 기록 INI 로드/저장                                                      }
{ ============================================================================ }

procedure TfrmGame.LoadBestScores;
var
  Ini: TIniFile;
  IniPath: string;
begin
  try
    IniPath := ChangeFileExt(ParamStr(0), '_data.ini');
    if not FileExists(IniPath) then Exit;
    Ini := TIniFile.Create(IniPath);
    try
      FBestSurvivalSeconds := Ini.ReadInteger('Survivor', 'BestSurvivalSeconds', 0);
      FBestKills := Ini.ReadInteger('Survivor', 'BestKills', 0);
      FBestLevel := Ini.ReadInteger('Survivor', 'BestLevel', 1);
      FBestStage := Ini.ReadInteger('Survivor', 'BestStage', 1);
    finally
      Ini.Free;
    end;
  except
  end;
end;

procedure TfrmGame.SaveBestScores;
var
  Ini: TIniFile;
  IniPath: string;
begin
  try
    IniPath := ChangeFileExt(ParamStr(0), '_data.ini');
    Ini := TIniFile.Create(IniPath);
    try
      Ini.WriteInteger('Survivor', 'BestSurvivalSeconds', FBestSurvivalSeconds);
      Ini.WriteInteger('Survivor', 'BestKills', FBestKills);
      Ini.WriteInteger('Survivor', 'BestLevel', FBestLevel);
      Ini.WriteInteger('Survivor', 'BestStage', FBestStage);
    finally
      Ini.Free;
    end;
  except
  end;
end;

{ ============================================================================ }
{ 게임 시작 및 리셋                                                            }
{ ============================================================================ }

{ ============================================================================ }
{ 뽀모도로 타이머 데이터 연동 & 캐릭터 선택                                     }
{ ============================================================================ }

procedure TfrmGame.LoadPomodoroHarvestData;
var
  Ini: TIniFile;
  IniPath: string;
begin
  FTomatoHarvestCount := 0;
  try
    IniPath := ChangeFileExt(ParamStr(0), '_data.ini');
    if FileExists(IniPath) then
    begin
      Ini := TIniFile.Create(IniPath);
      try
        FTomatoHarvestCount := Ini.ReadInteger('Stats', 'CompletedPomodoros', 0);
      finally
        Ini.Free;
      end;
    end;
  except
  end;
end;

procedure TfrmGame.SelectCharacter(const AChar: TCharacterType);
begin
  LoadPomodoroHarvestData;

  case AChar of
    ctEspresso:
      if FTomatoHarvestCount < 2 then
      begin
        AddFloatingText(FPlayerX, FPlayerY - 30, '🔒 토마토 2개 수확 시 [에스프레소 빈] 해금!', $FFFF4D6D);
        PlaySoundBeep(200, 150);
        Exit;
      end;
    ctBunny:
      if FTomatoHarvestCount < 4 then
      begin
        AddFloatingText(FPlayerX, FPlayerY - 30, '🔒 토마토 4개 수확 시 [바닐라 토끼] 해금!', $FFFF4D6D);
        PlaySoundBeep(200, 150);
        Exit;
      end;
    ctTomato:
      if FTomatoHarvestCount < 6 then
      begin
        AddFloatingText(FPlayerX, FPlayerY - 30, '🔒 토마토 6개 수확 시 [탱탱 토마토] 해금!', $FFFF4D6D);
        PlaySoundBeep(200, 150);
        Exit;
      end;
  end;

  FSelectedChar := AChar;
  case FSelectedChar of
    ctStrawberry: AddFloatingText(FPlayerX, FPlayerY - 30, '🍓 [딸기 공주] 선택! 밸런스 & 씨앗포 시작', $FFFF758F);
    ctEspresso:   AddFloatingText(FPlayerX, FPlayerY - 30, '☕ [에스프레소 빈] 선택! 빠른 공속 & 파동 시작', $FFE09F3E);
    ctBunny:      AddFloatingText(FPlayerX, FPlayerY - 30, '🐰 [바닐라 토끼] 선택! 신속 이동 & 쿨타임 단축', $FF52B788);
    ctTomato:     AddFloatingText(FPlayerX, FPlayerY - 30, '🍅 [탱탱 토마토] 선택! 대용량 체력 & 위성 시작', $FFFF4D6D);
  end;
  PlaySoundBeep(880, 100);

  // 캐릭터 변경 시 새 게임 적용
  StartNewGame;
end;

procedure TfrmGame.PerformDash;
begin
  if (FGameState = gsPlaying) and (FDashCooldownTimer <= 0) then
  begin
    FDashTimer := 0.22;       // 0.22초 동안 광속 대시
    FDashCooldownTimer := FDashMaxCooldown;
    FInvincibleTimer := 0.35; // 대시 중 완전 무적
    AddParticles(FPlayerX, FPlayerY, $FFFF758F, 12);
    AddFloatingText(FPlayerX, FPlayerY - 25, '💨 슈웅! 대시!', $FFFF758F);
    PlaySoundBeep(980, 80);
  end;
end;

{ ============================================================================ }
{ 게임 시작 및 리셋                                                            }
{ ============================================================================ }

procedure TfrmGame.StartGameSession;
begin
  Show;
  StartNewGame;
end;

procedure TfrmGame.StartNewGame;
var
  I: Integer;
begin
  FGameState := gsPlaying;
  lytLevelUpModal.Visible := False;
  lytGameOverModal.Visible := False;

  LoadPomodoroHarvestData;

  // 플레이어 기본 위치 (화면 중앙)
  FPlayerX := pbGame.Width / 2;
  FPlayerY := pbGame.Height / 2;
  FPlayerRadius := 18;
  FPlayerLevel := 1;
  FPlayerNextEXP := 10;
  FKills := 0;
  FSurvivalSeconds := 0;
  FInvincibleTimer := 0;

  FKeyLeft := False;
  FKeyRight := False;
  FKeyUp := False;
  FKeyDown := False;
  FMouseControlActive := False;

  // 모든 스킬 및 진화 플래그 초기화
  FSeedLevel := 0;
  FSeedCooldownTimer := 0;
  FOrbitLevel := 0;
  FOrbitAngle := 0;
  FCoffeeLevel := 0;
  FCoffeeCooldownTimer := 0;
  FCoffeeWaveActive := False;
  FCoffeeWaveRadius := 0;
  FVitaminLevel := 0;
  FVitaminCooldownTimer := 0;
  FMoveSpeedLevel := 0;
  FMaxHPLevel := 0;
  FMagnetLevel := 0;
  FAttackSpeedLevel := 0;
  FAttackSpeedMultiplier := 1.0;

  FSeedEvolved := False;
  FOrbitEvolved := False;
  FCoffeeEvolved := False;
  FVitaminEvolved := False;

  // 대시 초기화
  FDashTimer := 0;
  FDashCooldownTimer := 0;
  FDashMaxCooldown := 3.2;

  // 캐릭터별 고유 스탯 및 시작 스킬 분기
  case FSelectedChar of
    ctStrawberry:
      begin
        FPlayerMaxHP := 100;
        FPlayerHP := 100;
        FPlayerSpeed := 3.6;
        FSeedLevel := 1;
      end;
    ctEspresso:
      begin
        FPlayerMaxHP := 85;
        FPlayerHP := 85;
        FPlayerSpeed := 3.7;
        FAttackSpeedLevel := 1;
        FAttackSpeedMultiplier := 1.25;
        FCoffeeLevel := 1;
      end;
    ctBunny:
      begin
        FPlayerMaxHP := 80;
        FPlayerHP := 80;
        FPlayerSpeed := 4.4;
        FMoveSpeedLevel := 1;
        FDashMaxCooldown := 1.8; // 토끼는 대시 쿨타임 초단축!
        FSeedLevel := 1;
      end;
    ctTomato:
      begin
        FPlayerMaxHP := 160;
        FPlayerHP := 160;
        FPlayerSpeed := 3.2;
        FMaxHPLevel := 1;
        FOrbitLevel := 1;
      end;
  end;

  // 뽀모도로 타이머 연동 보너스:
  // 1. 토마토 4개 이상(일일 목표 달성)이면 '토마토 천사의 부활' 1회 기본 제공!
  FHasRevive := (FTomatoHarvestCount >= 4);
  FReviveUsed := False;

  // 2. 수확한 토마토 1개당 보너스 시작 경험치 +15 EXP
  FPlayerEXP := FTomatoHarvestCount * 15;

  FSpawnTimer := 0;
  FLastWaveTriggerSec := 0;

  // 스테이지 및 보스 상태 초기화
  FStage := 1;
  FStageKills := 0;
  FStageTargetKills := 35; // 첫 스테이지는 35마리 처치 시 보스 출현!
  FBossActive := False;
  FBossSpawnedThisStage := False;

  // 엔티티 풀 초기화
  for I := Low(FEnemies) to High(FEnemies) do FEnemies[I].Active := False;
  for I := Low(FProjectiles) to High(FProjectiles) do FProjectiles[I].Active := False;
  for I := Low(FGems) to High(FGems) do FGems[I].Active := False;
  for I := Low(FFloatingTexts) to High(FFloatingTexts) do FFloatingTexts[I].Active := False;
  for I := Low(FParticles) to High(FParticles) do FParticles[I].Active := False;

  rectExpFill.Width := 0;
  FLastDisplaySec := -1;
  FLastDisplayKills := -1;
  FLastDisplayHP := -1;
  FLastDisplayLevel := -1;
  FLastDisplayStage := -1;
  FLastDisplayStageKills := -1;
  FLastDisplayBossActive := False;
  UpdateHUDLabels;
  lblSurvivalTime.Text := '00:00';

  // 보너스 시작 EXP 레벨업 체크
  if FPlayerEXP >= FPlayerNextEXP then
    CheckLevelUp;

  FStopwatch := TStopwatch.StartNew;
  GameTimer.Enabled := True;
end;

{ ============================================================================ }
{ 키보드 및 마우스 입력                                                        }
{ ============================================================================ }

procedure TfrmGame.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  case Key of
    vkLeft, Ord('A'), Ord('a'): FKeyLeft := True;
    vkRight, Ord('D'), Ord('d'): FKeyRight := True;
    vkUp, Ord('W'), Ord('w'): FKeyUp := True;
    vkDown, Ord('S'), Ord('s'): FKeyDown := True;
    vkSpace, vkShift: PerformDash; // Space나 Shift는 순간 대시!
    Ord('P'), Ord('p'): rectBtnPauseClick(Self); // P키는 일시정지
    Ord('1'): SelectCharacter(ctStrawberry);
    Ord('2'): SelectCharacter(ctEspresso);
    Ord('3'): SelectCharacter(ctBunny);
    Ord('4'): SelectCharacter(ctTomato);
    vkEscape:
      if FGameState in [gsLevelUp, gsGameOver] then
        // 모달 상태 유지
      else
        rectBtnCloseGameClick(Self);
  end;
end;

procedure TfrmGame.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  case Key of
    vkLeft, Ord('A'), Ord('a'): FKeyLeft := False;
    vkRight, Ord('D'), Ord('d'): FKeyRight := False;
    vkUp, Ord('W'), Ord('w'): FKeyUp := False;
    vkDown, Ord('S'), Ord('s'): FKeyDown := False;
  end;
end;

procedure TfrmGame.pbGameMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Button = TMouseButton.mbLeft then
  begin
    FMouseControlActive := True;
    FMouseTargetX := X;
    FMouseTargetY := Y;
  end
  else if Button = TMouseButton.mbRight then
  begin
    PerformDash; // 마우스 우클릭으로도 순간 대시!
  end;
end;

procedure TfrmGame.pbGameMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if ssLeft in Shift then
  begin
    FMouseControlActive := True;
    FMouseTargetX := X;
    FMouseTargetY := Y;
  end;
end;

{ ============================================================================ }
{ 효과음 재생 (비동기 스레드)                                                 }
{ ============================================================================ }

procedure TfrmGame.PlaySoundBeep(const AFreq, ADur: Cardinal);
begin
  {$IFDEF MSWINDOWS}
  TThread.CreateAnonymousThread(
    procedure
    begin
      Winapi.Windows.Beep(AFreq, ADur);
    end
  ).Start;
  {$ENDIF}
end;

{ ============================================================================ }
{ 메인 게임 루프 (60 FPS)                                                      }
{ ============================================================================ }

procedure TfrmGame.GameTimerTick(Sender: TObject);
var
  DT: Single;
  ElapsedSec: Double;
begin
  ElapsedSec := FStopwatch.Elapsed.TotalSeconds;
  FStopwatch.Reset;
  FStopwatch.Start;

  // 창 이동이나 지연 발생 시 물리 연산 폭발 방지 (최대 0.05초 클램프)
  if ElapsedSec > 0.05 then
    ElapsedSec := 0.05;
  if ElapsedSec < 0.001 then
    ElapsedSec := 0.001;

  DT := ElapsedSec;

  if FGameState = gsPlaying then
  begin
    UpdateGame(DT);
  end;

  pbGame.Repaint;
end;

procedure TfrmGame.UpdateGame(const DT: Single);
var
  I, J: Integer;
  MoveX, MoveY, Dist, Spd: Single;
  MinExpSec: Integer;
  MagnetDist: Single;
  TimeScale: Single;
begin
  TimeScale := DT * 60.0; // 60 FPS 기준 1.0으로 정규화된 물리 타임스케일
  FSurvivalSeconds := FSurvivalSeconds + DT;
  if FInvincibleTimer > 0 then
    FInvincibleTimer := FInvincibleTimer - DT;

  // 1. 생존 시간 HUD 업데이트 (초가 변경될 때만 갱신하여 FMX 레이아웃 재연산 오버헤드 차단)
  MinExpSec := Trunc(FSurvivalSeconds);
  if MinExpSec <> FLastDisplaySec then
  begin
    FLastDisplaySec := MinExpSec;
    lblSurvivalTime.Text := Format('%.2d:%.2d', [MinExpSec div 60, MinExpSec mod 60]);
  end;

  // 2. 플레이어 이동 계산
  MoveX := 0;
  MoveY := 0;

  if FKeyLeft then MoveX := MoveX - 1;
  if FKeyRight then MoveX := MoveX + 1;
  if FKeyUp then MoveY := MoveY - 1;
  if FKeyDown then MoveY := MoveY + 1;

  // 키 입력이 있으면 마우스 조작 해제
  if (MoveX <> 0) or (MoveY <> 0) then
  begin
    FMouseControlActive := False;
    if (MoveX <> 0) and (MoveY <> 0) then
    begin
      MoveX := MoveX * 0.7071;
      MoveY := MoveY * 0.7071;
    end;
  end
  else if FMouseControlActive then
  begin
    // 마우스 터치 방향으로 이동
    Dist := Sqrt(Sqr(FMouseTargetX - FPlayerX) + Sqr(FMouseTargetY - FPlayerY));
    if Dist > 10 then
    begin
      MoveX := (FMouseTargetX - FPlayerX) / Dist;
      MoveY := (FMouseTargetY - FPlayerY) / Dist;
    end
    else
    begin
      FMouseControlActive := False;
    end;
  end;

  // 대시 쿨타임 및 지속시간 업데이트
  if FDashCooldownTimer > 0 then
    FDashCooldownTimer := FDashCooldownTimer - DT;

  Spd := FPlayerSpeed * (1.0 + FMoveSpeedLevel * 0.20) * TimeScale;

  if FDashTimer > 0 then
  begin
    FDashTimer := FDashTimer - DT;
    Spd := Spd * 2.7; // 대시 중 이동 속도 2.7배 폭발적 증가!
    if Random(2) = 0 then
      AddParticles(FPlayerX, FPlayerY, $FFFF758F, 2);
  end;

  FPlayerX := FPlayerX + MoveX * Spd;
  FPlayerY := FPlayerY + MoveY * Spd;

  // 빠른 이동 시 가벼운 발자국 먼지 파티클
  if (FMoveSpeedLevel > 0) and ((MoveX <> 0) or (MoveY <> 0)) and (Random(6) = 0) then
    AddParticles(FPlayerX - MoveX * 8, FPlayerY - MoveY * 8, $FFD6E2E8, 1);

  // 화면 경계 제한
  if FPlayerX < FPlayerRadius + 10 then FPlayerX := FPlayerRadius + 10;
  if FPlayerX > pbGame.Width - FPlayerRadius - 10 then FPlayerX := pbGame.Width - FPlayerRadius - 10;
  if FPlayerY < FPlayerRadius + 60 then FPlayerY := FPlayerRadius + 60;
  if FPlayerY > pbGame.Height - FPlayerRadius - 10 then FPlayerY := pbGame.Height - FPlayerRadius - 10;

  // 3. 대량 몬스터 스폰 & 군집 웨이브 제어 (Vampire Survivors 스타일!)
  FSpawnTimer := FSpawnTimer + DT;

  // 기본 스폰 주기: 0.18초 ~ 0.40초 주기로 다수 무리 동시 스폰!
  var SpawnInterval: Single := Max(0.36, 0.80 - (FSurvivalSeconds * 0.003));
  if FSpawnTimer >= SpawnInterval then
  begin
    FSpawnTimer := 0;
    var BatchCount: Integer;

    if FSurvivalSeconds < 15 then
      BatchCount := 2 + Random(2) // 2~3마리씩
    else if FSurvivalSeconds < 40 then
      BatchCount := 3 + Random(4) // 3~6마리씩
    else if FSurvivalSeconds < 70 then
      BatchCount := 5 + Random(5) // 5~9마리씩
    else
      BatchCount := 8 + Random(8); // 8~15마리씩 쏟아짐!

    for var B := 1 to BatchCount do
    begin
      if FSurvivalSeconds < 25 then
        SpawnEnemy(etDust)
      else if FSurvivalSeconds < 55 then
      begin
        if Random(10) < 6 then SpawnEnemy(etDust) else SpawnEnemy(etSleepy);
      end
      else
      begin
        case Random(10) of
          0..3: SpawnEnemy(etDust);
          4..6: SpawnEnemy(etSleepy);
          7..9: SpawnEnemy(etPhone);
        end;
      end;
    end;
  end;

  // 15초 주기 대규모 몰살 특수 웨이브 (Swarm Rush Waves!)
  var CurrentSec: Integer := Trunc(FSurvivalSeconds);
  if (CurrentSec > 0) and (CurrentSec mod 15 = 0) and (CurrentSec <> FLastWaveTriggerSec) then
  begin
    FLastWaveTriggerSec := CurrentSec;
    case CurrentSec of
      15:
        begin
          SpawnEnemiesBatch(25, etDust);
          AddFloatingText(FPlayerX, FPlayerY - 45, '🌊 [웨이브] 잡생각 먼지 대군 습격! (25마리)', $FFFF758F);
        end;
      30:
        begin
          SpawnEnemiesBatch(30, etSleepy);
          AddFloatingText(FPlayerX, FPlayerY - 45, '💤 [웨이브] 쏟아지는 졸음 폭풍! (30마리)', $FF4EA8DE);
        end;
      45:
        begin
          SpawnEnemiesBatch(35, etPhone);
          AddFloatingText(FPlayerX, FPlayerY - 45, '📱 [웨이브] 스마트폰 알림 유령 대공습! (35마리)', $FFFF4D6D);
        end;
      60:
        begin
          SpawnEnemiesBatch(45, etDust);
          AddFloatingText(FPlayerX, FPlayerY - 45, '🌪️ [대규모 포위] 사방에서 몰려오는 잡생각! (45마리)', $FFFFD166);
        end;
      75:
        begin
          SpawnEnemiesBatch(25, etSleepy);
          SpawnEnemiesBatch(25, etPhone);
          AddFloatingText(FPlayerX, FPlayerY - 45, '⚠️ [총력전] 졸음과 알림의 합공! (50마리)', $FFFF758F);
        end;
      90:
        begin
          SpawnEnemiesBatch(20, etSleepy);
          SpawnEnemiesBatch(20, etPhone);
          AddFloatingText(FPlayerX, FPlayerY - 45, '⚠️ [정예 공습] 졸음과 알림의 대규모 파상공격! (40마리)', $FFFF4D6D);
          PlaySoundBeep(250, 250);
        end;
      else
        if CurrentSec > 90 then
        begin
          SpawnEnemiesBatch(35, etPhone);
          AddFloatingText(FPlayerX, FPlayerY - 45, '⚡ [무한 서바이벌] 극한의 몬스터 러시! (35마리)', $FF7B7CDB);
        end;
    end;
  end;

  // 4. 자동 공격 무기 발사 (Vampire Survivors 스타일!)
  // 4-1. 씨앗 뿅뿅포 (가장 가까운 적 자동 조준 사격)
  FSeedCooldownTimer := FSeedCooldownTimer + DT;
  if (FSeedLevel > 0) and (FSeedCooldownTimer >= (0.55 / FAttackSpeedMultiplier)) then
  begin
    FSeedCooldownTimer := 0;
    FireSeedGun;
  end;

  // 4-2. 가디언 딸기 위성 회전 (공격 속도 버프 시 위성도 더 빠르게 회전!)
  if FOrbitLevel > 0 then
  begin
    FOrbitAngle := FOrbitAngle + (3.2 * (1.0 + FAttackSpeedLevel * 0.25)) * DT;
    if FOrbitAngle > 2 * Pi then
      FOrbitAngle := FOrbitAngle - 2 * Pi;
  end;

  // 4-3. 에스프레소 파동
  if FCoffeeLevel > 0 then
  begin
    FCoffeeCooldownTimer := FCoffeeCooldownTimer + DT;
    if FCoffeeCooldownTimer >= (3.0 / FAttackSpeedMultiplier) then
    begin
      FCoffeeCooldownTimer := 0;
      TriggerCoffeePulse;
    end;

    if FCoffeeWaveActive then
    begin
      FCoffeeWaveRadius := FCoffeeWaveRadius + 320 * DT;
      if FCoffeeWaveRadius > (90 + FCoffeeLevel * 25) then
        FCoffeeWaveActive := False;
    end;
  end;

  // 4-4. 비타민 번개
  if FVitaminLevel > 0 then
  begin
    FVitaminCooldownTimer := FVitaminCooldownTimer + DT;
    if FVitaminCooldownTimer >= (2.2 / FAttackSpeedMultiplier) then
    begin
      FVitaminCooldownTimer := 0;
      TriggerVitaminZap;
    end;
  end;

  // 5. 투사체 업데이트 및 적 충돌 처리
  for I := Low(FProjectiles) to High(FProjectiles) do
  begin
    if not FProjectiles[I].Active then Continue;

    FProjectiles[I].X := FProjectiles[I].X + FProjectiles[I].VX * TimeScale;
    FProjectiles[I].Y := FProjectiles[I].Y + FProjectiles[I].VY * TimeScale;
    FProjectiles[I].LifeTime := FProjectiles[I].LifeTime - DT;

    if (FProjectiles[I].LifeTime <= 0) or
       (FProjectiles[I].X < -20) or (FProjectiles[I].X > pbGame.Width + 20) or
       (FProjectiles[I].Y < -20) or (FProjectiles[I].Y > pbGame.Height + 20) then
    begin
      FProjectiles[I].Active := False;
      Continue;
    end;

    // 적과의 충돌 검사
    for J := Low(FEnemies) to High(FEnemies) do
    begin
      if not FEnemies[J].Active then Continue;

      Dist := Sqrt(Sqr(FEnemies[J].X - FProjectiles[I].X) + Sqr(FEnemies[J].Y - FProjectiles[I].Y));
      if Dist < (FEnemies[J].Radius + FProjectiles[I].Radius) then
      begin
        // 적 대미지 처리
        FEnemies[J].HP := FEnemies[J].HP - FProjectiles[I].Damage;
        FEnemies[J].FlashTimer := 0.12;

        AddFloatingText(FEnemies[J].X, FEnemies[J].Y - 12, Format('-%d', [Round(FProjectiles[I].Damage)]), $FFFF758F);
        AddParticles(FProjectiles[I].X, FProjectiles[I].Y, $FFFF8FA3, 4);

        Dec(FProjectiles[I].Pierce);
        if FProjectiles[I].Pierce <= 0 then
        begin
          FProjectiles[I].Active := False;
          Break;
        end;
      end;
    end;
  end;

  // 6. 가디언 딸기 위성 적 충돌 검사
  if FOrbitLevel > 0 then
  begin
    var OrbitCount := FOrbitLevel;
    var OrbitDist: Single := 65;
    for var O := 0 to OrbitCount - 1 do
    begin
      var Ang := FOrbitAngle + (2 * Pi / OrbitCount) * O;
      var Ox := FPlayerX + Cos(Ang) * OrbitDist;
      var Oy := FPlayerY + Sin(Ang) * OrbitDist;

      for J := Low(FEnemies) to High(FEnemies) do
      begin
        if not FEnemies[J].Active then Continue;
        Dist := Sqrt(Sqr(FEnemies[J].X - Ox) + Sqr(FEnemies[J].Y - Oy));
        if Dist < (FEnemies[J].Radius + 14) then
        begin
          FEnemies[J].HP := FEnemies[J].HP - (45 * DT);
          FEnemies[J].FlashTimer := 0.08;
          // 약간 넉백 밀어내기
          FEnemies[J].X := FEnemies[J].X + Cos(Ang) * (2 * TimeScale);
          FEnemies[J].Y := FEnemies[J].Y + Sin(Ang) * (2 * TimeScale);
        end;
      end;
    end;
  end;

  // 7. 적 몬스터 업데이트 & 플레이어 추적
  for I := Low(FEnemies) to High(FEnemies) do
  begin
    if not FEnemies[I].Active then Continue;

    if FEnemies[I].FlashTimer > 0 then
      FEnemies[I].FlashTimer := FEnemies[I].FlashTimer - DT;

    // 사망 처리
    if FEnemies[I].HP <= 0 then
    begin
      FEnemies[I].Active := False;
      Inc(FKills);

      AddParticles(FEnemies[I].X, FEnemies[I].Y, $FFFF758F, 8);

      // 보석 및 아이템 드랍
      case FEnemies[I].EnemyType of
        etDust:   AddGem(FEnemies[I].X, FEnemies[I].Y, gtGreen, 1);
        etSleepy: AddGem(FEnemies[I].X, FEnemies[I].Y, gtBlue, 3);
        etPhone:  AddGem(FEnemies[I].X, FEnemies[I].Y, gtPink, 8);
        etBoss:
          begin
            FBossActive := False;
            AddGem(FEnemies[I].X, FEnemies[I].Y, gtChest, 0); // 🎁 황금 보물상자 100% 확정 드랍!
            AddGem(FEnemies[I].X - 25, FEnemies[I].Y, gtCake, 0); // 힐링 케이크
            AddGem(FEnemies[I].X + 25, FEnemies[I].Y, gtMagnet, 0); // 슈퍼 자석
            for var B := 1 to 8 do
              AddGem(FEnemies[I].X + Random(50) - 25, FEnemies[I].Y + Random(50) - 25, gtPink, 12);

            AddFloatingText(FPlayerX, FPlayerY - 45, Format('🎉 STAGE %d CLEAR! 보스 격파 대성공!', [FStage]), $FFFFD166);
            PlaySoundBeep(880, 200);

            // 다음 스테이지 진입 & 난이도 상승
            Inc(FStage);
            FStageKills := 0;
            FStageTargetKills := 35 + (FStage - 1) * 15;
            FBossSpawnedThisStage := False;

            AddFloatingText(pbGame.Width / 2, pbGame.Height / 2 - 20, Format('⚔️ STAGE %d START! 더 강한 적들이 등장합니다!', [FStage]), $FFFF758F);
            PlaySoundBeep(587, 150);
            UpdateHUDLabels;
          end;
      end;

      // 일반 적 처치 시 스테이지 카운트 증가 및 보스 소환 판정
      if FEnemies[I].EnemyType <> etBoss then
      begin
        if not FBossSpawnedThisStage then
        begin
          Inc(FStageKills);
          if FStageKills >= FStageTargetKills then
          begin
            FBossSpawnedThisStage := True;
            FBossActive := True;
            SpawnEnemy(etBoss);
            SpawnEnemiesBatch(15 + Min(20, FStage * 4), etDust);
            AddFloatingText(pbGame.Width / 2, 85, Format('👑 [STAGE %d BOSS] 거대 보스 출현! 물리치세요!', [FStage]), $FFFF4D6D);
            PlaySoundBeep(260, 350);
          end;
        end;

        // 아이템 무작위 드랍: 3% 케이크, 2.5% 토마토 폭탄, 0.5% 황금 보물상자
        var Roll := Random(1000);
        if Roll < 30 then
          AddGem(FEnemies[I].X + 8, FEnemies[I].Y + 8, gtCake, 0)
        else if Roll < 55 then
          AddGem(FEnemies[I].X - 8, FEnemies[I].Y + 8, gtBomb, 0)
        else if Roll < 60 then
          AddGem(FEnemies[I].X, FEnemies[I].Y - 8, gtChest, 0);
      end;

      UpdateHUDLabels;
      Continue;
    end;

    // 플레이어를 향해 이동
    Dist := Sqrt(Sqr(FPlayerX - FEnemies[I].X) + Sqr(FPlayerY - FEnemies[I].Y));
    if Dist > 1 then
    begin
      FEnemies[I].X := FEnemies[I].X + ((FPlayerX - FEnemies[I].X) / Dist) * (FEnemies[I].Speed * TimeScale);
      FEnemies[I].Y := FEnemies[I].Y + ((FPlayerY - FEnemies[I].Y) / Dist) * (FEnemies[I].Speed * TimeScale);
    end;

    // 플레이어와의 충돌 (피격)
    if (Dist < (FPlayerRadius + FEnemies[I].Radius)) and (FInvincibleTimer <= 0) then
    begin
      FPlayerHP := FPlayerHP - FEnemies[I].Damage;
      FInvincibleTimer := 0.45; // 0.45초 무적 시간
      AddFloatingText(FPlayerX, FPlayerY - 20, Format('-%d', [Round(FEnemies[I].Damage)]), $FFFF3333);
      AddParticles(FPlayerX, FPlayerY, $FFFF4D6D, 6);
      UpdateHUDLabels;

      if FPlayerHP <= 0 then
      begin
        // 뽀모도로 토마토 천사 부활 확인!
        if FHasRevive and (not FReviveUsed) then
        begin
          FReviveUsed := True;
          FPlayerHP := FPlayerMaxHP;
          FInvincibleTimer := 2.5; // 2.5초간 긴 무적
          AddFloatingText(FPlayerX, FPlayerY - 35, '👼 [토마토 천사] 100% 부활 성공! 힘내세요!', $FFFFD166);
          AddParticles(FPlayerX, FPlayerY, $FFFFD166, 20);
          PlaySoundBeep(523, 70);
          PlaySoundBeep(659, 70);
          PlaySoundBeep(784, 70);
          PlaySoundBeep(1046, 220);
          UpdateHUDLabels;
        end
        else
        begin
          FPlayerHP := 0;
          UpdateHUDLabels;
          OnGameOver;
          Exit;
        end;
      end;
    end;
  end;

  // 8. 보석(EXP) 업데이트 & 자석 흡수
  MagnetDist := 60 + (FMagnetLevel * 45);
  var MagnetSpeed: Single := (7.5 + FMagnetLevel * 2.5) * TimeScale;
  for I := Low(FGems) to High(FGems) do
  begin
    if not FGems[I].Active then Continue;

    Dist := Sqrt(Sqr(FPlayerX - FGems[I].X) + Sqr(FPlayerY - FGems[I].Y));

    // 자석 범위 안으로 들어오면 플레이어에게 슉 끌려옴
    if Dist < MagnetDist then
    begin
      FGems[I].X := FGems[I].X + ((FPlayerX - FGems[I].X) / Dist) * MagnetSpeed;
      FGems[I].Y := FGems[I].Y + ((FPlayerY - FGems[I].Y) / Dist) * MagnetSpeed;
    end;

    // 획득 판정
    if Dist < (FPlayerRadius + FGems[I].Radius + 4) then
    begin
      FGems[I].Active := False;

      case FGems[I].GemType of
        gtBomb:
          TriggerTomatoBomb;
        gtChest:
          OpenTreasureChest;
        gtCake:
          begin
            FPlayerHP := Min(FPlayerMaxHP, FPlayerHP + 30);
            UpdateHUDLabels;
            AddFloatingText(FPlayerX, FPlayerY - 24, '+30 HP 🍰', $FF52B788);
          end;
        gtMagnet:
          begin
            // 화면의 모든 보석을 플레이어에게 즉시 끌어당김!
            for J := Low(FGems) to High(FGems) do
            begin
              if FGems[J].Active then
              begin
                FGems[J].X := FPlayerX + Random(30) - 15;
                FGems[J].Y := FPlayerY + Random(30) - 15;
              end;
            end;
            AddFloatingText(FPlayerX, FPlayerY - 24, '🧲 슈퍼 자석 파워!', $FFE09F3E);
          end;
        else
          begin
            FPlayerEXP := FPlayerEXP + FGems[I].ExpValue;
            AddFloatingText(FGems[I].X, FGems[I].Y - 10, Format('+%d', [FGems[I].ExpValue]), $FF7B7CDB);
            if FPlayerNextEXP > 0 then
              rectExpFill.Width := rectExpTrack.Width * Min(1.0, FPlayerEXP / FPlayerNextEXP);
            CheckLevelUp;
          end;
      end;
    end;
  end;

  // 9. 플로팅 텍스트 업데이트
  for I := Low(FFloatingTexts) to High(FFloatingTexts) do
  begin
    if not FFloatingTexts[I].Active then Continue;
    FFloatingTexts[I].Y := FFloatingTexts[I].Y - 24 * DT;
    FFloatingTexts[I].LifeTime := FFloatingTexts[I].LifeTime - DT;
    if FFloatingTexts[I].LifeTime <= 0 then
      FFloatingTexts[I].Active := False;
  end;

  // 10. 파티클 업데이트
  for I := Low(FParticles) to High(FParticles) do
  begin
    if not FParticles[I].Active then Continue;
    FParticles[I].X := FParticles[I].X + FParticles[I].VX * TimeScale;
    FParticles[I].Y := FParticles[I].Y + FParticles[I].VY * TimeScale;
    FParticles[I].LifeTime := FParticles[I].LifeTime - DT;
    if FParticles[I].LifeTime <= 0 then
      FParticles[I].Active := False;
  end;
end;

{ ============================================================================ }
{ 적 스폰 로직                                                                 }
{ ============================================================================ }

procedure TfrmGame.SpawnEnemiesBatch(const ACount: Integer; const AType: TEnemyType);
var
  C: Integer;
begin
  for C := 1 to ACount do
    SpawnEnemy(AType);
end;

procedure TfrmGame.SpawnEnemy(const AType: TEnemyType);
var
  I, Edge: Integer;
  Sx, Sy: Single;
  StageMult: Single;
begin
  StageMult := 1.0 + (FStage - 1) * 0.28;

  for I := Low(FEnemies) to High(FEnemies) do
  begin
    if not FEnemies[I].Active then
    begin
      // 화면 사방 모서리 외곽에서 스폰
      Edge := Random(4);
      case Edge of
        0: begin Sx := Random(Trunc(pbGame.Width)); Sy := -25 - Random(30); end;
        1: begin Sx := pbGame.Width + 25 + Random(30); Sy := Random(Trunc(pbGame.Height)); end;
        2: begin Sx := Random(Trunc(pbGame.Width)); Sy := pbGame.Height + 25 + Random(30); end;
        else begin Sx := -25 - Random(30); Sy := Random(Trunc(pbGame.Height)); end;
      end;

      FEnemies[I].Active := True;
      FEnemies[I].X := Sx;
      FEnemies[I].Y := Sy;
      FEnemies[I].EnemyType := AType;
      FEnemies[I].FlashTimer := 0;

      case AType of
        etDust: // 잡생각 먼지 구름 (대량 출현, 팝콘 터지듯 시원하게 처치!)
          begin
            FEnemies[I].Radius := 11;
            FEnemies[I].Speed := (1.7 + Random * 0.4) * Min(1.35, 1.0 + (FStage - 1) * 0.04);
            FEnemies[I].MaxHP := (10 + (FSurvivalSeconds * 0.12)) * StageMult;
            FEnemies[I].HP := FEnemies[I].MaxHP;
            FEnemies[I].Damage := 4 + (FStage - 1) * 1.5;
          end;
        etSleepy: // 졸음 몬스터
          begin
            FEnemies[I].Radius := 15;
            FEnemies[I].Speed := (1.1 + Random * 0.3) * Min(1.35, 1.0 + (FStage - 1) * 0.04);
            FEnemies[I].MaxHP := (24 + (FSurvivalSeconds * 0.22)) * StageMult;
            FEnemies[I].HP := FEnemies[I].MaxHP;
            FEnemies[I].Damage := 8 + (FStage - 1) * 2.0;
          end;
        etPhone: // 스마트폰 알림 유령
          begin
            FEnemies[I].Radius := 14;
            FEnemies[I].Speed := (2.1 + Random * 0.3) * Min(1.45, 1.0 + (FStage - 1) * 0.05);
            FEnemies[I].MaxHP := (38 + (FSurvivalSeconds * 0.35)) * StageMult;
            FEnemies[I].HP := FEnemies[I].MaxHP;
            FEnemies[I].Damage := 12 + (FStage - 1) * 3.0;
          end;
        etBoss: // 거대 보스 (스테이지마다 체력/공격력/크기 대폭 강화!)
          begin
            FEnemies[I].Radius := 38 + Min(16, (FStage - 1) * 3);
            FEnemies[I].Speed := 0.85 + Min(0.40, (FStage - 1) * 0.08);
            FEnemies[I].MaxHP := 480 + (FStage - 1) * 360;
            FEnemies[I].HP := FEnemies[I].MaxHP;
            FEnemies[I].Damage := 22 + (FStage - 1) * 6;
          end;
      end;
      Break;
    end;
  end;
end;

{ ============================================================================ }
{ 무기 및 스킬 발사                                                            }
{ ============================================================================ }

procedure TfrmGame.FireSeedGun;
var
  I, J: Integer;
  NearestIdx: Integer;
  MinDist, Dist: Single;
  TargetAngle, SpreadAngle: Single;
  SeedCount: Integer;
  ProjSpeed: Single;
begin
  NearestIdx := -1;
  MinDist := 999999;

  for I := Low(FEnemies) to High(FEnemies) do
  begin
    if not FEnemies[I].Active then Continue;
    Dist := Sqrt(Sqr(FEnemies[I].X - FPlayerX) + Sqr(FEnemies[I].Y - FPlayerY));
    if Dist < MinDist then
    begin
      MinDist := Dist;
      NearestIdx := I;
    end;
  end;

  if NearestIdx = -1 then Exit;

  TargetAngle := ArcTan2(FEnemies[NearestIdx].Y - FPlayerY, FEnemies[NearestIdx].X - FPlayerX);

  if FSeedEvolved then
  begin
    // ✨ 진화 무기: 메가 딸기 개틀링 (8발 전방위 고속 연사 탄막)
    SeedCount := 8;
    ProjSpeed := 12.0 + (FAttackSpeedLevel * 1.5);
    for I := 0 to SeedCount - 1 do
    begin
      SpreadAngle := TargetAngle + (I - 3.5) * 0.22;
      for J := Low(FProjectiles) to High(FProjectiles) do
      begin
        if not FProjectiles[J].Active then
        begin
          FProjectiles[J].Active := True;
          FProjectiles[J].X := FPlayerX;
          FProjectiles[J].Y := FPlayerY;
          FProjectiles[J].VX := Cos(SpreadAngle) * ProjSpeed;
          FProjectiles[J].VY := Sin(SpreadAngle) * ProjSpeed;
          FProjectiles[J].Radius := 7;
          FProjectiles[J].LifeTime := 2.5;
          FProjectiles[J].Damage := 60 + (FAttackSpeedLevel * 6);
          FProjectiles[J].Pierce := 25; // 25마리 관통!
          Break;
        end;
      end;
    end;
  end
  else
  begin
    SeedCount := FSeedLevel + 1; // 레벨 1부터 2발 발사, 레벨당 +1발 증가!
    ProjSpeed := 8.0 + (FAttackSpeedLevel * 1.5);

    for I := 0 to SeedCount - 1 do
    begin
      if SeedCount = 1 then
        SpreadAngle := TargetAngle
      else
        SpreadAngle := TargetAngle + (I - (SeedCount - 1) / 2) * 0.16;

      for J := Low(FProjectiles) to High(FProjectiles) do
      begin
        if not FProjectiles[J].Active then
        begin
          FProjectiles[J].Active := True;
          FProjectiles[J].X := FPlayerX;
          FProjectiles[J].Y := FPlayerY;
          FProjectiles[J].VX := Cos(SpreadAngle) * ProjSpeed;
          FProjectiles[J].VY := Sin(SpreadAngle) * ProjSpeed;
          FProjectiles[J].Radius := 5;
          FProjectiles[J].LifeTime := 2.2;
          FProjectiles[J].Damage := 18 + (FSeedLevel * 4) + (FAttackSpeedLevel * 3);
          FProjectiles[J].Pierce := 1 + FSeedLevel; // 적을 관통하여 무더기로 꿰뚫음!
          Break;
        end;
      end;
    end;
  end;
end;

procedure TfrmGame.TriggerCoffeePulse;
var
  I: Integer;
  Dist, PushAngle: Single;
  PulseRadius: Single;
  PulseDmg: Single;
begin
  FCoffeeWaveActive := True;
  FCoffeeWaveRadius := 10;

  if FCoffeeEvolved then
  begin
    // ✨ 진화 무기: 다크 로스트 허리케인 (화면 전체 230px 광역 흡입 및 폭발 넉백)
    PulseRadius := 230;
    PulseDmg := 110 + (FMoveSpeedLevel * 15);
  end
  else
  begin
    PulseRadius := 115 + FCoffeeLevel * 30;
    PulseDmg := 35 + FCoffeeLevel * 15;
  end;

  for I := Low(FEnemies) to High(FEnemies) do
  begin
    if not FEnemies[I].Active then Continue;
    Dist := Sqrt(Sqr(FEnemies[I].X - FPlayerX) + Sqr(FEnemies[I].Y - FPlayerY));
    if Dist < PulseRadius then
    begin
      FEnemies[I].HP := FEnemies[I].HP - PulseDmg;
      FEnemies[I].FlashTimer := 0.15;
      PushAngle := ArcTan2(FEnemies[I].Y - FPlayerY, FEnemies[I].X - FPlayerX);
      var PushForce: Single := IfThen(FCoffeeEvolved, 95.0, 60.0);
      FEnemies[I].X := FEnemies[I].X + Cos(PushAngle) * PushForce;
      FEnemies[I].Y := FEnemies[I].Y + Sin(PushAngle) * PushForce;
      AddFloatingText(FEnemies[I].X, FEnemies[I].Y - 14, Format('-%d ☕', [Round(PulseDmg)]), $FFE09F3E);
    end;
  end;
end;

procedure TfrmGame.TriggerVitaminZap;
var
  I, TargetCount, Struck: Integer;
  ZapDmg: Single;
begin
  if FVitaminEvolved then
  begin
    // ✨ 진화 무기: 메가 비타민 플라즈마 (동시 8마리 연쇄 벼락 폭풍)
    TargetCount := 9;
    ZapDmg := 130 + (FMagnetLevel * 15);
  end
  else
  begin
    TargetCount := 3 * FVitaminLevel;
    ZapDmg := 45 + FVitaminLevel * 15;
  end;

  Struck := 0;
  for I := Low(FEnemies) to High(FEnemies) do
  begin
    if not FEnemies[I].Active then Continue;
    FEnemies[I].HP := FEnemies[I].HP - ZapDmg;
    FEnemies[I].FlashTimer := 0.2;
    AddFloatingText(FEnemies[I].X, FEnemies[I].Y - 14, Format('-%d ⚡', [Round(ZapDmg)]), $FFFFD166);
    AddParticles(FEnemies[I].X, FEnemies[I].Y, $FFFFD166, 8);

    Inc(Struck);
    if Struck >= TargetCount then Break;
  end;
end;

procedure TfrmGame.TriggerTomatoBomb;
var
  I: Integer;
begin
  AddFloatingText(FPlayerX, FPlayerY - 30, '🍅 콰아아앙! 토마토 팡팡 폭탄!', $FFFF3333);
  PlaySoundBeep(180, 250);
  AddParticles(pbGame.Width / 2, pbGame.Height / 2, $FFFF4D6D, 35);

  // 화면 내의 모든 몬스터에게 대량 폭탄 피해
  for I := Low(FEnemies) to High(FEnemies) do
  begin
    if not FEnemies[I].Active then Continue;
    if FEnemies[I].EnemyType = etBoss then
      FEnemies[I].HP := FEnemies[I].HP - 400
    else
      FEnemies[I].HP := 0; // 일반 몬스터 일망타진!
  end;
end;

procedure TfrmGame.OpenTreasureChest;
var
  JackpotRoll, UpgradesCount: Integer;
  CanEvolve: Boolean;
  EvoCandidate: TUpgradeType;
begin
  CanEvolve := False;
  EvoCandidate := utSeedCount;

  // 진화 조건 체크: 기본 스킬 만렙(5) + 짝꿍 패시브 보유 시 즉시 무기 진화!
  if (not FSeedEvolved) and (FSeedLevel >= 5) and (FAttackSpeedLevel >= 1) then
  begin
    CanEvolve := True;
    EvoCandidate := utEvoSeedGatling;
  end
  else if (not FOrbitEvolved) and (FOrbitLevel >= 5) and (FMaxHPLevel >= 1) then
  begin
    CanEvolve := True;
    EvoCandidate := utEvoGalacticOrbit;
  end
  else if (not FCoffeeEvolved) and (FCoffeeLevel >= 5) and (FMoveSpeedLevel >= 1) then
  begin
    CanEvolve := True;
    EvoCandidate := utEvoDarkRoast;
  end
  else if (not FVitaminEvolved) and (FVitaminLevel >= 5) and (FMagnetLevel >= 1) then
  begin
    CanEvolve := True;
    EvoCandidate := utEvoPlasmaZap;
  end;

  if CanEvolve then
  begin
    ApplyUpgrade(EvoCandidate);
    AddFloatingText(FPlayerX, FPlayerY - 45, '✨ [보물상자 잭팟!] 궁극 무기 진화 달성! ✨', $FFFFD166);
    PlaySoundBeep(523, 70);
    PlaySoundBeep(659, 70);
    PlaySoundBeep(784, 70);
    PlaySoundBeep(1046, 200);
    Exit;
  end;

  // 1~3개 스킬 잭팟 롤링 (60% 1개, 30% 2개, 10% 3개)
  JackpotRoll := Random(100);
  if JackpotRoll < 60 then
    UpgradesCount := 1
  else if JackpotRoll < 90 then
    UpgradesCount := 2
  else
    UpgradesCount := 3;

  for var K := 1 to UpgradesCount do
  begin
    var RandUp: TUpgradeType := TUpgradeType(Random(8));
    ApplyUpgrade(RandUp);
  end;

  if UpgradesCount = 3 then
    AddFloatingText(FPlayerX, FPlayerY - 45, '🎰 [대박 잭팟! 3연타!] 스킬 3종 즉시 강화!', $FFFFD166)
  else if UpgradesCount = 2 then
    AddFloatingText(FPlayerX, FPlayerY - 45, '🎁 [더블 보너스!] 스킬 2종 동시 강화!', $FFFFD166)
  else
    AddFloatingText(FPlayerX, FPlayerY - 45, '🎁 [보물 상자 개봉!] 스킬 무료 강화!', $FFFFD166);

  PlaySoundBeep(784, 100);
  PlaySoundBeep(1046, 180);
end;

{ ============================================================================ }
{ 보석 및 파티클 헬퍼                                                          }
{ ============================================================================ }

procedure TfrmGame.AddGem(const X, Y: Single; const AType: TGemType; const AExp: Integer);
var
  I: Integer;
begin
  for I := Low(FGems) to High(FGems) do
  begin
    if not FGems[I].Active then
    begin
      FGems[I].Active := True;
      FGems[I].X := X;
      FGems[I].Y := Y;
      FGems[I].GemType := AType;
      FGems[I].ExpValue := AExp;
      FGems[I].Radius := 7;
      Exit;
    end;
  end;

  // 보석 풀(500개)이 가득 찼을 때: 기존 초록 보석을 고가치 보석으로 압축 병합 (경험치 보존)
  for I := Low(FGems) to High(FGems) do
  begin
    if FGems[I].Active and (FGems[I].GemType = gtGreen) then
    begin
      FGems[I].ExpValue := FGems[I].ExpValue + AExp;
      if FGems[I].ExpValue >= 10 then
        FGems[I].GemType := gtPink
      else if FGems[I].ExpValue >= 4 then
        FGems[I].GemType := gtBlue;
      Exit;
    end;
  end;
end;

procedure TfrmGame.AddFloatingText(const X, Y: Single; const AText: string; const ACol: TAlphaColor);
var
  I: Integer;
begin
  for I := Low(FFloatingTexts) to High(FFloatingTexts) do
  begin
    if not FFloatingTexts[I].Active then
    begin
      FFloatingTexts[I].Active := True;
      FFloatingTexts[I].X := X;
      FFloatingTexts[I].Y := Y;
      FFloatingTexts[I].Text := AText;
      FFloatingTexts[I].Color := ACol;
      FFloatingTexts[I].LifeTime := 0.8;
      FFloatingTexts[I].MaxLife := 0.8;
      Break;
    end;
  end;
end;

procedure TfrmGame.AddParticles(const X, Y: Single; const ACol: TAlphaColor; const ACount: Integer);
var
  I, C: Integer;
  Ang, Spd: Single;
begin
  C := 0;
  for I := Low(FParticles) to High(FParticles) do
  begin
    if not FParticles[I].Active then
    begin
      Ang := Random * 2 * Pi;
      Spd := 1.2 + Random * 2.5;
      FParticles[I].Active := True;
      FParticles[I].X := X;
      FParticles[I].Y := Y;
      FParticles[I].VX := Cos(Ang) * Spd;
      FParticles[I].VY := Sin(Ang) * Spd;
      FParticles[I].LifeTime := 0.4 + Random * 0.3;
      FParticles[I].MaxLife := FParticles[I].LifeTime;
      FParticles[I].Color := ACol;
      FParticles[I].Size := 3 + Random * 3;
      Inc(C);
      if C >= ACount then Break;
    end;
  end;
end;

{ ============================================================================ }
{ 레벨업 및 로그라이크 3선택 모달                                              }
{ ============================================================================ }

procedure TfrmGame.CheckLevelUp;
begin
  if FPlayerEXP >= FPlayerNextEXP then
  begin
    FPlayerEXP := FPlayerEXP - FPlayerNextEXP;
    Inc(FPlayerLevel);
    FPlayerNextEXP := Round(FPlayerNextEXP * 1.35 + 6);
    UpdateHUDLabels;

    // 레벨업 축하 멜로디
    {$IFDEF MSWINDOWS}
    TThread.CreateAnonymousThread(
      procedure
      begin
        Winapi.Windows.Beep(523, 70);
        Sleep(20);
        Winapi.Windows.Beep(659, 70);
        Sleep(20);
        Winapi.Windows.Beep(784, 80);
        Sleep(20);
        Winapi.Windows.Beep(1046, 150);
      end
    ).Start;
    {$ENDIF}

    ShowLevelUpModal;
  end;
end;

procedure TfrmGame.ShowLevelUpModal;
var
  Pool: array of TUpgradeType;
  Chosen: array[1..3] of TUpgradeType;
  I, J, PickIdx: Integer;
  Exists: Boolean;

  function GetUpgradeInfo(const AType: TUpgradeType): TUpgradeOption;
  begin
    Result.UpgradeType := AType;
    case AType of
      utSeedCount:
        begin
          Result.Icon := '🍓';
          Result.Title := '씨앗 뿅뿅포';
          Result.Desc := Format('적 자동 조준 씨앗 발사수 +1발 & 관통력 강화' + sLineBreak + '(현재: %d발 -> 다음: %d발)',
            [FSeedLevel + 1, FSeedLevel + 2]);
          Result.Badge := Format('Lv.%d', [FSeedLevel + 1]);
        end;
      utAttackSpeed:
        begin
          Result.Icon := '⚡';
          Result.Title := '딸기 부스터 (공속)';
          Result.Desc := Format('모든 무기 연사 속도 & 탄속 +25%% 가속' + sLineBreak + '(현재: +%d%% -> 다음: +%d%%)',
            [FAttackSpeedLevel * 25, (FAttackSpeedLevel + 1) * 25]);
          if FAttackSpeedLevel = 0 then
            Result.Badge := 'NEW!'
          else
            Result.Badge := Format('Lv.%d', [FAttackSpeedLevel + 1]);
        end;
      utOrbitStrawberry:
        begin
          Result.Icon := '🪐';
          Result.Title := '가디언 딸기 위성';
          Result.Desc := Format('플레이어 주위를 회전하는 보호 딸기 +1개' + sLineBreak + '(현재: %d개 -> 다음: %d개)',
            [FOrbitLevel, FOrbitLevel + 1]);
          if FOrbitLevel = 0 then
            Result.Badge := 'NEW!'
          else
            Result.Badge := Format('Lv.%d', [FOrbitLevel + 1]);
        end;
      utCoffeePulse:
        begin
          Result.Icon := '☕';
          Result.Title := '에스프레소 파동';
          Result.Desc := Format('360도 넉백 충격파 범위 & 위력 대폭 증가' + sLineBreak + '(현재: Lv.%d -> 다음: Lv.%d)',
            [FCoffeeLevel, FCoffeeLevel + 1]);
          if FCoffeeLevel = 0 then
            Result.Badge := 'NEW!'
          else
            Result.Badge := Format('Lv.%d', [FCoffeeLevel + 1]);
        end;
      utVitaminZap:
        begin
          Result.Icon := '⚡';
          Result.Title := '비타민 번개';
          Result.Desc := Format('적을 정밀 타격하는 번개 타겟수 +3명' + sLineBreak + '(현재: %d타겟 -> 다음: %d타겟)',
            [FVitaminLevel * 3, (FVitaminLevel + 1) * 3]);
          if FVitaminLevel = 0 then
            Result.Badge := 'NEW!'
          else
            Result.Badge := Format('Lv.%d', [FVitaminLevel + 1]);
        end;
      utMoveSpeed:
        begin
          Result.Icon := '👟';
          Result.Title := '토끼 덧신 (이속)';
          Result.Desc := Format('플레이어 이동속도 +20%% 영구 증가' + sLineBreak + '(현재: +%d%% -> 다음: +%d%%)',
            [FMoveSpeedLevel * 20, (FMoveSpeedLevel + 1) * 20]);
          if FMoveSpeedLevel = 0 then
            Result.Badge := 'NEW!'
          else
            Result.Badge := Format('Lv.%d', [FMoveSpeedLevel + 1]);
        end;
      utMaxHPHeal:
        begin
          Result.Icon := '💖';
          Result.Title := '딸기 케이크 (체력)';
          Result.Desc := Format('최대 체력 +30 증가 & HP 100%% 즉시 완전 회복' + sLineBreak + '(현재: %d HP -> 다음: %d HP)',
            [Round(FPlayerMaxHP), Round(FPlayerMaxHP + 30)]);
          if FMaxHPLevel = 0 then
            Result.Badge := 'NEW!'
          else
            Result.Badge := Format('Lv.%d', [FMaxHPLevel + 1]);
        end;
      utMagnetRadius:
        begin
          Result.Icon := '🧲';
          Result.Title := '달콤한 자석 (범위)';
          Result.Desc := Format('보석 흡수 범위 +45px 및 흡입 속도 대폭 증가' + sLineBreak + '(현재: Lv.%d -> 다음: Lv.%d)',
            [FMagnetLevel, FMagnetLevel + 1]);
          if FMagnetLevel = 0 then
            Result.Badge := 'NEW!'
          else
            Result.Badge := Format('Lv.%d', [FMagnetLevel + 1]);
        end;
      utEvoSeedGatling:
        begin
          Result.Icon := '✨🍓';
          Result.Title := '메가 딸기 개틀링';
          Result.Desc := '✨ [최종 진화] 사방으로 쉬지 않고 쏟아지는 8발 전방위 고속 연사 탄막!';
          Result.Badge := 'EVOLVED!';
        end;
      utEvoGalacticOrbit:
        begin
          Result.Icon := '✨🪐';
          Result.Title := '은하계 딸기 결계';
          Result.Desc := '✨ [최종 진화] 플레이어를 감싸는 초거대 7개 위성 궤도 & 닿는 적 분쇄!';
          Result.Badge := 'EVOLVED!';
        end;
      utEvoDarkRoast:
        begin
          Result.Icon := '✨☕';
          Result.Title := '다크 로스트 허리케인';
          Result.Desc := '✨ [최종 진화] 230px 초대형 회오리로 적을 빨아들인 뒤 폭발 넉백!';
          Result.Badge := 'EVOLVED!';
        end;
      utEvoPlasmaZap:
        begin
          Result.Icon := '✨⚡';
          Result.Title := '메가 비타민 플라즈마';
          Result.Desc := '✨ [최종 진화] 화면 내 9마리의 적을 동시에 타격하는 연쇄 벼락 폭풍!';
          Result.Badge := 'EVOLVED!';
        end;
    end;
  end;

begin
  FGameState := gsLevelUp;

  // 전체 업그레이드 풀 구성 (진화 조건 충족 시 진화 무기 우선 후보 편입)
  SetLength(Pool, 0);

  if (not FSeedEvolved) and (FSeedLevel >= 5) and (FAttackSpeedLevel >= 1) then
  begin
    SetLength(Pool, Length(Pool) + 1);
    Pool[High(Pool)] := utEvoSeedGatling;
  end;
  if (not FOrbitEvolved) and (FOrbitLevel >= 5) and (FMaxHPLevel >= 1) then
  begin
    SetLength(Pool, Length(Pool) + 1);
    Pool[High(Pool)] := utEvoGalacticOrbit;
  end;
  if (not FCoffeeEvolved) and (FCoffeeLevel >= 5) and (FMoveSpeedLevel >= 1) then
  begin
    SetLength(Pool, Length(Pool) + 1);
    Pool[High(Pool)] := utEvoDarkRoast;
  end;
  if (not FVitaminEvolved) and (FVitaminLevel >= 5) and (FMagnetLevel >= 1) then
  begin
    SetLength(Pool, Length(Pool) + 1);
    Pool[High(Pool)] := utEvoPlasmaZap;
  end;

  // 일반 스킬 추가
  var BaseSkills: array[0..7] of TUpgradeType := (
    utSeedCount, utAttackSpeed, utOrbitStrawberry, utCoffeePulse,
    utVitaminZap, utMoveSpeed, utMaxHPHeal, utMagnetRadius
  );
  for var B := 0 to 7 do
  begin
    SetLength(Pool, Length(Pool) + 1);
    Pool[High(Pool)] := BaseSkills[B];
  end;

  // 중복 없는 3가지 랜덤 선택
  for I := 1 to 3 do
  begin
    repeat
      PickIdx := Random(Length(Pool));
      Chosen[I] := Pool[PickIdx];
      Exists := False;
      for J := 1 to I - 1 do
      begin
        if Chosen[J] = Chosen[I] then
        begin
          Exists := True;
          Break;
        end;
      end;
    until not Exists;

    FCardOptions[I] := GetUpgradeInfo(Chosen[I]);
  end;

  // 카드 1 세팅
  lblCardIcon1.Text := FCardOptions[1].Icon;
  lblCardTitle1.Text := FCardOptions[1].Title;
  lblCardBadge1.Text := FCardOptions[1].Badge;
  lblCardDesc1.Text := FCardOptions[1].Desc;

  // 카드 2 세팅
  lblCardIcon2.Text := FCardOptions[2].Icon;
  lblCardTitle2.Text := FCardOptions[2].Title;
  lblCardBadge2.Text := FCardOptions[2].Badge;
  lblCardDesc2.Text := FCardOptions[2].Desc;

  // 카드 3 세팅
  lblCardIcon3.Text := FCardOptions[3].Icon;
  lblCardTitle3.Text := FCardOptions[3].Title;
  lblCardBadge3.Text := FCardOptions[3].Badge;
  lblCardDesc3.Text := FCardOptions[3].Desc;

  lytLevelUpModal.Visible := True;
  lytLevelUpModal.BringToFront;
end;

procedure TfrmGame.ApplyUpgrade(const AType: TUpgradeType);
begin
  case AType of
    utEvoSeedGatling:
      begin
        FSeedEvolved := True;
        AddFloatingText(FPlayerX, FPlayerY - 32, '✨ [진화] 메가 딸기 개틀링 완성!', $FFFFD166);
        PlaySoundBeep(1046, 200);
      end;
    utEvoGalacticOrbit:
      begin
        FOrbitEvolved := True;
        FOrbitLevel := 7; // 위성 7개 결계
        AddFloatingText(FPlayerX, FPlayerY - 32, '✨ [진화] 은하계 딸기 결계 완성!', $FFFFD166);
        PlaySoundBeep(1046, 200);
      end;
    utEvoDarkRoast:
      begin
        FCoffeeEvolved := True;
        AddFloatingText(FPlayerX, FPlayerY - 32, '✨ [진화] 다크 로스트 허리케인 완성!', $FFFFD166);
        PlaySoundBeep(1046, 200);
      end;
    utEvoPlasmaZap:
      begin
        FVitaminEvolved := True;
        AddFloatingText(FPlayerX, FPlayerY - 32, '✨ [진화] 메가 비타민 플라즈마 완성!', $FFFFD166);
        PlaySoundBeep(1046, 200);
      end;
    utSeedCount:
      begin
        Inc(FSeedLevel);
        AddFloatingText(FPlayerX, FPlayerY - 32, Format('🍓 씨앗 뿅뿅포 Lv.%d 강화!', [FSeedLevel]), $FFFF758F);
      end;
    utAttackSpeed:
      begin
        Inc(FAttackSpeedLevel);
        FAttackSpeedMultiplier := 1.0 + (FAttackSpeedLevel * 0.25);
        AddFloatingText(FPlayerX, FPlayerY - 32, Format('⚡ 공격 속도 Lv.%d (+%d%%)!', [FAttackSpeedLevel, FAttackSpeedLevel * 25]), $FFFFD166);
      end;
    utOrbitStrawberry:
      begin
        Inc(FOrbitLevel);
        AddFloatingText(FPlayerX, FPlayerY - 32, Format('🪐 딸기 위성 Lv.%d (+1개)!', [FOrbitLevel]), $FFFF758F);
      end;
    utCoffeePulse:
      begin
        Inc(FCoffeeLevel);
        AddFloatingText(FPlayerX, FPlayerY - 32, Format('☕ 에스프레소 파동 Lv.%d 강화!', [FCoffeeLevel]), $FFE09F3E);
      end;
    utVitaminZap:
      begin
        Inc(FVitaminLevel);
        AddFloatingText(FPlayerX, FPlayerY - 32, Format('⚡ 비타민 번개 Lv.%d 강화!', [FVitaminLevel]), $FFFFD166);
      end;
    utMoveSpeed:
      begin
        Inc(FMoveSpeedLevel);
        AddFloatingText(FPlayerX, FPlayerY - 32, Format('👟 이동 속도 Lv.%d (+%d%%)!', [FMoveSpeedLevel, FMoveSpeedLevel * 20]), $FF52B788);
      end;
    utMaxHPHeal:
      begin
        Inc(FMaxHPLevel);
        FPlayerMaxHP := 100 + (FMaxHPLevel * 30);
        FPlayerHP := FPlayerMaxHP;
        AddFloatingText(FPlayerX, FPlayerY - 32, Format('💖 최대 체력 %d HP 달성 & 완치!', [Round(FPlayerMaxHP)]), $FFFF4D6D);
      end;
    utMagnetRadius:
      begin
        Inc(FMagnetLevel);
        AddFloatingText(FPlayerX, FPlayerY - 32, Format('🧲 자석 범위 Lv.%d 강화!', [FMagnetLevel]), $FFE09F3E);
      end;
  end;

  UpdateHUDLabels;
  lytLevelUpModal.Visible := False;
  FGameState := gsPlaying;

  // 연속 레벨업 처리: 남은 경험치가 다음 레벨 필요량 이상이면 연속 모달 표시
  if FPlayerEXP >= FPlayerNextEXP then
    CheckLevelUp;
end;

procedure TfrmGame.rectCard1Click(Sender: TObject);
begin
  ApplyUpgrade(FCardOptions[1].UpgradeType);
end;

procedure TfrmGame.rectCard2Click(Sender: TObject);
begin
  ApplyUpgrade(FCardOptions[2].UpgradeType);
end;

procedure TfrmGame.rectCard3Click(Sender: TObject);
begin
  ApplyUpgrade(FCardOptions[3].UpgradeType);
end;

{ ============================================================================ }
{ 게임 오버 처리                                                               }
{ ============================================================================ }

procedure TfrmGame.OnGameOver;
var
  Secs: Integer;
  IsNewRecord: Boolean;
begin
  FGameState := gsGameOver;
  Secs := Trunc(FSurvivalSeconds);

  IsNewRecord := False;
  if Secs > FBestSurvivalSeconds then
  begin
    FBestSurvivalSeconds := Secs;
    IsNewRecord := True;
  end;
  if FStage > FBestStage then
  begin
    FBestStage := FStage;
    IsNewRecord := True;
  end;
  if FKills > FBestKills then FBestKills := FKills;
  if FPlayerLevel > FBestLevel then FBestLevel := FPlayerLevel;
  SaveBestScores;

  lblGameOverStats.Text := Format(
    '도달 스테이지: STAGE %d | 생존 시간: %0.2d:%0.2d' + sLineBreak +
    '퇴치한 방해 몬스터: %d마리 | 최종 레벨: Lv.%d',
    [FStage, Secs div 60, Secs mod 60, FKills, FPlayerLevel]
  );

  if IsNewRecord then
    lblGameOverBest.Text := Format('🎉 NEW RECORD! STAGE %d 달성 & 역대 최고 기록 갱신!', [FStage])
  else
    lblGameOverBest.Text := Format('🏆 최고 기록: STAGE %d, %0.2d:%0.2d (퇴치 %d마리, Lv.%d)', [FBestStage, FBestSurvivalSeconds div 60, FBestSurvivalSeconds mod 60, FBestKills, FBestLevel]);

  lytGameOverModal.Visible := True;
  lytGameOverModal.BringToFront;
end;

procedure TfrmGame.rectBtnRestartClick(Sender: TObject);
begin
  StartNewGame;
end;

procedure TfrmGame.rectBtnReturnTimerClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmGame.rectBtnPauseClick(Sender: TObject);
begin
  if FGameState = gsPlaying then
  begin
    FGameState := gsPaused;
    lblBtnPause.Text := '▶';
  end
  else if FGameState = gsPaused then
  begin
    FGameState := gsPlaying;
    lblBtnPause.Text := '⏸';
  end;
end;

procedure TfrmGame.rectBtnCloseGameClick(Sender: TObject);
begin
  Close;
end;

{ ============================================================================ }
{ 2D Skia 캔버스 렌더링 (아기자기 파스텔 그래픽)                              }
{ ============================================================================ }

procedure TfrmGame.pbGamePaint(Sender: TObject; Canvas: TCanvas);
var
  I: Integer;
  R: TRectF;
  HpRatio: Single;
begin
  Canvas.BeginScene;
  try
    // 1. 잔디밭/바닐라 파스텔 배경 및 부드러운 테두리 그리기 (고속 렌더링)
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := $FFFFFAF4;
    Canvas.FillRect(TRectF.Create(0, 0, pbGame.Width, pbGame.Height), 0, 0, [], 1.0);

    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Color := $FFF0E7DE;
    Canvas.Stroke.Thickness := 2.0;
    Canvas.DrawRect(TRectF.Create(2, 2, pbGame.Width - 2, pbGame.Height - 2), 0, 0, [], 1.0);

    // 2. 에스프레소 파동 충격파 링
    if FCoffeeWaveActive then
    begin
      Canvas.Stroke.Color := $FFE09F3E;
      Canvas.Stroke.Thickness := 3.0;
      R := TRectF.Create(
        FPlayerX - FCoffeeWaveRadius,
        FPlayerY - FCoffeeWaveRadius,
        FPlayerX + FCoffeeWaveRadius,
        FPlayerY + FCoffeeWaveRadius
      );
      Canvas.DrawEllipse(R, 0.7);
    end;

    // 3. 보석 및 드랍 아이템 그리기
    for I := Low(FGems) to High(FGems) do
    begin
      if not FGems[I].Active then Continue;

      R := TRectF.Create(
        FGems[I].X - FGems[I].Radius,
        FGems[I].Y - FGems[I].Radius,
        FGems[I].X + FGems[I].Radius,
        FGems[I].Y + FGems[I].Radius
      );

      case FGems[I].GemType of
        gtBomb:
          begin
            Canvas.Fill.Color := $FFFF3333; // 붉은 토마토 폭탄
            Canvas.FillEllipse(R, 1.0);
            Canvas.Stroke.Color := $FFFFFFFF;
            Canvas.Stroke.Thickness := 2.0;
            Canvas.DrawEllipse(R, 1.0);
            Canvas.Fill.Color := $FF2D6A4F;
            Canvas.FillRect(TRectF.Create(FGems[I].X - 2, FGems[I].Y - FGems[I].Radius - 3, FGems[I].X + 2, FGems[I].Y - FGems[I].Radius + 2), 1, 1, [], 1.0);
          end;
        gtChest:
          begin
            Canvas.Fill.Color := $FFFFD166; // 빛나는 황금 보물상자
            Canvas.FillRect(R, 2.5, 2.5, [], 1.0);
            Canvas.Stroke.Color := $FFFFFFFF;
            Canvas.Stroke.Thickness := 2.0;
            Canvas.DrawRect(R, 2.5, 2.5, [], 1.0);
          end;
        gtCake:
          begin
            Canvas.Fill.Color := $FFFF758F;
            Canvas.FillEllipse(R, 1.0);
            Canvas.Stroke.Color := $FFFFFFFF;
            Canvas.Stroke.Thickness := 2.0;
            Canvas.DrawEllipse(R, 1.0);
          end;
        gtMagnet:
          begin
            Canvas.Fill.Color := $FFE09F3E;
            Canvas.FillEllipse(R, 1.0);
            Canvas.Stroke.Color := $FFFFFFFF;
            Canvas.Stroke.Thickness := 2.0;
            Canvas.DrawEllipse(R, 1.0);
          end;
        gtGreen:
          begin
            Canvas.Fill.Color := $FF52B788;
            Canvas.FillEllipse(R, 0.9);
          end;
        gtBlue:
          begin
            Canvas.Fill.Color := $FF4EA8DE;
            Canvas.FillEllipse(R, 0.95);
          end;
        gtPink:
          begin
            Canvas.Fill.Color := $FFFF758F;
            Canvas.FillEllipse(R, 1.0);
            Canvas.Stroke.Color := $FFFFFFFF;
            Canvas.Stroke.Thickness := 1.5;
            Canvas.DrawEllipse(R, 1.0);
          end;
      end;
    end;

    // 4. 적 몬스터 그리기
    for I := Low(FEnemies) to High(FEnemies) do
    begin
      if not FEnemies[I].Active then Continue;

      R := TRectF.Create(
        FEnemies[I].X - FEnemies[I].Radius,
        FEnemies[I].Y - FEnemies[I].Radius,
        FEnemies[I].X + FEnemies[I].Radius,
        FEnemies[I].Y + FEnemies[I].Radius
      );

      // 피격 플래시 효과
      if FEnemies[I].FlashTimer > 0 then
      begin
        Canvas.Fill.Color := $FFFFFFFF;
      end
      else
      begin
        case FEnemies[I].EnemyType of
          etDust:   Canvas.Fill.Color := $FFD6C7E8; // 연보라 잡생각 먼지
          etSleepy: Canvas.Fill.Color := $FFBEE1E6; // 포근한 하늘빛 졸음
          etPhone:  Canvas.Fill.Color := $FFFFC2D1; // 분홍빛 스마트폰 유령
          etBoss:   // 거대 보스 (스테이지별 테마 색상)
            case FStage of
              1: Canvas.Fill.Color := $FF7B7CDB; // 1스테이지: 라벤더 퍼플 보스
              2: Canvas.Fill.Color := $FF3A86FF; // 2스테이지: 심해 네이비 블루 보스
              3: Canvas.Fill.Color := $FFFF006E; // 3스테이지: 네온 마젠타 핑크 보스
              4: Canvas.Fill.Color := $FFFF595E; // 4스테이지: 분노의 코랄 레드 보스
              else Canvas.Fill.Color := $FF8338EC; // 5스테이지+: 다크 사이버 퍼플
            end;
        end;
      end;

      Canvas.FillEllipse(R, 1.0);
      Canvas.Stroke.Color := $FFFFFFFF;
      Canvas.Stroke.Thickness := 1.5;
      Canvas.DrawEllipse(R, 1.0);

      // 보스 HP 바
      if FEnemies[I].EnemyType = etBoss then
      begin
        var BarHalfW := FEnemies[I].Radius + 12;
        var BossBar := TRectF.Create(FEnemies[I].X - BarHalfW, FEnemies[I].Y - (FEnemies[I].Radius + 16), FEnemies[I].X + BarHalfW, FEnemies[I].Y - (FEnemies[I].Radius + 10));
        Canvas.Fill.Color := $55000000;
        Canvas.FillRect(BossBar, 3, 3, [], 0.7);

        var CurRatio := Max(0.0, Min(1.0, FEnemies[I].HP / FEnemies[I].MaxHP));
        var BossFill := TRectF.Create(FEnemies[I].X - BarHalfW, FEnemies[I].Y - (FEnemies[I].Radius + 16), (FEnemies[I].X - BarHalfW) + (BarHalfW * 2) * CurRatio, FEnemies[I].Y - (FEnemies[I].Radius + 10));
        Canvas.Fill.Color := $FFFF4D6D;
        Canvas.FillRect(BossFill, 3, 3, [], 1.0);
      end;
    end;

    // 5. 투사체(씨앗) 그리기
    for I := Low(FProjectiles) to High(FProjectiles) do
    begin
      if not FProjectiles[I].Active then Continue;
      R := TRectF.Create(
        FProjectiles[I].X - FProjectiles[I].Radius,
        FProjectiles[I].Y - FProjectiles[I].Radius,
        FProjectiles[I].X + FProjectiles[I].Radius,
        FProjectiles[I].Y + FProjectiles[I].Radius
      );
      if FSeedEvolved then
        Canvas.Fill.Color := $FFFFD166 // 진화 개틀링: 황금빛 탄막
      else
        Canvas.Fill.Color := $FFFF758F;

      Canvas.Stroke.Color := $FFFFFFFF;
      Canvas.Stroke.Thickness := 1.5;
      Canvas.FillEllipse(R, 1.0);
      Canvas.DrawEllipse(R, 1.0);
    end;

    // 6. 가디언 딸기 위성 그리기
    if FOrbitLevel > 0 then
    begin
      var OrbitCount := FOrbitLevel;
      var OrbitDist: Single := IfThen(FOrbitEvolved, 75.0, 65.0);
      var SatSize: Single := IfThen(FOrbitEvolved, 13.0, 10.0);

      for var O := 0 to OrbitCount - 1 do
      begin
        var Ang := FOrbitAngle + (2 * Pi / OrbitCount) * O;
        var Ox := FPlayerX + Cos(Ang) * OrbitDist;
        var Oy := FPlayerY + Sin(Ang) * OrbitDist;

        R := TRectF.Create(Ox - SatSize, Oy - SatSize, Ox + SatSize, Oy + SatSize);
        if FOrbitEvolved then
          Canvas.Fill.Color := $FFFFD166 // 은하계 결계: 눈부신 골드 & 핑크
        else
          Canvas.Fill.Color := $FFFF758F;

        Canvas.FillEllipse(R, 1.0);
        Canvas.Stroke.Color := $FFFFFFFF;
        Canvas.Stroke.Thickness := 2.0;
        Canvas.DrawEllipse(R, 1.0);
      end;
    end;

    // 7. 플레이어 그리기
    R := TRectF.Create(
      FPlayerX - FPlayerRadius,
      FPlayerY - FPlayerRadius,
      FPlayerX + FPlayerRadius,
      FPlayerY + FPlayerRadius
    );

    // 대시 중 잔상 오라 또는 대시 준비 완료 발밑 링
    if FDashTimer > 0 then
    begin
      Canvas.Stroke.Color := $AAFF758F;
      Canvas.Stroke.Thickness := 3.0;
      Canvas.DrawEllipse(TRectF.Create(FPlayerX - FPlayerRadius - 6, FPlayerY - FPlayerRadius - 6, FPlayerX + FPlayerRadius + 6, FPlayerY + FPlayerRadius + 6), 0.8);
    end
    else if FDashCooldownTimer <= 0 then
    begin
      Canvas.Stroke.Color := $4452B788;
      Canvas.Stroke.Thickness := 1.8;
      Canvas.DrawEllipse(TRectF.Create(FPlayerX - 16, FPlayerY + FPlayerRadius - 2, FPlayerX + 16, FPlayerY + FPlayerRadius + 6), 0.6);
    end;

    // 무적 시간 깜빡임
    if (FInvincibleTimer <= 0) or ((Trunc(FInvincibleTimer * 20) mod 2) = 0) then
    begin
      // 캐릭터별 고유 바디 컬러
      case FSelectedChar of
        ctStrawberry: Canvas.Fill.Color := $FFFF758F; // 딸기 핑크
        ctEspresso:   Canvas.Fill.Color := $FF6F4E37; // 딥 에스프레소 브라운
        ctBunny:      Canvas.Fill.Color := $FFFFFAF0; // 부드러운 바닐라 크림 화이트
        ctTomato:     Canvas.Fill.Color := $FFFF4D6D; // 선명한 토마토 레드
      end;

      Canvas.FillEllipse(R, 1.0);
      Canvas.Stroke.Color := $FFFFFFFF;
      Canvas.Stroke.Thickness := 2.5;
      Canvas.DrawEllipse(R, 1.0);

      // 머리 위 장식 (토끼는 귀, 딸기/토마토는 꼭지, 에스프레소는 크레마)
      if FSelectedChar = ctBunny then
      begin
        Canvas.Fill.Color := $FFFFB3C1;
        Canvas.FillEllipse(TRectF.Create(FPlayerX - 9, FPlayerY - FPlayerRadius - 10, FPlayerX - 3, FPlayerY - FPlayerRadius + 2), 1.0);
        Canvas.FillEllipse(TRectF.Create(FPlayerX + 3, FPlayerY - FPlayerRadius - 10, FPlayerX + 9, FPlayerY - FPlayerRadius + 2), 1.0);
      end
      else
      begin
        Canvas.Fill.Color := $FF52B788;
        var LeafRect := TRectF.Create(FPlayerX - 6, FPlayerY - FPlayerRadius - 5, FPlayerX + 6, FPlayerY - FPlayerRadius + 2);
        Canvas.FillEllipse(LeafRect, 1.0);
      end;

      // 귀여운 눈망울
      Canvas.Fill.Color := $FF4A3E3D;
      var EyeL := TRectF.Create(FPlayerX - 6, FPlayerY - 4, FPlayerX - 2, FPlayerY);
      var EyeR := TRectF.Create(FPlayerX + 2, FPlayerY - 4, FPlayerX + 6, FPlayerY);
      Canvas.FillEllipse(EyeL, 1.0);
      Canvas.FillEllipse(EyeR, 1.0);

      // 발그레한 핑크 볼
      Canvas.Fill.Color := $FFFFB3C1;
      var CheekL := TRectF.Create(FPlayerX - 11, FPlayerY, FPlayerX - 7, FPlayerY + 3);
      var CheekR := TRectF.Create(FPlayerX + 7, FPlayerY, FPlayerX + 11, FPlayerY + 3);
      Canvas.FillEllipse(CheekL, 0.8);
      Canvas.FillEllipse(CheekR, 0.8);
    end;

    // 플레이어 머리 위 HP 게이지 바 (최대 체력 증가 시 가로 길이도 시각적으로 시원하게 늘어남!)
    if FPlayerMaxHP > 0 then
    begin
      HpRatio := Max(0.0, Min(1.0, FPlayerHP / FPlayerMaxHP));
      var BarW: Single := 36 + (FMaxHPLevel * 8);
      var BarLeft: Single := FPlayerX - (BarW / 2);
      var BarTop: Single := FPlayerY - FPlayerRadius - 14;
      var HpTrack := TRectF.Create(BarLeft, BarTop, BarLeft + BarW, BarTop + 5);
      Canvas.Fill.Color := $55000000;
      Canvas.FillRect(HpTrack, 2.5, 2.5, [], 0.6);

      var HpFill := TRectF.Create(BarLeft, BarTop, BarLeft + (BarW * HpRatio), BarTop + 5);
      if HpRatio > 0.4 then Canvas.Fill.Color := $FF52B788 else Canvas.Fill.Color := $FFFF4D6D;
      Canvas.FillRect(HpFill, 2.5, 2.5, [], 1.0);
    end;

    // 자석 업그레이드 시 은은한 자석 흡수 범위 링 시각화
    if FMagnetLevel > 0 then
    begin
      var MagRadius: Single := 60 + (FMagnetLevel * 45);
      Canvas.Stroke.Color := $28E09F3E; // 은은한 파스텔 골드 링
      Canvas.Stroke.Thickness := 1.5;
      Canvas.DrawEllipse(TRectF.Create(FPlayerX - MagRadius, FPlayerY - MagRadius, FPlayerX + MagRadius, FPlayerY + MagRadius), 0.5);
    end;

    // 8. 파티클 그리기
    for I := Low(FParticles) to High(FParticles) do
    begin
      if not FParticles[I].Active then Continue;
      R := TRectF.Create(
        FParticles[I].X - FParticles[I].Size / 2,
        FParticles[I].Y - FParticles[I].Size / 2,
        FParticles[I].X + FParticles[I].Size / 2,
        FParticles[I].Y + FParticles[I].Size / 2
      );
      Canvas.Fill.Color := FParticles[I].Color;
      Canvas.FillEllipse(R, FParticles[I].LifeTime / FParticles[I].MaxLife);
    end;

    // 9. 대미지 플로팅 텍스트
    Canvas.Font.Family := 'Malgun Gothic';
    Canvas.Font.Size := 12;
    Canvas.Font.Style := [TFontStyle.fsBold];
    for I := Low(FFloatingTexts) to High(FFloatingTexts) do
    begin
      if not FFloatingTexts[I].Active then Continue;
      R := TRectF.Create(FFloatingTexts[I].X - 60, FFloatingTexts[I].Y - 12, FFloatingTexts[I].X + 60, FFloatingTexts[I].Y + 12);
      Canvas.Fill.Color := FFloatingTexts[I].Color;
      Canvas.FillText(R, FFloatingTexts[I].Text, False, FFloatingTexts[I].LifeTime / FFloatingTexts[I].MaxLife, [], TTextAlign.Center, TTextAlign.Center);
    end;

    // 10. 하단 컨트롤 팁 및 대시 상태 표시
    Canvas.Font.Size := 11;
    Canvas.Font.Style := [];
    Canvas.Fill.Color := $664A3E3D;
    var DashStatus: string;
    if FDashCooldownTimer <= 0 then
      DashStatus := '💨 대시 준비완료 (Space / 우클릭)'
    else
      DashStatus := Format('⏳ 대시 쿨타임 (%.1fs)', [FDashCooldownTimer]);

    Canvas.FillText(
      TRectF.Create(14, pbGame.Height - 24, pbGame.Width - 14, pbGame.Height - 4),
      Format('%s  |  [1~4: 캐릭터 선택]', [DashStatus]),
      False, 0.75, [], TTextAlign.Leading, TTextAlign.Center
    );

    // 11. 일시정지 오버레이 표시
    if FGameState = gsPaused then
    begin
      Canvas.Fill.Color := $88241E30;
      Canvas.FillRect(TRectF.Create(0, 0, pbGame.Width, pbGame.Height), 0, 0, [], 1.0);

      Canvas.Font.Size := 24;
      Canvas.Fill.Color := $FFFFFFFF;
      Canvas.FillText(
        TRectF.Create(0, pbGame.Height / 2 - 40, pbGame.Width, pbGame.Height / 2 + 40),
        '⏸ 잠시 쉬어가는 중 (PAUSED)',
        False, 1.0, [], TTextAlign.Center, TTextAlign.Center
      );
    end;

  finally
    Canvas.EndScene;
  end;
end;

end.
