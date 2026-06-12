@echo off
rem ============================================================
rem  Build DelForEx IDE plugin DLL (RAD Studio 13.1 / Win32)
rem  Bypasses old .dproj vs new MSBuild targets incompatibility,
rem  compiles directly with dcc32.
rem  Location: repo root. Output: .\release\DelForEx370.dll
rem ============================================================
setlocal

set BDS=D:\DevDisk\DelphiDisk\DelphiXE13.1
set LIB=%BDS%\lib\win32\release
set ROOT=%~dp0

call "%BDS%\bin\rsvars.bat"
if errorlevel 1 goto :err_env

if not exist "%ROOT%release" mkdir "%ROOT%release"
if not exist "%ROOT%src\dcu" mkdir "%ROOT%src\dcu"
if not exist "%ROOT%DelForDll\dcu" mkdir "%ROOT%DelForDll\dcu"

rem ---- Step 1: build the formatter engine DLL (DelForDll.dll) ----
cd /d "%ROOT%DelForDll"
echo [Build] DelForDll.dpr ...
dcc32 -B DelForDll.dpr -E"%ROOT%release" -N0.\dcu -U"%LIB%" -I"%LIB%" -NSSystem;Xml;Data;Datasnap;Web;Soap;Vcl;Winapi;System.Win;Data.Win -DRELEASE -Q -W- -H-
if errorlevel 1 goto :err_build

rem ---- Step 2: build the IDE expert DLL (DelForEx370.dll) ----
rem .dpr uses relative unit paths, so compile from inside src
cd /d "%ROOT%src"

echo [Build] DelForEx.dpr ...
dcc32 -B DelForEx.dpr -E"%ROOT%release" -N0.\dcu -U"%LIB%" -I"%LIB%" -NSSystem;Xml;Data;Datasnap;Web;Soap;Vcl;Winapi;System.Win;Data.Win -DDELPHI9_UP;DELPHI6_UP;RELEASE -LUdesignide -Q -W- -H-
if errorlevel 1 goto :err_build

echo.
echo [OK] Output:
echo       %ROOT%release\DelForDll.dll       (formatter engine)
echo       %ROOT%release\DelForEx370.dll     (IDE plugin)
endlocal
exit /b 0

:err_env
echo [ERROR] rsvars.bat not found. Check BDS path: %BDS%
exit /b 1

:err_build
echo.
echo [FAIL] Compilation failed.
exit /b 1
