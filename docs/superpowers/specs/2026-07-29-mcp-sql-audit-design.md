# MCP SQL 审计设计

## 目标

将本工作区中由 Codex 通过 MCP 提交的每一条 SQL 记录到可审计的本地文件中，便于按时间、服务和操作类型追溯。

## 目录与格式

- 审计目录：`audit/mcp-sql/`
- 文件命名：`YYYY-MM-DD.jsonl`，按本地日期分文件。
- 格式：每行一个 UTF-8 JSON 对象；只追加，不改写既有记录。
- 初始文件：`audit/mcp-sql/README.md` 说明字段和查看方式；`.gitkeep` 保留空目录。

每条记录包含：

- `timestamp`：ISO 8601 时间戳及 `+08:00` 时区。
- `mcp_server`：MCP 服务名，例如 `doris-jamf-develop`。
- `database`：目标数据库；未知时为 `null`。
- `operation`：`SELECT`、`SHOW`、`EXPLAIN`、`INSERT`、`UPDATE`、`DELETE`、`DDL` 或 `OTHER`。
- `sql`：将提交到 MCP 的完整 SQL。
- `status`：`planned`、`succeeded` 或 `failed`。
- `result_summary`：成功时仅记录行数、受影响行数或摘要；失败时记录错误摘要。

审计记录不得包含连接密码、令牌或其他凭据。

## 执行流程

1. 在调用任何 MCP SQL 工具前，先写入一条 `planned` 记录。
2. 调用完成后，在同一条记录中更新为 `succeeded` 或 `failed` 并补充结果摘要。
3. 如果无法写入审计文件，不执行 SQL；先向用户说明阻塞原因。
4. SQL 不得通过未记录的别名、脚本或批处理绕过本流程。

## 落地方式与边界

在 `AGENTS.md` 中加入强制规则，使后续 Codex 会话在任何 MCP SQL 调用前后遵循上述流程。该规则约束 Codex 的操作流程；它不是运行时拦截器，不能替代数据库侧审计或代理日志。

## 验证

验证时检查：审计目录存在、README 记录字段契约、AGENTS.md 明确要求 MCP SQL 审计、示例 JSONL 可被 JSON 解析。不会为了验证而连接数据库或执行 SQL。
