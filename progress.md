# WorkSpace Plus Group — 重构进度

## 已完成

### 第一阶段：删除冗余、修复UX、设置重组、i18n
- 删除 Per Workspace Settings、Show instructions、Per Mode Settings
- 修复弹窗 inputEl bug、Ribbon toggle、模式 Ribbon
- 设置布局重组：3 个可折叠分组 + auto-save 顶层
- 全部 STRINGS 中英文翻译

### 第二阶段：工作区层级功能
- 数据模型：`workspaceChildren`、`collapsedWorkspaces`、`modalCollapseMode`、`modalCollapsedWorkspaces`
- 辅助方法：`getWorkspaceParent`（跳过 `__root__`）、`getWorkspaceChildren`、`getWorkspaceDepth`、`getOrderedWorkspaces`、`getModalCollapseState`、`cleanupHierarchy`、`renameInHierarchy`、`reparentWorkspace`、`reorderWorkspace`
- 设置面板：拖拽树形视图（行中央=父子高亮框，边缘 25%=同级排序插入线）
- 弹窗：缩进 + 折叠/展开按钮（内联 SVG 前置固定占位）+ 4 种折叠规则下拉
- 生命周期：删除/重命名自动清理层级引用

### 第三阶段：Bug 修复
- `getWorkspaceParent` 跳过 `__root__`（避免根级工作区消失和 depth+1 错误）
- `reparentWorkspace` 创建父子关系（非兄弟）
- 拖拽用 `_dragName` 属性替代 `dataTransfer.getData`
- 折叠图标统一用内联 SVG（`obsidian.setIcon` 的 "down-triangle" 不存在）
- 弹窗折叠按钮前置固定 20×20 占位（`visibility` 控制），标题对齐
- 弹窗点击折叠后保持当前选中项不跳
- `renderHierarchy`/`getOrderedWorkspaces` 根级排序：`__root__` 手动顺序优先 → 孤儿字母序排后
- 移除缩进/缩出按钮（拖拽完全替代）
- `modal-collapse-mode` 名称改为"弹窗折叠规则"

## 关键决策

1. **层级数据**：`{ parentName: [child...], "__root__": [root...] }`
2. **`__root__` 非父级**：`getWorkspaceParent` 必须 `continue` 跳过
3. **拖拽双行为**：行中央=父子（`.drag-over` 实线框），边缘 25%=同级排序（`::before`/`::after` 彩线）
4. **根级排序**：`__root__` 项保持手动顺序在前，未纳入的孤儿字母序在后
5. **拖拽数据**：`this._dragName`（非 `dataTransfer`）
6. **折叠图标**：全部内联 SVG + `fill="currentColor"`（非 `obsidian.setIcon`）
7. **弹窗折叠按钮**：`el.prepend()` 前置 + `visibility: hidden` 占位 + `.has-children` 显形
8. **i18n**：所有文本 STRINGS 中英文双译

## 未完成

- [ ] 清理冗余代码：cMenu 集成、Periodic Notes 集成、backupCoreConfig
- [ ] 弹窗每次 renderSuggestion 重建按钮（性能微优化，功能正常）
