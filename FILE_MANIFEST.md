# 文件归属清单

更新时间：2026-07-30

| 文件或目录 | 分类 | 说明 |
| --- | --- | --- |
| `.codex/` | 工作台配置 | Codex 规则与本地配置，保留根目录。 |
| `AGENTS.md` | 工作台规范 | 全局协作与数据开发约束。 |
| `projects/finance-ca-profit/` | 业务项目 | CA 利润月报逻辑与核验材料。 |
| `docs/superpowers/specs/` | 全局设计文档 | 既有 MCP SQL 审计设计文档。 |
| `_tools/` | 第三方工具 | Graphify 和 Superpowers 的本地工具源码。 |
| `_generated/` | 可再生成产物 | Python 缓存等不需要人工维护的内容。 |
| `audit/mcp-sql/` | MCP SQL 审计 | 以 JSONL 追加记录 MCP SQL 调用。 |
| `graphify-out/` | 工具生成物 | Graphify 固定输出路径；可重新生成，不纳入版本控制。 |
| `roles/` | 工作台角色库 | 精选角色、默认路由和使用说明；不包含外部 Agent 工具或凭据。 |

## 维护方式

- 新增项目时，在 `projects/` 下创建项目目录，并在本清单新增一行。
- 文件移动、归档或弃用时，同步更新本清单与对应项目的 `README.md`。
- 需要保留的历史交付物放入项目内 `docs/`、`mindmaps/` 或 `evidence/`，不要与缓存混放。
