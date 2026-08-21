# Codex 工作台精选角色与路由设计

## 目标

将 `E:\Codex-items` 建设为可长期维护的 Codex 工作仓库。用户只需提出需求；工作台编排器根据任务类型选择合适的专业角色，遵循现有仓库规则后输出可验证的结论或完成对应变更。

本设计仅精选并适配角色方法论，不复制 `E:\cursorItem\agency-agents-main` 的全部角色，也不修改来源项目。

## 设计原则

1. 一个默认入口：未指定角色时，由工作台编排器负责分类、调度和结论汇总。
2. 规则优先：`AGENTS.md` 与 `.codex/cursor-rules/` 是强制约束；角色说明不得覆盖其数据审计、目录和安全要求。
3. 最小角色集：只保留当前数据仓库、业务分析、模板交付与 Git 管理需要的职责。
4. 结论可追溯：涉及数据结论时保留审计证据；涉及文件变更时报告文件、验证结果和 Git 状态。
5. 可显式覆盖：用户可在需求中指定“按数据验证角色处理”等，覆盖默认路由。

## 精选角色

| 角色标识 | 来源方法论 | 适配后的职责 | 默认触发条件 |
| --- | --- | --- | --- |
| `workspace-orchestrator` | Project Shepherd | 需求分类、角色选择、风险识别、结论汇总 | 未指定角色的所有需求 |
| `data-warehouse-engineer` | Data Engineer | Doris、ETL、ODS/DWD/DWS/ADS、指标与脚本 | 建表、SQL、ETL、数仓逻辑 |
| `data-validation-auditor` | Evidence Collector / Reality Checker | 口径、质量、对账、回归、MCP 审计 | 验证、对比、异常、可信度 |
| `product-requirements-designer` | Product Manager | 模板、业务需求、字段设计、指标定义 | Excel、页面、PRD、字段和流程 |
| `delivery-acceptance-reviewer` | Project Shepherd | UAT、上线检查、交付完整性、Go/No-Go | 验收、上线、交付检查 |
| `project-manager` | Senior Project Manager | 多步骤任务拆解、优先级、依赖与风险 | 计划、排期、跨项目协同 |
| `minimal-change-engineer` | Minimal Change Engineer | 最小范围修复，禁止借题扩改 | 小修复、局部改动、热修 |
| `code-reviewer` | Code Reviewer | 正确性、可维护性、测试与安全审查 | 代码审查、变更评审 |
| `git-workflow-manager` | Git Workflow Master | 分支、合并、冲突、提交、推送与仓库卫生 | Git、TortoiseGit、提交、推送 |

## 路由规则

工作台编排器先读取用户目标和约束，再按以下顺序路由：

1. 用户明确指定角色时，使用该角色，并同时加载适用的仓库强制规则。
2. 涉及生产数据、SQL、指标或 ETL 时，优先 `data-warehouse-engineer`；涉及结果正确性时追加 `data-validation-auditor`。
3. 涉及业务模板、字段、交互、需求范围时，优先 `product-requirements-designer`。
4. 涉及上线、验收或交付核对时，优先 `delivery-acceptance-reviewer`。
5. 涉及多步骤目标、依赖或优先级时，追加 `project-manager`。
6. 涉及局部代码修复时，追加 `minimal-change-engineer`；涉及审查时使用 `code-reviewer`。
7. 涉及仓库状态、分支、合并、提交或远端同步时，使用 `git-workflow-manager`。
8. 一项需求可由多个角色协作，但对用户只输出一个一致的结论、决策和下一步。

## 仓库结构

```text
roles/
  README.md                         # 角色入口、使用方式和路由总表
  workspace-orchestrator.md
  data-warehouse-engineer.md
  data-validation-auditor.md
  product-requirements-designer.md
  delivery-acceptance-reviewer.md
  project-manager.md
  minimal-change-engineer.md
  code-reviewer.md
  git-workflow-manager.md
```

`AGENTS.md` 将新增简短入口：任务开始时读取 `roles/README.md`，由 `workspace-orchestrator` 完成默认路由。数据仓库、产品、验证、验收任务仍按现有 `.codex/cursor-rules/` 加载相应规则。

## 使用方式

默认用法：

```text
帮我检查 CA 月报脚本依赖的上传表，并给出影响结论。
```

工作台将路由至数据仓库工程师和数据验证审计师。

指定角色：

```text
按最小变更工程师角色修复这个脚本。
按 Git 工作流管理员角色处理这次冲突。
```

## 边界与安全

- 角色不是独立账号或后台进程；由当前 Codex 对话按角色视角执行。
- 角色不能绕过用户授权、Git 安全规则或 MCP SQL 审计硬门槛。
- 未经明确授权，不删除、覆盖或移动工作区外文件。
- 只迁入适配后的中文工作台角色文档；不引入来源项目的品牌、工具依赖或特定技术栈约束。

## 验证与完成标准

实施完成后应满足：

1. `roles/` 中存在九份角色定义和入口 README。
2. `AGENTS.md` 能指向角色入口，且不削弱既有强制规则。
3. 每个角色说明均明确触发条件、职责、输出和边界。
4. 角色路由示例覆盖数仓、数据验证、模板设计、验收、Git 和最小变更六类常见需求。
5. Git 状态干净，变更已提交并推送至 `main`。
