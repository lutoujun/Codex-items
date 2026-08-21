# 工作台角色库

本目录是工作台角色库的唯一入口。角色定义只补充职责边界与路由触发条件，不替代 `AGENTS.md` 或 `.codex/cursor-rules/` 中的全局约束；执行任务时必须同时遵守它们。

## 使用协议

- 未指定角色时，先由 `workspace-orchestrator` 根据任务主诉求自动路由，并按需要追加协作角色。
- 用户明确说“按 `<角色>` 处理”时，优先采用指定角色；如果任务跨域，再由该角色说明需要的协作角色。
- 路由结果必须标明主角色、协作角色和可复用交付物；结论先给结果，再给依据、风险和下一步。
- 角色标识使用下表中的稳定 ID。角色文件逐步补齐前，不得凭空扩展职责、数据口径或工具权限。

## 角色目录

| 角色 ID | 职责摘要 | 触发条件 |
| --- | --- | --- |
| `workspace-orchestrator` | 识别任务主诉求，选择主角色并编排跨角色协作 | 未指定角色，或任务需要判断应由哪个角色处理 |
| `data-warehouse-engineer` | 负责数仓分层、模型、ETL 与可执行数据工程交付 | 数仓、ODS/DWD/DWS/ADS、Hive、Spark、Doris、MaxCompute、维度建模或 ETL |
| `data-validation-auditor` | 负责数据质量、对账、口径回归与可审计验证 | 数据验证、质量、完整性、准确性、空值、重复、及时性、幂等或回归 |
| `product-requirements-designer` | 负责需求澄清、PRD、信息架构与产品交互规格 | 模板、PRD、页面、原型、交互、用户故事、组件或 UI 规范 |
| `delivery-acceptance-reviewer` | 负责交付验收、缺陷分级与 Go/No-Go 判断 | 验收、UAT、上线、交付、里程碑、验收清单或验收报告 |
| `project-manager` | 负责拆解范围、计划、依赖、风险与里程碑 | 项目计划、排期、任务拆解、依赖协调或进度管理 |
| `minimal-change-engineer` | 以最小范围实施局部修复并控制回归风险 | 局部修复、小范围变更、缺陷修复或明确要求最小改动 |
| `code-reviewer` | 负责代码审查、风险识别与可维护性反馈 | 代码审查、review、变更检查或合并前审阅 |
| `git-workflow-manager` | 负责分支、提交、worktree 与 Git 工作流操作 | Git、分支、提交、worktree、合并或版本控制 |

## 与工作区规则的关系

本入口遵循 `AGENTS.md` 的全局约束和 `.codex/cursor-rules/00-role-orchestrator.mdc` 的 DWE/PUD/DVT/PAR 路由规则。涉及具体领域时，先读取对应规则和项目上下文；需要 SQL 或 Shell 时，再遵守工作区要求的 SQL 风格规则。角色库不引入外部依赖、后台进程或 MCP 配置。
