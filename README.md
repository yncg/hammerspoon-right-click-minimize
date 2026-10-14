# Hammerspoon 右键下滑最小化窗口

一个给 **Hammerspoon** 用的手势小脚本：按住**鼠标右键快速向下划**，当前窗口立刻最小化。

不开窗口、不点按钮、不碰键盘，纯手势操作。

---

## 一、这是什么软件用的？

### Hammerspoon 是什么

[Hammerspoon](https://www.hammerspoon.org/) 是一款 **macOS 上的开源自动化工具**。它本身几乎不带界面，而是给你一个 **Lua 脚本运行环境**，让你用代码去控制系统层面的能力：

| 能做什么 | 对应的 API |
|---|---|
| 监听键盘 / 鼠标事件，识别手势 | `hs.eventtap` |
| 控制窗口（移动、缩放、最小化、全屏） | `hs.window` |
| 获取 / 移动鼠标位置 | `hs.mouse` |
| 定时器、延时任务 | `hs.timer` |
| 屏幕弹窗提示 | `hs.alert` |
| 快捷键绑定 | `hs.hotkey` |
| 连接 WiFi、调节音量、控制 App 等 | 各类内置模块 |

可以把它理解成 macOS 版的 AutoHotkey（但用 Lua，且更接近系统底层）。所有功能都靠你写在 `~/.hammerspoon/init.lua` 里的脚本驱动。

### 本脚本用了哪些能力

- `hs.eventtap` —— 监听全局右键的**按下 / 拖动 / 抬起**三种事件，并根据位移和时间判定手势
- `hs.mouse` —— 读取鼠标实时坐标，计算拖动距离和方向
- `hs.window` —— 拿到当前焦点窗口并调用 `minimize()`
- `hs.timer` —— 记录手势耗时，过滤掉"慢慢拖"的操作
- `hs.alert` —— 启动时弹一个提示

---

## 二、效果

| 操作 | 结果 |
|---|---|
| 按住右键，**快速向下划**（>30px，0.8 秒内） | 当前窗口最小化 |
| 按住右键慢慢拖 | 无反应，正常弹出右键菜单 |
| 按住右键向上 / 左右划 | 无反应 |
| 单击右键（不拖动） | 正常弹出右键菜单 |

---

## 三、安装

### 第 1 步：安装 Hammerspoon

**方式 A — Homebrew（推荐）**

```bash
brew install --cask hammerspoon
```

**方式 B — 官网下载**

到 <https://www.hammerspoon.org/> 下载安装包，拖进「应用程序」。

**方式 C — 用本仓库自带的离线包（免下载）**

仓库内附了一份打包好的 Hammerspoon 应用，解压即用：

| 文件 | 版本 | 大小 |
|---|---|---|
| `Hammerspoon-1.1.1-macOS.zip` | 1.1.1 | 9.5 MB |

```bash
# 1. 解压
unzip Hammerspoon-1.1.1-macOS.zip

# 2. 移动到「应用程序」目录（需要管理员密码）
sudo mv Hammerspoon.app /Applications/

# 3. 如果是通过浏览器下载的，去掉隔离属性，避免"已损坏"提示
sudo xattr -dr com.apple.quarantine /Applications/Hammerspoon.app

# 4. 启动
open -a Hammerspoon
```

> **关于这个包**
> - 它是 Hammerspoon **官方原版应用**，未做任何修改，Apple 代码签名完整（Team ID `VQCYSNZB89`、Bundle ID `org.hammerspoon.Hammerspoon`）。
> - SHA256 校验值：`9ed882b8568f3547a60103e19800bfe9052adc7e1bdffcc99af20f55997ce9e6`
>   下载后可自行核对：`shasum -a 256 Hammerspoon-1.1.1-macOS.zip`
> - Hammerspoon 采用 **MIT 许可证**，允许自由再分发。原始项目：<https://github.com/Hammerspoon/hammerspoon>
> - 如果你想用**最新版本**，请优先使用方式 A 或方式 B，本包仅为方便离线/快速部署而附带的版本快照。

### 第 2 步：启动并授予权限（关键）

1. 打开 Hammerspoon，菜单栏会出现一个 🔨 图标。
2. 首次启动它会请求权限。**必须**在
   `系统设置 → 隐私与安全性 → 辅助功能`
   里勾选 **Hammerspoon**。
   > 没有这个权限，`hs.eventtap` 无法监听鼠标事件，手势会完全没反应。
3. 如果之前拒绝过，手动到上述位置补勾选，然后重启 Hammerspoon。

### 第 3 步：放入脚本

把本仓库的 `init.lua` 放到 Hammerspoon 的配置目录：

```bash
mkdir -p ~/.hammerspoon
cp init.lua ~/.hammerspoon/init.lua
```

> 如果你已经有 `~/.hammerspoon/init.lua` 并且在用别的配置，**不要直接覆盖**，
> 把本文件的内容**追加**到你的 init.lua 末尾即可。

### 第 4 步：加载

点菜单栏 🔨 → **Reload Config**。

看到弹窗提示 `右键手势: 快速下滑最小化窗口` 就说明加载成功了。

---

## 四、参数调整

打开 `init.lua`，文件顶部有两个可调参数：

```lua
local MIN_DISTANCE = 30   -- 触发所需的最小垂直拖动距离（像素）
local MAX_TIME = 0.8      -- 手势允许的最长持续时间（秒）
```

- **觉得手势太容易误触发** → 把 `MIN_DISTANCE` 调大（如 `50`），或把 `MAX_TIME` 调小（如 `0.5`）
- **觉得划了没反应** → 把 `MIN_DISTANCE` 调小（如 `20`），或把 `MAX_TIME` 调大（如 `1.2`）

改完记得 **Reload Config**。

---

## 五、工作原理

```
右键按下 (rightMouseDown)
    └─ 记录起点坐标 startPos + 起始时间 startTime
           ↓
       拖动中 (rightMouseDragged)
    └─ 持续更新垂直位移 dragDistance
           ↓
       右键抬起 (rightMouseUp)
    └─ 判定三个条件同时满足：
        ① dragDistance > MIN_DISTANCE   （划得够远）
        ② timeTaken  < MAX_TIME         （划得够快）
        ③ deltaY     > 0                （方向朝下）
              ↓
        满足 → doMinimize() 最小化焦点窗口，并 return true 吞掉事件
        不满足 → return false，事件正常传递给系统（弹出右键菜单）
```

`return true` 这一步很关键：它会让 Hammerspoon **拦截**这个右键事件，这样最小化窗口的同时不会弹出右键菜单。如果判定不通过就 `return false`，把事件放行，保证你平时正常点右键不受影响。

---

## 六、自定义扩展

脚本目前只保留了下滑。如果你想加**上滑全屏**、**左滑关闭窗口**之类的手势，在判定处横向对比 `currentPos.x` 和 `startPos.x` 即可，例如：

```lua
-- 在 rightMouseUp 分支里，替换原有判定
local deltaX = currentPos.x - GestureData.startPos.x

if distanceY > MIN_DISTANCE and timeTaken < MAX_TIME then
    if deltaY > 0 then
        -- 下滑：最小化
        window.focusedWindow():minimize()
    elseif deltaY < 0 then
        -- 上滑：切换全屏
        local win = window.focusedWindow()
        if win then win:setFullScreen(not win:isFullScreen()) end
    end
    GestureData.startPos = nil
    return true
end
```

---

## 七、常见问题

**手势完全没反应？**
检查 `系统设置 → 隐私与安全性 → 辅助功能` 里 Hammerspoon 是否被勾选。这是最常见的原因。

**弹出右键菜单，但窗口没最小化？**
说明划得太慢或距离不够。调大 `MAX_TIME` 或调小 `MIN_DISTANCE`。

**窗口没最小化，提示"无焦点窗口"？**
桌面（Finder 桌面本身）没有可最小化的窗口，属于正常情况。

**想看日志？**
点菜单栏 🔨 → **Console**，脚本里的 `print` 输出都会显示在那里。

**和某些 App 的右键手势冲突？**
本脚本只在"快速下滑"时吞事件，普通右键点击不受影响。若仍有冲突，可调大 `MIN_DISTANCE`。

---

## 八、环境要求

- macOS
- [Hammerspoon](https://www.hammerspoon.org/)（任意较新版本）
- 已授予「辅助功能」权限

---

## 九、License

MIT
