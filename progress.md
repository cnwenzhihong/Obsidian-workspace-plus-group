# WorkSpace Plus Group — 重构进度

## 已完成

### 第一阶段：删除冗余、修复UX、设置重组、i18n
- 删除 Per Workspace Settings、Show instructions、Per Mode Settings
- 修复弹窗 inputEl bug、Ribbon toggle、模式 Ribbon
- 设置布局重组：3 个可折叠分组 + auto-save 顶层
- 全部 STRINGS 中英文翻译

### 第二阶段：工作区层级功能
- 数据模型：`workspaceChildren`、`collapsedWorkspaces`、`modalCollapseMode`、`modalCollapsedWorkspaces`
- 辅助方法：`getWorkspaceParent`(跳过`__root__`)、`getWorkspaceChildren`、`getWorkspaceDepth`、`getOrderedWorkspaces`、`getModalCollapseState`、`cleanupHierarchy`、`renameInHierarchy`、`reparentWorkspace`、`reorderWorkspace`、`renameInSettings`
- 设置面板：拖拽树形视图（行中央=父子高亮框，边缘25%=同级排序插入线）+ 折叠/展开 + 新建工作区输入框 + 创建子工作区按钮 + 双击/铅笔重命名 + 垃圾桶删除
- 弹窗：缩进层级 + 折叠/展开按钮(前置20×20内联SVG) + 4种折叠规则 + 拖拽排序 + 操作提示栏
- 生命周期：删除/重命名自动清理层级引用
- 版本发布：GitHub Actions 自动构建 + artifact attestations

### 第三阶段：Bug修复
- `getWorkspaceParent` 跳过 `__root__`
- 拖拽用 `_dragName` 替代 `dataTransfer`
- 折叠图标全用内联SVG（No `obsidian.setIcon`）
- 弹窗折叠按钮前置占位对齐，点击保持选中项
- 根级排序：`__root__` 手动顺序 > 孤儿字母序
- 编辑状态 cursor: text
- CSS 禁用 `!important`

## 未完成
- 清理冗余：cMenu、Periodic Notes、backupCoreConfig
- Workspace Modes 功能标记为 beta/不推荐
