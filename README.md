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

- **Make Child / 建立父子**：Drag onto the row **center** (solid outline) → becomes a child.
  拖到行中央（实线框）→ 成为子工作区
- **Reorder / 同级排序**：Drag to the row **edge** 25% (colored insertion line) → adjust sibling order.
  拖到边缘 25%（彩色插入线）→ 同级排序
- **Collapse/Expand / 折叠展开**：Click the triangle left of a parent.
  点击父工作区左侧三角按钮
![](https://github.com/cnwenzhihong/Obsidian-workspace-plus-group/blob/main/docs/Assets/Example_Settings.png)

### Workspace Modes / 工作区模式

Bind independent Obsidian global settings (theme, font, etc.) to each workspace. Switching applies them automatically.
为每个工作区绑定独立设置方案，切换时自动应用。

### Status Bar / 状态栏

Shows current workspace and mode. **Shift+Click** to save.
显示当前名称，Shift+Click 快速保存。

---

## Settings / 设置

| Setting / 设置 | Description / 说明 |
|---------|-------------|
| Auto-save layout / 自动保存布局 | Save on any layout change |
| Delete confirmation / 删除确认 | Show confirmation before deleting |
| Sidebar ribbon icon / Ribbon 图标 | Show workspace switcher ribbon button |
| Workspace Modes / 工作区模式 | Enable per-workspace settings (beta) |
| Mode ribbon icon / 模式 Ribbon | Show mode switcher ribbon button |
| System dark mode / 系统深色模式 | Follow OS light/dark when switching modes |
| Live Preview auto-reload / 自动重载 | Reload Obsidian on Live Preview change |
| Workspace Hierarchy / 工作区层级 | Drag-and-drop tree view |
| Modal collapse rule / 弹窗折叠规则 | Collapse behavior in switcher (4 modes) |

### Modal Collapse Rules / 弹窗折叠规则

| Mode / 模式 | Behavior / 行为 |
|------|------|
| Inherit from settings / 继承插件设置 | Syncs with settings panel |
| Save independently / 弹窗独立保存 | Separate collapse state |
| Always expand all / 始终全部展开 | All expanded on open |
| Always collapse all / 始终全部折叠 | All collapsed on open |

---

## Keyboard Shortcuts / 快捷键

### Workspace Switcher / 工作区弹窗

| Shortcut | Action / 操作 |
|----------|--------|
| `Enter` | Switch / create new / 切换或新建 |
| `Shift + Enter` | Save and switch / 保存并切换 |
| `Alt + Enter` | Save current, then switch / 保存当前后切换 |
| `Ctrl + Enter` | Rename / 重命名 |
| `Shift + Delete` | Delete / 删除 |
| `Escape` | Close / 关闭 |

### Mode Switcher / 模式弹窗

| Shortcut | Action / 操作 |
|----------|--------|
| `Enter` | Load mode / 加载模式 |
| `Ctrl + Enter` | Rename / 重命名 |
| `Shift + Delete` | Delete / 删除 |

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
