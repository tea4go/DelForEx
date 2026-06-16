{ DelForEx 版本信息 - 同时被插件(src)和引擎(DelForDll)使用。
  主版本号在此手动维护。build 时间字符串由 build.bat 在每次编译时
  生成到 DelForBuild.inc(该文件不纳入版本库,见 .gitignore)。}

const
  DelForVerMajor = '2.5';

{$IFDEF DELFOR_HASBUILD}
  {$I DelForBuild.inc}   // 定义 DelForBuildStr,由 build.bat 生成
{$ELSE}
  DelForBuildStr = 'dev';  // IDE 内直接编译(未经 build.bat)时的占位
{$ENDIF}

  DelForVersionStr = DelForVerMajor + ' (build ' + DelForBuildStr + ')';
