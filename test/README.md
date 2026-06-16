# DelForEx 命令行格式化测试工具

无需启动 RAD Studio，直接在命令行验证格式化效果。使用与 IDE 内
Ctrl+D 完全相同的引擎 DLL（`..\release\DelForDll.dll`）。

## 编译

先确保引擎 DLL 已生成（在仓库根目录运行 `build.bat`），然后：

```
test\build_test.bat
```

产物：`test\DelForTest.exe`

## 用法

```
DelForTest.exe <input.pas> [output.pas] [--style=NAME]
```

| 参数 | 说明 |
|---|---|
| `input.pas` | 待格式化的源文件（必填） |
| `output.pas` | 输出文件；省略时格式化结果打印到 stdout |
| `--style=NAME` | 预设风格，默认 `borland` |

可选风格：`default` `borland` `rad` `opsg` `knr` `jcl`
（与 `src\Delfor1.pas` 中的 `SetXxx` 预设保持一致）

## 示例

```
rem 格式化并打印到屏幕
DelForTest.exe samples\anon_method.pas

rem 用 K&R 风格，写入新文件
DelForTest.exe samples\anon_method.pas out.pas --style=knr

rem 对比格式化前后（PowerShell）
DelForTest.exe samples\anon_method.pas > after.pas
fc samples\anon_method.pas after.pas
```

## 调测建议

修改引擎 `DelForDll\*.pas` 后的快速验证循环：

```
build.bat                              rem 重新编译引擎
test\build_test.bat                    rem 重新编译测试工具
test\DelForTest.exe test\samples\anon_method.pas   rem 看效果
```

## 实现说明

测试工具通过 `uses DelForTypes in '..\DelForDll\DelForTypes.pas'`
直接复用引擎源码的 `TSettings` 定义，因此结构体布局与引擎完全一致，
不存在跨 DLL 字段偏移错配的风险。DLL 函数通过 `GetProcAddress` 动态
绑定，调用约定为 `register`（与引擎导出一致）。
