# WorkSpace Plus Group

Enhanced workspace management for Obsidian's built-in Workspaces core plugin — workspace hierarchy, mode switching, and quickly switch workspaces via shortcut keys.  
增强 Obsidian 原生 Workspaces 核心插件，提供工作区层级管理、模式切换和通过快捷键快速切换工作区。

> **Prerequisite / 前提**：Enable the **Workspaces** core plugin in Settings → Core Plugins.  
> 需先在 设置 → 核心插件 中启用 **Workspaces** 插件。

---

## Features / 功能

### Quick Workspace Switcher / 快速切换

Open via command palette or click the status bar workspace name or bind shortcut keys(**recommend shift+tab**). Fuzzy search with keyboard shortcuts — type a new name and press **Enter** to create a new workspace.  
通过命令面板或状态栏或快捷键(**推荐 shift+tab**)打开，模糊搜索，输入新名称按 **Enter** 直接创建新工作区。
![](https://github.com/cnwenzhihong/Obsidian-workspace-plus-group/blob/main/docs/Assets/Example_pop.png)

### Workspace Hierarchy / 工作区层级

Drag and drop workspaces in the settings panel to build parent-child relationships, clearly displayed with indentation in the switcher modal.  
在设置面板拖拽建立父子层级，弹窗中带缩进显示。

| Operation / 操作 | EN | 中文 |
|------|----|------|
| Make Child / 建立父子 | Drag onto the row **center** (solid outline) → becomes a child | 拖到行中央（实线框）→ 成为子工作区 |
| Reorder / 同级排序 | Drag to the row **edge** 25% (colored insertion line) → adjust sibling order | 拖到边缘 25%（彩色插入线）→ 同级排序 |
| Collapse/Expand / 折叠展开 | Click the triangle left of a parent | 点击父工作区左侧三角按钮 |

![](https://github.com/cnwenzhihong/Obsidian-workspace-plus-group/blob/main/docs/Assets/Example_Settings.png)

### Workspace Modes / 工作区模式

Bind independent Obsidian global settings (theme, font, etc.) to each workspace. Switching applies them automatically.  
为每个工作区绑定独立设置方案，切换时自动应用。

### Status Bar / 状态栏

Shows current workspace and mode. **Shift+Click** to save.  
显示当前名称，Shift+Click 快速保存。

---

## Settings / 设置

| Setting / 设置 | EN | 中文 |
|---------|----|------|
| Auto-save layout / 自动保存布局 | Save on any layout change | 布局变更时自动保存 |
| Delete confirmation / 删除确认 | Show confirmation before deleting | 删除前显示确认提示 |
| Sidebar ribbon icon / Ribbon 图标 | Show workspace switcher ribbon button | 显示工作区切换 Ribbon 按钮 |
| Workspace Modes / 工作区模式 | Enable per-workspace settings (beta) | 启用独立工作区设置 (beta) |
| Mode ribbon icon / 模式 Ribbon | Show mode switcher ribbon button | 显示模式切换 Ribbon 按钮 |
| System dark mode / 系统深色模式 | Follow OS light/dark when switching modes | 切换模式时跟随系统亮/暗 |
| Live Preview auto-reload / 自动重载 | Reload Obsidian on Live Preview change | Live Preview 变更时自动重载 |
| Workspace Hierarchy / 工作区层级 | Drag-and-drop tree view | 拖拽树形视图管理父子关系 |
| Modal collapse rule / 弹窗折叠规则 | Collapse behavior in switcher (4 modes) | 弹窗中折叠行为（4 种模式） |

### Modal Collapse Rules / 弹窗折叠规则

| Mode / 模式 | EN | 中文 |
|------|----|------|
| Inherit from settings / 继承插件设置 | Syncs with settings panel | 与设置面板折叠状态同步 |
| Save independently / 弹窗独立保存 | Separate collapse state | 独立维护折叠状态 |
| Always expand all / 始终全部展开 | All expanded on open | 每次打开全部展开 |
| Always collapse all / 始终全部折叠 | All collapsed on open | 每次打开全部折叠 |

---

## Keyboard Shortcuts / 快捷键

### Workspace Switcher / 工作区弹窗

| Shortcut | EN | 中文 |
|----------|----|------|
| `Enter` | Switch / create new | 切换或新建工作区 |
| `Shift + Enter` | Save and switch | 保存并切换 |
| `Alt + Enter` | Save current, then switch | 保存当前后切换 |
| `Ctrl + Enter` | Rename workspace | 重命名工作区 |
| `Shift + Delete` | Delete workspace | 删除工作区 |
| `Escape` | Close modal | 关闭弹窗 |

### Mode Switcher / 模式弹窗

| Shortcut | EN | 中文 |
|----------|----|------|
| `Enter` | Load selected mode | 加载选中模式 |
| `Ctrl + Enter` | Rename mode | 重命名模式 |
| `Shift + Delete` | Delete mode | 删除模式 |

---

## Commands / 命令

- **Open WorkSpace Plus Group / 打开工作区切换器**
- **Save workspace / 保存工作区**
- **Open WorkSpace Plus Group Modes / 打开模式切换器** (requires Workspace Modes)

Each workspace auto-registers as `workspace-plus-group:<name>`, bindable to custom hotkeys.  
每个工作区自动注册为独立命令，可绑定快捷键。

---

## Installation / 安装

### Community Plugin Browser / 插件市场

Search "WorkSpace Plus Group" → Install and enable.

### Manual / 手动

Download `main.js`, `styles.css`, `manifest.json` → place in `<vault>/.obsidian/plugins/workspace-plus-group/` → restart and enable.

---

## Language / 语言

Auto-detects Obsidian language. Supports **English** and **中文**.

---

## Credits / 致谢

Original author / 原作者：[NothingIsLost](https://github.com/nothingislost)

---

> Desktop only / 仅桌面端 · Requires Obsidian 1.5.0+
