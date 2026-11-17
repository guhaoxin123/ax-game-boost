# 全机型游戏高刷加速

<img src="banner.jpg" width="100%">

进游戏自动拉满刷新率与触控响应，退出一键复原。基于 `settings` 参数，免 ROOT，全机型通用。

## 功能
- 游戏时把 `peak_refresh_rate` / `min_refresh_rate` 推到屏幕最高档（60 / 90 / 120Hz 自适应）
- 提高触控采样与响应（`touch.resample`、`touch.size.scale` 等）
- 放宽温控与调度门槛（`thermal_limit.cpu/gpu`、`scheduler.boost`）
- 退出一键还原全部参数
- 操作按钮打印当前刷新率、SOC、GPU 驱动等信息

## 安装
1. 到 [Releases](../../releases) 下载 `ax-game-boost-v1.1.zip`
2. AxManager / 模块管理器里从本地导入该 zip
3. 重启生效；操作按钮可随时手动触发一次

## 文件
| 文件 | 说明 |
|---|---|
| `module.prop` | 模块信息 |
| `customize.sh` | 安装时检测机型与刷新率档位 |
| `post-fs-data.sh` / `service.sh` | 开机与常驻逻辑 |
| `action.sh` | 操作按钮：手动执行 / 查看状态 |
| `banner.jpg` | 模块头图 |

## 说明
作者 ghx；本仓库由 DSH 整理、重命名并统一打包。
