@echo off
rem ============================================================
rem  Build command-line formatter test tool: DelForTest.exe
rem  Requires ..\release\DelForDll.dll (run repo-root build.bat first).
rem ============================================================
setlocal

set BDS=D:\DevDisk\DelphiDisk\DelphiXE13.1
set LIB=%BDS%\lib\win32\release
set ROOT=%~dp0

call "%BDS%\bin\rsvars.bat"
if errorlevel 1 goto :err_env

if not exist "%ROOT%dcu" mkdir "%ROOT%dcu"

cd /d "%ROOT%"
echo [Build] DelForTest.dpr ...
dcc32 -B DelForTest.dpr -E. -N0.\dcu -U"%LIB%" -U..\DelForDll -I..\DelForDll -NSSystem;Xml;Data;Datasnap;Web;Soap;Vcl;Winapi;System.Win;Data.Win -Q -W- -H-
if errorlevel 1 goto :err_build

echo.
echo [OK] %ROOT%DelForTest.exe
echo.
echo Usage: DelForTest.exe ^<input.pas^> [output.pas] [--style=NAME]
echo Styles: default borland rad opsg knr jcl
endlocal
exit /b 0

:err_env
echo [ERROR] rsvars.bat not found. Check BDS path: %BDS%
exit /b 1

:err_build
echo.
echo [FAIL] Compilation failed.
exit /b 1
