@echo off
chcp 65001 >nul
setlocal

rem ===== DelForEx 注册脚本 (RAD Studio 13.1 / BDS 37.0) =====
set "REGKEY=HKCU\Software\Embarcadero\BDS\37.0\Experts"
set "DLL=%~dp0DelForEx370.dll"

echo.
echo  DelForEx 代码格式化插件 - 注册
echo  ----------------------------------------

if not exist "%DLL%" (
    echo  [错误] 找不到插件 DLL:
    echo         %DLL%
    echo  请确认本脚本与 DelForEx370.dll 在同一目录。
    goto :end
)

reg add "%REGKEY%" /v "DelForEx" /t REG_SZ /d "%DLL%" /f >nul
if errorlevel 1 (
    echo  [错误] 写入注册表失败。
    goto :end
)

echo  [成功] 已注册到 IDE:
echo         %DLL%
echo.
echo  请重启 RAD Studio,在 Tools 菜单查看格式化菜单项:
echo    源代码格式化       Ctrl+Shift+D
echo    格式化当前文件     Ctrl+D

:end
echo.
pause
endlocal
