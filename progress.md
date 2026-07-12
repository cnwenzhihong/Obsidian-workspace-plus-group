# WorkSpace Plus Group — 重构进度

## 已完成

### 第一阶段：删除冗余、修复UX、设置重组、i18n
- 删除 Per Workspace Settings、Show instructions、Per Mode Settings、platform 指示器
- 修复弹窗 inputEl bug、Ribbon toggle、模式 Ribbon
- 设置布局重组：3 个可折叠分组 + auto-save 顶层
- 全部 STRINGS 中英文翻译

### 第二阶段：工作区层级功能
- 数据模型：`workspaceChildren`、`collapsedWorkspaces`、`modalCollapseMode`、`modalCollapsedWorkspaces`
- 核心方法：`reparentWorkspace`、`reorderWorkspace`（均在 `WorkspacesPlus` 插件类，全局复用）
- 设置面板：拖拽树形视图（中央=父子/边缘25%=排序）+ 折叠/展开 + 新建/子工作区输入框 + hover编辑删除按钮
- 弹窗：层级缩进 + 折叠/展开 + 4种折叠规则 + 拖拽（中央=父子/边缘=排序）+ 提示栏 + `✓`确认按钮
- GitHub Actions 自动发布 + artifact attestations

### 第三阶段：弹窗层级管理深度修复（本次会话核心）

#### 已修复的Bug及根因

| # | 问题 | 根因 | 解决 |
|---|------|------|------|
| 1 | 弹窗编辑清空文字后无法输入 | contentEditable 为空时浏览器无法放置光标 | `input`事件自动补`\u200B`零宽空格 |
| 2 | 重命名后父子关系消失 | `handleRename` 未调用 `renameInHierarchy` | 添加调用 + saveData |
| 3 | 重命名同名时工作区消失 | `workspaces[new]=workspaces[old]; delete workspaces[old]` → 同key自删 | 同名时 `return` 跳过 |
| 4 | 删除确认弹窗不关闭 | `__awaiter` 中 `this` 丢失 + `updateSuggestions` 干扰关闭 | 先 `this.close()` 再 `onAccept()` |
| 5 | 删除后列表跳回顶端 | `updateSuggestions` 重建 DOM 重置 scrollTop | `requestAnimationFrame` 恢复滚动位置 |
| 6 | 弹窗折叠无效(子项出现在底部) | `getItems()` 孤儿循环补回了被折叠父级跳过的子项 | 孤儿循环加 `!getWorkspaceParent` 条件 |
| 7 | 创建子分区逻辑分散 | 多处手动操作 `workspaceChildren` | 统一调用 `reparentWorkspace` |
| 8 | 设置回车创建子分区 | 回车绑定到 childBtn | 改为 createBtn（根级创建） |
| 9 | 创建后编辑逻辑重复 | 弹窗和设置各写一套 contentEditable 逻辑 | 复用 `onRenameClick` / `renameBtn.click()` |
| 10 | 弹窗确认按钮缺失 | 只有 Enter/失焦提交 | 添加内联 `✓` 按钮（26×26，absolute 定位输入框内右侧） |
| 11 | CSS `!important` 审核拒绝 | 特异性不足 | 用 `.settings-container .hierarchy-compact-setting.setting-item` |
| 12 | 弹窗提示延迟1s | Obsidian 内置 tooltip 冷启动机制 | 接受此限制（不可绕过） |

#### 架构决策
- **所有父子关系操作统一经由 `WorkspacesPlus.reparentWorkspace()` 和 `reorderWorkspace()`**
- 弹窗和设置面板不再有任何地方手动操作 `workspaceChildren`
- 创建子分区后编辑逻辑统一复用已有的编辑入口

## 未完成
- 清理冗余：cMenu、Periodic Notes、backupCoreConfig
- Workspace Modes 功能标记为 beta/不推荐
