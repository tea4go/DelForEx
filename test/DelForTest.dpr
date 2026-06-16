program DelForTest;

{$APPTYPE CONSOLE}

{ 命令行格式化测试工具 - 加载 DelForDll.dll，格式化指定 .pas 文件并输出结果。

  用法:
    DelForTest.exe <input.pas> [output.pas] [--style=NAME]

  参数:
    input.pas      待格式化的源文件(必填)
    output.pas     输出文件;省略时输出到 stdout
    --style=NAME   预设风格,可选: default borland rad opsg knr jcl
                   默认 borland

  说明:
    直接复用引擎源码的 DelForTypes(uses)，TSettings 布局与引擎完全一致,
    不会有跨 DLL 字段偏移错配。格式化效果与 IDE 内 Ctrl+D 一致(同一引擎 DLL)。
}

uses
  SysUtils,
  Classes,
  Windows,
  DelForTypes in '..\DelForDll\DelForTypes.pas';

var
  DllHandle: THandle;
  DllPath, InFile, OutFile, StyleName: string;
  Settings: TSettings;
  SL: TStringList;
  AnsiText: AnsiString;
  ResultPtr: PAnsiChar;
  I: Integer;

  Formatter_Create: procedure;
  Formatter_Destroy: procedure;
  Formatter_SetTextStr: procedure(AText: PAnsiChar);
  Formatter_GetTextStr: function: PAnsiChar;
  Formatter_Parse: function(S: PSettings; size: Integer): Boolean;
  Formatter_Clear: procedure;

{ ---- 预设风格(与 src\Delfor1.pas 中 SetXxx 保持一致) ---- }

procedure StyleDefault(var S: TSettings);
begin
  FillChar(S, SizeOf(S), 0);
  S.WrapPosition := 255;  { Byte 上限;原插件用 401 会溢出,这里取最大值表示"基本不换行" }
  S.AlignCommentPos := 40;
  S.AlignVarPos := 20;
  S.SpaceEqualOper := spBoth;
  S.SpaceOperators := spBoth;
  S.SpaceColon := spAfter;
  S.SpaceComma := spAfter;
  S.SpaceSemiColon := spAfter;
  S.SpaceLeftBr := spNone;
  S.SpaceRightBr := spNone;
  S.SpaceLeftHook := spNone;
  S.SpaceRightHook := spNone;
  S.ReservedCase := rfLowerCase;
  S.StandDirectivesCase := rfLowerCase;
  S.ChangeIndent := True;
  S.UpperCompDirectives := True;
  S.UpperNumbers := True;
  S.SpacePerIndent := 2;
  S.BlankProc := True;
  S.FeedRoundBegin := UnChanged;
  S.FillNewWords := fmUnchanged;
  StrCopy(S.StartCommentOut, '{(*}');
  StrCopy(S.EndCommentOut, '{*)}');
end;

procedure StyleBorland(var S: TSettings);
begin
  StyleDefault(S);
  S.WrapLines := True;
  S.IndentComments := True;
  S.FeedAfterThen := True;
  S.NoFeedBeforeThen := True;
  S.FeedAfterVar := True;
  S.FeedBeforeEnd := True;
  S.FeedRoundBegin := NewLine;
  S.FeedAfterSemiColon := True;
  S.RemoveDoubleBlank := True;
end;

procedure StyleRAD(var S: TSettings);
begin
  StyleDefault(S);
  S.WrapLines := True;
  S.WrapPosition := 80;
  S.FeedRoundBegin := NewLine;
  S.FeedBeforeEnd := True;
  S.IndentComments := True;
  S.BlankProc := True;
end;

procedure StyleOPSG(var S: TSettings);
begin
  StyleDefault(S);
  S.WrapLines := True;
  S.WrapPosition := 80;
  S.FeedRoundBegin := NewLine;
  S.FeedBeforeEnd := True;
  S.FeedAfterThen := True;
  S.ExceptSingle := True;
  S.FeedAfterVar := True;
  S.FeedAfterSemiColon := True;
  S.BlankProc := True;
  S.RemoveDoubleBlank := True;
  S.AlignVar := True;
  S.AlignVarPos := 20;
  S.IndentComments := True;
end;

procedure StyleKNR(var S: TSettings);
begin
  StyleDefault(S);
  S.WrapLines := False;
  S.FeedRoundBegin := UnChanged;
  S.ExceptSingle := True;
  S.FeedBeforeEnd := True;
  S.RemoveDoubleBlank := True;
  S.BlankProc := False;
end;

procedure StyleJCL(var S: TSettings);
begin
  StyleDefault(S);
  S.WrapLines := True;
  S.WrapPosition := 100;
  S.FeedRoundBegin := NewLine;
  S.FeedAfterThen := True;
  S.FeedBeforeEnd := True;
  S.FeedAfterVar := True;
  S.FeedAfterSemiColon := True;
  S.RemoveDoubleBlank := True;
  S.BlankProc := True;
  S.IndentComments := True;
  S.AlignComments := True;
  S.AlignCommentPos := 40;
  S.CommentFunction := True;
end;

procedure ApplyStyle(const Name: string; var S: TSettings);
begin
  if SameText(Name, 'default') then StyleDefault(S)
  else if SameText(Name, 'rad') then StyleRAD(S)
  else if SameText(Name, 'opsg') then StyleOPSG(S)
  else if SameText(Name, 'knr') then StyleKNR(S)
  else if SameText(Name, 'jcl') then StyleJCL(S)
  else StyleBorland(S);  { 默认 borland }
end;

function BindProc(const AName: AnsiString): Pointer;
begin
  Result := GetProcAddress(DllHandle, PAnsiChar(AName));
  if Result = nil then
  begin
    Writeln(ErrOutput, 'ERROR: can not find exported function ', AName);
    Halt(2);
  end;
end;

begin
  StyleName := 'borland';
  InFile := '';
  OutFile := '';

  { 解析命令行参数 }
  for I := 1 to ParamCount do
  begin
    if Copy(ParamStr(I), 1, 8) = '--style=' then
      StyleName := Copy(ParamStr(I), 9, MaxInt)
    else if InFile = '' then
      InFile := ParamStr(I)
    else if OutFile = '' then
      OutFile := ParamStr(I);
  end;

  if InFile = '' then
  begin
    Writeln(ErrOutput, '用法: DelForTest.exe <input.pas> [output.pas] [--style=NAME]');
    Writeln(ErrOutput, '风格: default borland rad opsg knr jcl');
    Halt(1);
  end;

  if not FileExists(InFile) then
  begin
    Writeln(ErrOutput, 'ERROR: 输入文件不存在: ', InFile);
    Halt(1);
  end;

  { 加载引擎 DLL(优先 release 目录) }
  DllPath := ExtractFilePath(ParamStr(0)) + '..\release\DelForDll.dll';
  if not FileExists(DllPath) then
    DllPath := 'DelForDll.dll';
  DllHandle := LoadLibraryW(PWideChar(WideString(DllPath)));
  if DllHandle = 0 then
  begin
    Writeln(ErrOutput, 'ERROR: 无法加载 DLL: ', DllPath);
    Halt(2);
  end;

  @Formatter_Create := BindProc('Formatter_Create');
  @Formatter_Destroy := BindProc('Formatter_Destroy');
  @Formatter_SetTextStr := BindProc('Formatter_SetTextStr');
  @Formatter_GetTextStr := BindProc('Formatter_GetTextStr');
  @Formatter_Parse := BindProc('Formatter_Parse');
  @Formatter_Clear := BindProc('Formatter_Clear');

  ApplyStyle(StyleName, Settings);

  SL := TStringList.Create;
  try
    SL.LoadFromFile(InFile);
    AnsiText := AnsiString(SL.Text);

    Formatter_Create;
    try
      Formatter_SetTextStr(PAnsiChar(AnsiText));
      if not Formatter_Parse(@Settings, SizeOf(Settings)) then
      begin
        Writeln(ErrOutput, 'ERROR: Formatter_Parse 返回 FALSE');
        Halt(3);
      end;
      ResultPtr := Formatter_GetTextStr;

      if OutFile <> '' then
      begin
        SL.Text := string(AnsiString(ResultPtr));
        SL.SaveToFile(OutFile);
        Writeln(ErrOutput, 'OK: 已写入 ', OutFile, ' (风格=', StyleName, ')');
      end
      else
        Write(string(AnsiString(ResultPtr)));
    finally
      Formatter_Destroy;
    end;
  finally
    SL.Free;
    FreeLibrary(DllHandle);
  end;
end.
