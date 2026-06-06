# DelforExp — Delphi 源代码格式化工具

## 程序信息

- **名称**：DelforExp（Delphi Formatter Expert）
- **版本**：2.4.1（原版支持 Delphi 2-7；当前代码已扩展支持至 RAD Studio XE4 及更高版本）
- **类别**：程序员工具

## 简介

DelforExp 是一个可自定义的 Delphi 源代码格式化工具。它可以改善 Delphi 源代码的缩进、空格、大小写和空行的使用。在默认设置下，格式化风格与 Borland 源代码风格保持一致。它以 IDE 专家（Expert）的形式集成在 Delphi IDE 中，通过"工具"菜单调用。

## 授权状态

本程序以免费软件（FREEWARE）形式发布，旨在提高 Delphi 开发效率。只要不以盈利为目的，您可以自由分发本程序。使用本程序的风险由使用者自行承担（详见 license.txt）。

源代码部分开放，以便用户自定义界面并适配未来的 Delphi 版本。格式化引擎以编译后的 DLL 形式提供。

## 项目结构

当前代码仓库已将源码按模块整理为以下目录结构：

```
DelForEx/
├── src/                        # IDE 专家插件源码（DelForEx.dll）
│   ├── DelForEx.dpr            # 主项目文件（DLL 库）
│   ├── DelForExpert.pas        # IDE 专家注册与菜单集成
│   ├── DelForOTAUtils.pas      # Open Tools API 工具函数（Delphi 9+）
│   ├── DelForCommon.pas        # 公共常量与工具
│   ├── Delfor1.pas             # 格式化主控逻辑
│   ├── DelforEng.pas           # 格式化引擎接口（调用 DelForDll）
│   ├── DelforTypes.pas         # 类型定义
│   ├── DelExpert.pas / .dfm    # 专家对话框
│   ├── OptDlg.pas / .dfm       # 选项设置对话框
│   ├── EditFile.pas / .dfm     # 文件编辑对话框
│   ├── progr.pas / .dfm        # 进度条对话框
│   ├── DockForm.pas / .dfm     # 停靠窗体
│   ├── MyIDEStream.pas         # IDE 流读写
│   ├── CnDebug.pas             # 调试输出工具（来自 CnPack）
│   ├── DelForEx.inc            # 编译条件定义（版本适配）
│   └── pgDelforex.groupproj    # 项目组文件
├── DelForDll/                  # 格式化引擎源码（DelForDll.dll）
│   ├── DelForDll.dpr           # DLL 项目文件
│   ├── DelforEngine.pas        # 解析/格式化引擎核心
│   ├── DelForInterf.pas        # DLL 导出接口
│   ├── OObjects.pas            # 对象结构定义
│   └── DelforTypes.pas         # 类型定义
├── SetupEx/                    # 安装/卸载工具
│   ├── SetupEx.dpr             # 安装程序项目文件
│   └── Setup1.pas              # 安装逻辑
├── .gitignore
└── README.md
```

## 支持的 Delphi 版本

通过 [DelForEx.inc](src/DelForEx.inc) 中的编译条件，当前代码支持以下版本：

| Delphi 版本 | 编译器版本常量 | 状态 |
|---|---|---|
| Delphi 2.0 | VER90 | 旧版支持 |
| Delphi 3.0 | VER100 | 旧版支持 |
| Delphi 4.0 | VER120 | 旧版支持 |
| Delphi 5.0 | VER130 | 旧版支持 |
| Delphi 6.0 | VER140 | 旧版支持 |
| Delphi 7.0 | VER150 | 旧版支持 |
| Delphi 9 (2005) | VER170 | 支持 |
| Delphi 10 (2006) | VER180 | 支持 |
| Delphi 11 (2007) | VER185/VER190 | 支持 |
| Delphi 12 (2009) | VER200 | 支持 |
| Delphi 14 (2010) | VER210 | 支持 |
| Delphi 15 (XE) | VER220 | 支持 |
| Delphi 16 (XE2) | VER230 | 支持 |
| Delphi 17 (XE3) | VER240 | 支持 |
| XE4 及更高版本 | CompilerVersion >= 25.0 | 通过 `{$IF CompilerVersion}` 统一支持 |

> **注意**：XE4 及以上版本使用 `{$IF CompilerVersion >= 25.0}` 条件统一处理，并使用 `{$LIBSUFFIX AUTO}` 自动匹配 IDE 的 RTL 版本号，无需再逐版本维护 `VERxxx` 宏。

## 安装方法

### 通过安装程序（推荐）

1. 编译 `SetupEx\SetupEx.dpr` 生成 SetupEx.exe
2. 关闭 Delphi IDE
3. 运行 SetupEx.exe
4. 重新启动 Delphi
5. "工具"菜单中应出现"Source Formatter..."菜单项

### 手动安装

在注册表中设置以下键值（将 `[Path]` 替换为实际路径）：

- **Delphi 7**：`HKEY_CURRENT_USER\Software\Borland\Delphi\7.0\Experts\DelForEx7` = `[Path]\DelForEx7.dll`
- **Delphi 6**：`HKEY_CURRENT_USER\Software\Borland\Delphi\6.0\Experts\DelForEx6` = `[Path]\DelForEx6.dll`
- **Delphi 5**：`HKEY_CURRENT_USER\Software\Borland\Delphi\5.0\Experts\DelForEx5` = `[Path]\DelForEx5.dll`
- **Delphi 4**：`HKEY_CURRENT_USER\Software\Borland\Delphi\4.0\Experts\DelForEx4` = `[Path]\DelForEx4.dll`
- **Delphi 3**：`HKEY_CURRENT_USER\Software\Borland\Delphi\3.0\Experts\DelForExp` = `[Path]\DelForEx3.dll`
- **Delphi 2**：`HKEY_CURRENT_USER\Software\Borland\Delphi\2.0\Experts\DelForEx` = `[Path]\DelForEx2.dll`

> **注意**：Delphi 9 (2005) 及以上版本使用 Open Tools API 注册专家，无需手动设置注册表。

## 编译说明

1. 先编译 `DelForDll\DelForDll.dpr`，生成格式化引擎 DLL
2. 再编译 `src\DelForEx.dpr`，生成 IDE 专家插件 DLL
3. 编译 `SetupEx\SetupEx.dpr`，生成安装程序

> **提示**：DFM 文件的版本为 Delphi 5。在更早版本的 Delphi 中编译时，请先打开所有对话框窗体并忽略错误提示，然后再编译。

## 卸载

1. 运行 SetupEx 程序卸载
2. 删除所有相关文件

## DelForDll 导出函数

格式化引擎 DLL 导出以下接口函数：

| 函数名 | 说明 |
|---|---|
| `Formatter_Create` | 创建格式化器实例 |
| `Formatter_Destroy` | 销毁格式化器实例 |
| `Formatter_LoadFromFile` | 从文件加载源代码 |
| `Formatter_LoadFromList` | 从字符串列表加载源代码 |
| `Formatter_Parse` | 执行格式化解析 |
| `Formatter_Clear` | 清除格式化器状态 |
| `Formatter_WriteToFile` | 将格式化结果写入文件 |
| `Formatter_GetTextStr` | 获取格式化后的文本 |
| `Formatter_SetTextStr` | 设置待格式化的文本 |
| `Formatter_SetOnProgress` | 设置进度回调 |
| `Formatter_LoadCapFile` | 加载大小写配置文件 |
| `Formatter_SaveCapFile` | 保存大小写配置文件 |
| `Formatter_Version` | 获取版本号 |

## 已知问题

1. **条件编译嵌套限制**：编译器 `{$IFDEF}` + `{$ELSE}` 指令嵌套超过 3 层后，无法保证正确的缩进。
2. **二次格式化**：使用对齐、添加换行等选项后，缩进可能不正确。再次运行 DelForExp 可修复此问题。
3. **函数指令缩进**：函数声明后的指令（如 `cdecl`、`overload` 等）在某些情况下无法正确缩进。
4. **断点和书签丢失**：格式化后断点和书签的位置不会自动更新（所有书签会被移到文件末尾，断点被删除）。
