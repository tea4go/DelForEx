unit TestAnon;

interface

implementation

uses
Classes, SysUtils;

procedure TestAnonymous;
begin
TThread.Synchronize(nil,
procedure
begin
FCloudIndexLoading := False;
if LoadOk then
begin
try
FGitMgr.SaveToLocalCache(FQNoteCacheFile);
except
on E: Exception do
WriteELogs('[Error] %s', [E.Message]);
end;
StatusBar2.Caption := 'Done';
WriteLog('refresh ok');
end
else
begin
StatusBar2.Caption := 'Failed';
WriteELogs('[Error] %s', [ErrMsg]);
end;
end);
end;

end.
