# Codex 工作台角色路由实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 `E:\Codex-items` 建立精选角色库和默认路由入口，使用户可直接提出需求或显式指定角色。

**Architecture:** `roles/README.md` 是唯一角色目录与路由表，`workspace-orchestrator.md` 负责默认分类。八份专业角色文档只定义职责、触发条件、输出和边界；`AGENTS.md` 保留现有强制规则，并新增到角色入口的引用。

**Tech Stack:** Markdown、PowerShell 静态校验、Git。

## Global Constraints

- 角色文档使用中文，保留必要的英文技术术语。
- `AGENTS.md` 与 `.codex/cursor-rules/` 的规则优先于角色文档。
- 不复制来源项目的原文、品牌、特定技术栈依赖或工具配置。
- 不创建独立账号、后台进程、外部服务或 MCP 配置。
- 不修改 `E:\cursorItem\agency-agents-main`。
- 所有仓库变更须通过 Git 提交并推送到 `main`。

---

### Task 1: 创建角色入口与默认编排器

**Files:**
- Create: `roles/README.md`
- Create: `roles/workspace-orchestrator.md`

**Interfaces:**
- Consumes: `AGENTS.md` 的全局约束和 `.codex/cursor-rules/00-role-orchestrator.mdc` 的 DWE/PUD/DVT/PAR 路由规则。
- Produces: `roles/README.md` 作为其他角色和 `AGENTS.md` 的唯一入口；`workspace-orchestrator.md` 作为未指定角色任务的默认路由定义。

- [ ] **Step 1: 创建 `roles/README.md` 的角色目录和使用协议**

写入九个角色标识、职责摘要和触发条件；明确两种用法：未指定角色时自动路由，指定“按 `<角色>` 处理”时优先采用该角色。

目录表必须包含：`workspace-orchestrator`、`data-warehouse-engineer`、`data-validation-auditor`、`product-requirements-designer`、`delivery-acceptance-reviewer`、`project-manager`、`minimal-change-engineer`、`code-reviewer`、`git-workflow-manager`。

- [ ] **Step 2: 创建默认编排器角色定义**

在 `roles/workspace-orchestrator.md` 中定义以下固定输出结构：

```markdown
## 本次路由
- 主角色：<role-id>
- 协作角色：<role-id 列表或无>
- 可复用交付物：<文档、脚本、SQL、模板或结论>

## 结论
<先给结果，再给关键依据、风险和下一步>
```

路由顺序必须为：显式指定角色优先；数仓/数据任务选择 DWE；验证追加 DVT；模板/PRD 选择 PUD；验收选择 PAR；计划选择项目经理；局部修复追加最小变更工程师；代码审查选择代码审查员；Git 任务选择 Git 工作流管理员。

- [ ] **Step 3: 验证入口完整性**

运行：

```powershell
$required = @('workspace-orchestrator','data-warehouse-engineer','data-validation-auditor','product-requirements-designer','delivery-acceptance-reviewer','project-manager','minimal-change-engineer','code-reviewer','git-workflow-manager')
$index = Get-Content -Raw 'roles/README.md'
$missing = $required | Where-Object { $index -notmatch [regex]::Escape($_) }
if ($missing) { throw "Missing role IDs: $($missing -join ', ')" }
```

Expected: no exception.

- [ ] **Step 4: 提交任务变更**

```powershell
git add roles/README.md roles/workspace-orchestrator.md
git commit -m "feat: add workspace role router"
```

### Task 2: 创建数据、产品、交付与项目管理角色

**Files:**
- Create: `roles/data-warehouse-engineer.md`
- Create: `roles/data-validation-auditor.md`
- Create: `roles/product-requirements-designer.md`
- Create: `roles/delivery-acceptance-reviewer.md`
- Create: `roles/project-manager.md`

**Interfaces:**
- Consumes: `roles/README.md` 的角色 ID；`AGENTS.md` 的 DWE/PUD/DVT/PAR 规则。
- Produces: 五份领域角色说明，每份均含“触发条件、工作方式、交付物、不可突破的边界”。

- [ ] **Step 1: 写入五份领域角色说明**

每份文件使用以下固定骨架：

```markdown
# <中文角色名>

## 触发条件
<明确列出关键词和任务类型>

## 工作方式
<只列该角色需要执行的判断与检查>

## 交付物
<明确输出文件或结论形式>

## 强制边界
<指向 AGENTS.md 和适用 cursor rule；列出不可绕过的约束>
```

具体约束：数据仓库工程师引用 MCP SQL 审计硬门槛；数据验证审计师要求证据和审计 ID；产品需求设计师要求字段、口径、数据范围和验收标准；交付验收负责人要求可复现证据后才能给 Go/No-Go；项目经理要求范围、依赖、风险与下一步。

- [ ] **Step 2: 验证五份角色的结构和边界**

运行：

```powershell
$files = Get-ChildItem 'roles' -Filter '*.md' | Where-Object Name -in @('data-warehouse-engineer.md','data-validation-auditor.md','product-requirements-designer.md','delivery-acceptance-reviewer.md','project-manager.md')
foreach ($file in $files) {
  $text = Get-Content -Raw $file.FullName
  foreach ($heading in @('## 触发条件','## 工作方式','## 交付物','## 强制边界')) {
    if ($text -notmatch [regex]::Escape($heading)) { throw "$($file.Name) missing $heading" }
  }
}
```

Expected: no exception.

- [ ] **Step 3: 提交任务变更**

```powershell
git add roles/data-warehouse-engineer.md roles/data-validation-auditor.md roles/product-requirements-designer.md roles/delivery-acceptance-reviewer.md roles/project-manager.md
git commit -m "feat: add data and delivery roles"
```

### Task 3: 创建工程质量与 Git 管理角色

**Files:**
- Create: `roles/minimal-change-engineer.md`
- Create: `roles/code-reviewer.md`
- Create: `roles/git-workflow-manager.md`

**Interfaces:**
- Consumes: `roles/README.md` 的路由入口和现有 `.gitignore`、Git 远端配置。
- Produces: 三份工程治理角色说明，覆盖最小变更、代码审查和 Git 维护。

- [ ] **Step 1: 写入最小变更工程师角色**

定义“只修改需求所需文件、发现额外问题只记录为后续项、修改后运行与风险相称的验证”的强制规则；禁止借题重构、无关格式化和未授权删除。

- [ ] **Step 2: 写入代码审查员角色**

定义审查输出必须按 `P0/P1/P2` 标注，并包含“文件/行号、问题、影响、建议”；审查重点为正确性、数据风险、安全、可维护性和测试。

- [ ] **Step 3: 写入 Git 工作流管理员角色**

定义 Git 操作前检查工作区、远端和分支；提交前验证暂存范围；推送前禁止强推；冲突时保留双方语义并验证；所有结果报告提交 SHA 和同步状态。

- [ ] **Step 4: 验证工程治理角色关键规则**

运行：

```powershell
$checks = @{
  'roles/minimal-change-engineer.md' = '后续项'
  'roles/code-reviewer.md' = 'P0/P1/P2'
  'roles/git-workflow-manager.md' = '禁止强推'
}
foreach ($pair in $checks.GetEnumerator()) {
  if ((Get-Content -Raw $pair.Key) -notmatch [regex]::Escape($pair.Value)) { throw "$($pair.Key) missing $($pair.Value)" }
}
```

Expected: no exception.

- [ ] **Step 5: 提交任务变更**

```powershell
git add roles/minimal-change-engineer.md roles/code-reviewer.md roles/git-workflow-manager.md
git commit -m "feat: add engineering governance roles"
```

### Task 4: 接入仓库入口并完成发布验证

**Files:**
- Modify: `AGENTS.md`
- Modify: `FILE_MANIFEST.md`
- Test: `roles/README.md`、`roles/*.md` 的 PowerShell 静态校验

**Interfaces:**
- Consumes: `roles/README.md` 和九份角色文件。
- Produces: `AGENTS.md` 的角色入口，`FILE_MANIFEST.md` 的角色库归属记录，以及已验证并推送的 `main` 分支。

- [ ] **Step 1: 修改 `AGENTS.md` 增加角色路由入口**

在“Global development standards”之后新增“Workspace role routing”小节，内容限定为：任务开始时读取 `roles/README.md`；未指定角色由 `workspace-orchestrator` 路由；显式角色优先；既有 DWE/PUD/DVT/PAR 与 MCP 审计要求仍然优先。

- [ ] **Step 2: 修改 `FILE_MANIFEST.md` 增加 `roles/` 归属**

新增一行：`roles/`，分类为“工作台角色库”，说明为“精选角色、默认路由和使用说明；不包含外部 Agent 工具或凭据”。

- [ ] **Step 3: 执行完整静态校验**

运行：

```powershell
$roleFiles = Get-ChildItem 'roles' -Filter '*.md'
if ($roleFiles.Count -ne 10) { throw "Expected 10 role markdown files, found $($roleFiles.Count)" }
foreach ($file in $roleFiles) {
  if ((Get-Content -Raw $file.FullName).Length -lt 300) { throw "$($file.Name) is too short" }
}
$agents = Get-Content -Raw 'AGENTS.md'
if ($agents -notmatch 'roles/README\.md') { throw 'AGENTS.md does not reference role entrypoint' }
$manifest = Get-Content -Raw 'FILE_MANIFEST.md'
if ($manifest -notmatch 'roles/') { throw 'FILE_MANIFEST.md does not list roles/' }
git diff --check
git status -sb
```

Expected: ten Markdown files, no exceptions, no whitespace errors, and a reviewable Git status.

- [ ] **Step 4: 提交并推送发布变更**

```powershell
git add AGENTS.md FILE_MANIFEST.md roles/
git commit -m "feat: enable Codex workspace role routing"
git push
git status -sb
```

Expected: `main...origin/main` 且无未提交变更。
