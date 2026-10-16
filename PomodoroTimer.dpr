// ============================================================================
// 프로젝트: 델파이 12.3 (Athens) - 모던 뽀모도로 타이머 (Pomodoro Timer)
// 특징: FMX (FireMonkey) 크로스플랫폼 기반 + Skia 2D 하드웨어 가속 지원
// ============================================================================
program PomodoroTimer;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia, // 델파이 12에 기본 내장된 Skia 엔진 연동
  MainForm in 'MainForm.pas' {frmMain},
  GameForm in 'GameForm.pas' {frmGame};

{$R *.res}

begin
  // 델파이 12의 고성능 2D Skia 렌더링 활성화 (안티앨리어싱 및 부드러운 벡터 그래픽)
  GlobalUseSkia := True;

  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmGame, frmGame);
  Application.Run;
end.
