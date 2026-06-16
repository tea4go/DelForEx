@echo off
rem ============================================================
rem  Build DelForEx IDE plugin DLL (RAD Studio 13.1 / Win32)
rem  Bypasses old .dproj vs new MSBuild targets incompatibility,
rem  compiles directly with dcc32.
rem  Location: repo root. Output: .\release\DelForEx370.dll
rem
rem  Usage:
rem    build.bat            只编译,输出到 .\release
rem    build.bat install    编译后杀掉 bds.exe 并把两个 DLL
rem                         复制到已安装的插件目录(见 INSTALLDIR)
rem ============================================================
setlocal

set BDS=D:\DevDisk\DelphiDisk\DelphiXE13.1
set LIB=%BDS%\lib\win32\release
set ROOT=%~dp0
rem 已安装的 IDE 插件目录(注册表 HKCU\...\37.0\Experts\DelForEx 实际指向此处)
set INSTALLDIR=C:\DevDisk\DelphiDisk\DelphiXE13.1\Extra\DelForEx

rem 带 install 参数时,编译后复制 DLL 到 INSTALLDIR(复制前杀掉 bds.exe)
set DOINSTALL=0
if /I "%~1"=="install" set DOINSTALL=1

call "%BDS%\bin\rsvars.bat"
if errorlevel 1 goto :err_env

if not exist "%ROOT%release" mkdir "%ROOT%release"
if not exist "%ROOT%src\dcu" mkdir "%ROOT%src\dcu"
if not exist "%ROOT%DelForDll\dcu" mkdir "%ROOT%DelForDll\dcu"

rem ---- 生成 build 时间戳到 src\DelForBuild.inc(供 DelForVer.inc 引入) ----
rem 用 cmd 内建 %DATE%/%TIME%(去掉毫秒),不依赖 PowerShell/wmic
set BUILDTS=%DATE% %TIME%
set BUILDTS=%BUILDTS:~0,19%
echo   DelForBuildStr = '%BUILDTS%';> "%ROOT%src\DelForBuild.inc"
echo [Build] timestamp: %BUILDTS%

rem ---- Step 1: build the formatter engine DLL (DelForDll.dll) ----
cd /d "%ROOT%DelForDll"
echo [Build] DelForDll.dpr ...
dcc32 -B DelForDll.dpr -E"%ROOT%release" -N0.\dcu -U"%LIB%" -I"%LIB%" -NSSystem;Xml;Data;Datasnap;Web;Soap;Vcl;Winapi;System.Win;Data.Win -DRELEASE -Q -W- -H-
if errorlevel 1 goto :err_build

rem ---- Step 2: build the IDE expert DLL (DelForEx370.dll) ----
rem .dpr uses relative unit paths, so compile from inside src
cd /d "%ROOT%src"

echo [Build] DelForEx.dpr ...
dcc32 -B DelForEx.dpr -E"%ROOT%release" -N0.\dcu -U"%LIB%" -I"%LIB%" -NSSystem;Xml;Data;Datasnap;Web;Soap;Vcl;Winapi;System.Win;Data.Win -DDELPHI9_UP;DELPHI6_UP;RELEASE;DELFOR_HASBUILD -LUdesignide -Q -W- -H-
if errorlevel 1 goto :err_build

echo.
echo [OK] Output:
echo       %ROOT%release\DelForDll.dll       (formatter engine)
echo       %ROOT%release\DelForEx370.dll     (IDE plugin)

if "%DOINSTALL%"=="0" goto :done

rem ---- Step 3 (install): kill IDE, copy DLLs to installed plugin dir ----
echo.
echo [Install] Target: %INSTALLDIR%

if not exist "%INSTALLDIR%\" (
    echo [ERROR] Install dir not found: %INSTALLDIR%
    goto :err_build
)

rem 杀掉 bds.exe,否则已加载的 DLL 被锁定无法覆盖。
rem taskkill 对未运行的进程返回非 0,无副作用,故不预先用 tasklist 探测。
echo [Install] Closing bds.exe (if running) ...
"%SystemRoot%\System32\taskkill.exe" /F /IM bds.exe >nul 2>&1
rem 等待文件句柄释放(用绝对路径避免 PATH 问题)
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul 2>&1

copy /Y "%ROOT%release\DelForDll.dll" "%INSTALLDIR%\DelForDll.dll" >nul
if errorlevel 1 goto :err_copy
copy /Y "%ROOT%release\DelForEx370.dll" "%INSTALLDIR%\DelForEx370.dll" >nul
if errorlevel 1 goto :err_copy
echo [Install] OK: DLLs copied. Restart RAD Studio to load the new build.

:done
endlocal
exit /b 0

:err_copy
echo [FAIL] Copy to install dir failed: %INSTALLDIR%
endlocal
exit /b 1

:err_env
echo [ERROR] rsvars.bat not found. Check BDS path: %BDS%
exit /b 1

:err_build
echo.
echo [FAIL] Compilation failed.
exit /b 1
