# WorkSpace Plus Group - AI开发上下文文档

## 项目概述

WorkSpace Plus Group 是一个 Obsidian 插件，扩展了 Obsidian 内置的 Workspaces 核心插件功能，提供增强的工作区管理和快速切换体验。

**插件ID**: `workspace-plus-group`
**版本**: 0.3.3
**依赖**: Obsidian 1.0.0+（需要启用内置 Workspaces 核心插件）

## 核心功能

### 1. 工作区快速切换器
- 模糊搜索的工作区切换，输入新名称按 Enter 直接创建

### 2. 工作区管理
- 创建、保存、重命名、删除工作区，删除确认弹窗可配置

### 3. 工作区模式（Modes）
- 为每个工作区绑定独立 Obsidian 设置方案，模式切换自动应用

### 4. 状态栏指示器
- 显示当前工作区和模式名称，Shift+Click 快速保存

### 5. 侧边栏 Ribbon 图标
- 工作区切换器和模式切换器 Ribbon 按钮

### 6. 工作区层级
- 设置面板拖拽树形视图：行中央=父子关系（实线框），边缘 25%=同级排序（插入线）
- 弹窗中显示缩进层级 + 折叠/展开按钮（前置固定占位对齐）
- 弹窗折叠规则 4 种：继承插件设置 / 独立保存 / 全部展开 / 全部折叠
- 层级关系持久化，删除/重命名自动清理

## 代码结构

```
main.js
├── Popper.js (弹窗定位)
├── Utils 工具类
│   ├── 工作区设置管理
│   ├── 模式管理
│   └── 模板字符串渲染
├── WorkspacesPlus 主插件类
│   ├── 生命周期、事件处理、命令注册
│   ├── 层级辅助方法（getWorkspaceParent 等）
│   └── 设置管理
├── WorkspacesPlusSettingsTab 设置面板
│   ├── addSection() 分组折叠
│   ├── renderHierarchy() / renderHierarchyRow() 树视图
│   ├── reparentWorkspace() 父子创建
│   └── reorderWorkspace() 同级排序
├── WorkspacesPlusPluginWorkspaceModal 工作区切换模态框
├── WorkspacesPlusPluginModeModal 模式切换模态框
├── ConfirmationModal 确认对话框
└── Periodic Notes 相关（待清理）
```

## 设置项（DEFAULT_SETTINGS）

```javascript
{
  showDeletePrompt: true,
  saveOnChange: false,
  saveOnSwitch: false,
  workspaceSettings: false,
  systemDarkMode: false,
  globalSettings: {},
  activeWorkspaceDesktop: "",
  activeWorkspaceMobile: "",
  reloadLivePreview: false,
  workspaceSwitcherRibbon: false,
  modeSwitcherRibbon: false,
  replaceNativeRibbon: false,          // [已废弃]
  collapsedSections: {},
  workspaceChildren: {},               // { parentName: [child...], "__root__": [root...] }
  collapsedWorkspaces: {},             // 设置页工作区折叠状态
  modalCollapseMode: "inherit",        // "inherit" | "independent" | "all-expanded" | "all-collapsed"
  modalCollapsedWorkspaces: {},        // 弹窗独立/覆盖折叠状态
}
```

## 设置面板布局

1. **自动保存**（顶层）
2. **显示**（可折叠分组）— 删除确认 + Ribbon 图标
3. **高级**（可折叠分组）— 工作区模式 + 子设置（`requires-workspace-modes`）
4. **工作区层级**（可折叠分组）— 树形视图 + 弹窗折叠规则下拉

分组通过 `addSection(containerEl, sectionId, sectionName)` 创建，折叠状态保存在 `collapsedSections`。

### 层级树操作方法

- `renderHierarchy(treeContainer)` — 重建树视图，`__root__` 项按手动顺序、孤儿按字母序排后
- `renderHierarchyRow(treeContainer, name, depth)` — 单行：折叠按钮 + 拖拽手柄 + 名称
- `reparentWorkspace(dragName, targetName)` — 行中央落点：dragName 成为 targetName 子节点，含循环检查
- `reorderWorkspace(dragName, targetName, position)` — 边缘落点：dragName 成为 targetName 同级（"before"/"after"），含同数组索引偏移处理

### 层级数据流

- `workspaceChildren["__root__"]` — 根级列表，保留手动排序顺序
- `workspaceChildren[parentName]` — 各父级下的子列表
- `getWorkspaceParent` 跳过 `"__root__"`，确保 `__root__` 成员不被当作有父级
- 根级排序规则：`__root__` 项按其存储顺序在前，未纳入的孤儿按字母序在后
- 删除/重命名自动调用 `cleanupHierarchy` / `renameInHierarchy`

## 已删除的功能

1. Per Workspace Settings（FileOverrides、FileSuggest 等）
2. Per Mode Settings
3. Show instructions 及 buildInstructions
4. replaceNativeRibbon（废弃，设置项保留向后兼容）
5. showInstructions 设置项
6. 缩进/缩出按钮（拖拽完全替代）
7. `moveWorkspaceToRoot` 方法

## 待清理的冗余功能

- cMenu 集成（`updateCMenuIcon`，cMenu 已停止维护）
- Periodic Notes 集成函数
- 配置文件备份（`backupCoreConfig`）

## 国际化 (i18n)

翻译在 `main.js` 的 `STRINGS` 对象中。语言检测：`window.moment.locale()` 返回 zh 开头时用中文。通过 `t(key)` 获取。
**规则：每次修改公开文本必须同步更新 STRINGS 中英文。**

### STRINGS（层级相关）

| Key | EN | ZH |
|-----|----|----|
| `hierarchy` | Workspace Hierarchy | 工作区层级 |
| `hierarchy-desc` | Drag and drop... | 拖拽工作区以创建父子层级... |
| `modal-collapse-mode` | Modal collapse rule | 弹窗折叠规则 |
| `modal-collapse-mode-inherit` | Inherit from settings | 继承插件设置 |
| `modal-collapse-mode-independent` | Save independently | 弹窗独立保存 |
| `modal-collapse-mode-all-expanded` | Always expand all | 始终全部展开 |
| `modal-collapse-mode-all-collapsed` | Always collapse all | 始终全部折叠 |
| `collapse-workspace` | Collapse children | 折叠子工作区 |
| `expand-workspace` | Expand children | 展开子工作区 |
| `set-as-child` | Set as child | 设为子工作区 |

## 关键类和函数

### WorkspacesPlus 类（层级相关）
- `getWorkspaceParent(name)` — 获取父级，**跳过 `__root__`**
- `getWorkspaceChildren(name)` — 获取子级列表
- `getWorkspaceDepth(name)` — 嵌套深度（向上遍历 parent 链）
- `getOrderedWorkspaces()` — 深度优先列表，`__root__` 顺序优先 + 孤儿字母序
- `getModalCollapseState()` — 依 `modalCollapseMode` 计算弹窗折叠状态
- `cleanupHierarchy(name)` / `renameInHierarchy(old, new)` — 删除/重命名时清理层级引用
- `reparentWorkspace(dragName, targetName)` — 拖拽创建父子
- `reorderWorkspace(dragName, targetName, "before"|"after")` — 拖拽同级排序

### WorkspacesPlusSettingsTab 类
- `addSection(containerEl, sectionId, sectionName)` — 可折叠分组
- `renderHierarchy(treeContainer)` — 重建树视图
- `renderHierarchyRow(treeContainer, name, depth)` — 渲染单行 + 拖拽/折叠事件
- `reparentWorkspace` / `reorderWorkspace` — 拖拽落点处理

### 模态框类
- `WorkspacesPlusPluginWorkspaceModal` — 工作区切换器
  - `getItems()` — 深度优先遍历，过滤已折叠父级的子项
  - `renderSuggestion()` — 按 depth 设 paddingLeft，折叠按钮通过 `el.prepend()` 前置，内联 SVG，`visibility` 控制
  - **`this.inputEl` 不可靠**（构造时被替换为脱离 DOM 克隆节点），用 `this.modalEl.querySelector(".prompt-input")` 读输入
- `WorkspacesPlusPluginModeModal` — 模式切换器
- `ConfirmationModal` — 确认对话框

## 已知技术细节

1. **inputEl bug**：`saveAndStay` 和 `useSelectedItem` 改用 `modalEl.querySelector(".prompt-input").value`
2. **Ribbon 显示**：`.show()`/`.hide()` 不可靠，改用 `style.display`
3. **模式 Ribbon**：不依赖 `workspaceSettings`，通过 CSS `requires-workspace-modes` 联动
4. **`getWorkspaceParent` 跳过 `__root__`**：否则根级工作区被误判有父级 → 消失 + depth 错误
5. **折叠图标**：全部使用内联 SVG + `fill="currentColor"`，**不用** `obsidian.setIcon`（"down-triangle" 不存在）
6. **拖拽数据**：用 `this._dragName` 实例属性，**不用** `dataTransfer.getData`（Obsidian 内嵌浏览器不可靠）
7. **拖拽行为**：`dragover` 按 `clientY` / `rect.height` 判断区域（边缘 25%=排序插入线 `::before`/`::after`，中央=父子高亮框 `.drag-over`）
8. **根级排序**：`__root__` 项按存储顺序在前，孤儿字母序在后。新增项 push 到 `__root__` 末尾
9. **弹窗折叠按钮**：`el.prepend()` 前置 + `visibility: hidden` 默认占位 20×20 + `.has-children` 显形，保证标题对齐
10. **弹窗折叠点击**：先保存当前选中项，`updateSuggestions` 后重新 `setSelectedItem`，避免焦点跳走
11. **弹窗折叠存储**："inherit" 读/写 `collapsedWorkspaces`，"independent" 读/写 `modalCollapsedWorkspaces`，"all-expanded"/"all-collapsed" 以 `modalCollapsedWorkspaces` 作为单项覆盖
12. **依赖原生 Workspaces 插件**，通过 `around` Hook 原生方法
13. **CSS 禁用 `!important`**：Obsidian 插件审核会拒绝 `!important`。应通过提高选择器特异性覆盖默认样式（如用 `.settings-container .hierarchy-compact-setting.setting-item` 代替 `.setting-item`）

## 快捷键

### 工作区切换器
- `Enter` — 切换 / 新名称创建
- `Shift+Enter` — 保存并切换
- `Alt+Enter` — 保存当前并切换
- `Ctrl+Enter` — 重命名
- `Shift+Delete` — 删除
- `Escape` — 关闭

## CSS 要点

### 层级设置面板
- `.hierarchy-row` — flex 行容器，`position:relative`，含 drag 状态样式
- `.hierarchy-row.dragging` — opacity:0.5
- `.hierarchy-row.drag-over` — 父子落点：实线框高亮
- `.hierarchy-row.drag-insert-before::before` — 排序落点：顶部彩线
- `.hierarchy-row.drag-insert-after::after` — 排序落点：底部彩线
- `.hierarchy-collapse` — 折叠按钮，内联 SVG
- `.hierarchy-grip` — 6 点网格拖拽手柄
- `.hierarchy-name` — 名称，`text-overflow: ellipsis`
- `.hierarchy-name.is-active` — 当前活动工作区加粗蓝色

### 弹窗层级
- `.hierarchy-modal-collapse` — `inline-flex` 20×20 居中，`visibility:hidden` 默认占位，`.has-children` 显形
- 弹窗内 `.workspace-item` paddingLeft 按 `depth * 16px` 递增
- 弹窗按钮栏统一风格：`add-child-workspace`(4.6em) / `rename-workspace`(2em) / `delete-workspace`(0.7em)，均 `position:absolute; opacity:0`→选中/hover 显示；已删除 `platform` 指示器

### 其他

### 其他
- `.settings-heading.is-collapsed + .settings-container` — 分组折叠隐藏
- `.requires-workspace-modes` + `.workspace-modes ~ .requires-workspace-modes` — 模式子设置联动
- `.mode-sub-settings` — 模式子设置边距缩进
