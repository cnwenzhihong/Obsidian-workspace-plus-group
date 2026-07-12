# WorkSpace Plus Group - AI开发上下文文档

## 项目概述

WorkSpace Plus Group 是一个 Obsidian 插件，扩展了 Obsidian 内置的 Workspaces 核心插件功能。

**插件ID**: `workspace-plus-group` | **版本**: 1.2.5 | **文件**: `main.js`(~5060行) + `styles.css`(~500行)

---

## 会话总结 — 弹窗层级管理重构

### 核心架构决策

**所有父子关系操作统一通过 `WorkspacesPlus` 插件类的两个方法管理：**
- `reparentWorkspace(dragName, targetName)` — 创建/修改父子关系
- `reorderWorkspace(dragName, targetName, "before"|"after")` — 同级排序

设置面板和弹窗均调用这两个方法，不再有任何地方手动操作 `workspaceChildren`。

### 修复的问题及根因

| # | 问题 | 根因 | 解决 |
|---|------|------|------|
| 1 | 弹窗编辑时清空文字后无法输入 | contentEditable 为空时浏览器无法放置光标 | `input`事件监听，`textContent`为空时插入`\u200B` |
| 2 | 重命名后父子关系消失 | `handleRename`未调用`renameInHierarchy` | 添加`this.plugin.renameInHierarchy()`+`saveData` |
| 3 | 重命名同名时工作区消失 | `workspaces[new]=workspaces[old]; delete workspaces[old]` → 同key自删 | 同名时`return`跳过 |
| 4 | 删除确认弹窗不关闭 | `__awaiter`中`this`绑定丢失；`updateSuggestions`干扰关闭 | 改为先`this.close()`再`onAccept()`，移除`__awaiter` |
| 5 | 删除后列表跳回顶端 | `updateSuggestions`销毁并重建DOM | 保存`scrollTop`，`requestAnimationFrame`后恢复 |
| 6 | 设置输入框回车创建子分区 | 回车绑定到childBtn | 改为绑定createBtn |
| 7 | 创建子分区逻辑分散 | 多处手动操作`workspaceChildren` | 统一调用`reparentWorkspace` |
| 8 | CSS `!important`被审核拒绝 | 特异性不足 | 用`.settings-container .hierarchy-compact-setting.setting-item`提高特异性 |
| 9 | 弹窗提示延迟1s | Obsidian内置tooltip冷启动机制，不可绕过 | 接受此限制 |
| 10 | contentEditable被`user-select:none`/`draggable`阻断 | 父元素CSS干扰 | 改用原生`<input>`弹窗，设置保留contentEditable |

### 关键代码位置 (main.js)

| 功能 | 位置 |
|------|------|
| DEFAULT_SETTINGS + STRINGS | ~2144-2215 |
| WorkspacesPlusSettingsTab | ~2234 |
| renderHierarchy / renderHierarchyRow | ~2418 |
| 创建/子工作区按钮 | ~2353 |
| reparentWorkspace (plugin) | ~4740 |
| reorderWorkspace (plugin) | ~4757 |
| WorkspacesPlusPluginWorkspaceModal | ~2755 |
| onRenameClick (弹窗编辑) | ~2756 |
| handleRename | ~2882 |
| deleteWorkspace / doDelete | ~2913 / ~3087 |
| getItems (层级顺序) | ~3099 |
| renderSuggestion (弹窗渲染) | ~2932 |
| getWorkspaceParent (跳过__root__) | ~4636 |
| getWorkspaceChildren | ~4643 |
| renameInHierarchy | ~4675 |

### 核心约束速查

- `getWorkspaceParent` 必须 `continue` 跳过 `"__root__"`
- 拖拽数据用实例属性（`_dragName`/`_modalDragName`），不用 `dataTransfer`
- 折叠图标用内联SVG + `fill="currentColor"`，不用 `obsidian.setIcon`
- 弹窗按钮用 `aria-label`+`aria-label-position="top"`，不用 `title`
- CSS 禁用 `!important`
- STRINGS 中英文双译
- `this.inputEl` 不可靠 → 用 `modalEl.querySelector(".prompt-input")`
