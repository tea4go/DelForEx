{ StartCloudIndexRefresh - 后台只拉一次云笔记索引，成功后写回本地缓存，条件性重绘 UI }
procedure TFrmMynotes.StartCloudIndexRefresh;
begin
    if FCloudIndexLoading then
        Exit;
    if (FGistToken = '') or (FGistId = '') then
        Exit;
    FCloudIndexLoading := True;
    StatusBar2.Caption := '[云笔记] 正在刷新索引...';
    TThread.CreateAnonymousThread(
        procedure
    var
        LoadOk: Boolean;
        ErrMsg: string;
        begin
            LoadOk := False;
            ErrMsg := '';
            try
                FGitMgr.Load;
                LoadOk := FGitMgr.Loaded;
            except
                on E: Exception do
                    ErrMsg := E.Message;
            end;
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
                                WriteELogs('[云笔记] 写本地缓存失败：%s', [E.Message]);
                        end;
                        StatusBar2.Caption := '[云笔记] 索引已刷新';
                        WriteLog('[云笔记] 后台索引刷新成功');
                        { 如果当前正显示云笔记面板，重绘分组 }
                        if (FCurLib <> nil) and (FCurLib.Caption = '云笔记') and
                            (FMyNotes = '云笔记') then
                            ReadCloudPath;
                    end
                    else
                    begin
                        StatusBar2.Caption := '[云笔记] 索引刷新失败';
                        WriteELogs('[云笔记] 后台索引刷新失败：%s', [ErrMsg]);
                    end;
                end);
        end).Start;
end;