// ============================================================================
// 프로젝트: 델파이 12.3 (Athens) - 모던 뽀모도로 타이머 (Pomodoro Timer)
// 특징: FMX (FireMonkey) 네이티브 GPU 가속 (Direct2D / DirectX) 완전 단일 실행 파일 지원
// ============================================================================
program PomodoroTimer;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainForm in 'MainForm.pas' {frmMain},
  GameForm in 'GameForm.pas' {frmGame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmGame, frmGame);
  Application.Run;
end.
