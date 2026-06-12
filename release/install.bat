@echo off
setlocal

rem ===== DelForEx register script (RAD Studio 13.1 / BDS 37.0) =====
set "REGKEY=HKCU\Software\Embarcadero\BDS\37.0\Experts"
set "DLL=%~dp0DelForEx370.dll"

echo.
echo  DelForEx code formatter plugin - Install
echo  ----------------------------------------

if not exist "%DLL%" (
    echo  [ERROR] Plugin DLL not found:
    echo          %DLL%
    echo  Make sure this script sits next to DelForEx370.dll.
    goto :end
)

reg add "%REGKEY%" /v "DelForEx" /t REG_SZ /d "%DLL%" /f >nul
if errorlevel 1 (
    echo  [ERROR] Failed to write registry.
    goto :end
)

echo  [OK] Registered to IDE:
echo       %DLL%
echo.
echo  Restart RAD Studio. Look under Tools menu for:
echo    Source Format            Ctrl+Shift+D
echo    Format Current File      Ctrl+D

:end
echo.
pause
endlocal
