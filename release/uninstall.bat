@echo off
chcp 65001 >nul
setlocal

rem ===== DelForEx 卸载脚本 (RAD Studio 13.1 / BDS 37.0) =====
set "REGKEY=HKCU\Software\Embarcadero\BDS\37.0\Experts"

echo.
echo  DelForEx 代码格式化插件 - 卸载
echo  ----------------------------------------

reg query "%REGKEY%" /v "DelForEx" >nul 2>&1
if errorlevel 1 (
    echo  [提示] 注册表中未找到 DelForEx,无需卸载。
    goto :end
)

reg delete "%REGKEY%" /v "DelForEx" /f >nul
if errorlevel 1 (
    echo  [错误] 删除注册表项失败。
    goto :end
)

echo  [成功] 已从 IDE 注销 DelForEx。
echo.
echo  请重启 RAD Studio 使更改生效。
echo  插件 DLL 文件未删除,如需彻底清理可手动删除本目录。

:end
echo.
pause
endlocal
