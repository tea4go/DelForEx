@echo off
setlocal

rem ===== DelForEx uninstall script (RAD Studio 13.1 / BDS 37.0) =====
set "REGKEY=HKCU\Software\Embarcadero\BDS\37.0\Experts"

echo.
echo  DelForEx code formatter plugin - Uninstall
echo  ----------------------------------------

reg query "%REGKEY%" /v "DelForEx" >nul 2>&1
if errorlevel 1 (
    echo  [INFO] DelForEx not found in registry, nothing to remove.
    goto :end
)

reg delete "%REGKEY%" /v "DelForEx" /f >nul
if errorlevel 1 (
    echo  [ERROR] Failed to delete registry value.
    goto :end
)

echo  [OK] DelForEx unregistered from IDE.
echo.
echo  Restart RAD Studio for the change to take effect.
echo  The plugin DLL file is left in place; delete manually if you want a clean removal.

:end
echo.
pause
endlocal
