# MCP SQL 审计目录

本目录记录 Codex 通过 MCP 提交的 SQL，便于按日期、服务和操作类型追溯。

## 文件规则

- 按本地日期创建 `YYYY-MM-DD.jsonl`。
- UTF-8 编码，每行一个 JSON 对象。
- 只追加新行；不修改既有审计记录。
- 不记录密码、令牌、连接串中的敏感信息。
- 每次 MCP SQL 调用使用一个唯一 `audit_id`；同一 ID 必须有一条 `planned` 和一条终态记录。

## 字段契约

```json
{
  "audit_id": "20260730-100000-doris-001",
  "timestamp": "2026-07-30T10:00:00+08:00",
  "mcp_server": "doris-jamf-develop",
  "database": "jamf_ads",
  "operation": "SELECT",
  "sql": "SELECT 1;",
  "status": "planned",
  "result_summary": null,
  "record_source": "live"
}
```

- `audit_id`：单次 MCP SQL 调用的唯一标识；终态记录必须与 `planned` 记录一致。
- `timestamp`：ISO 8601 时间及 `+08:00` 时区。
- `mcp_server`：实际调用的 MCP 服务名。
- `database`：目标数据库；无法确定时写 `null`。
- `operation`：`SELECT`、`SHOW`、`EXPLAIN`、`INSERT`、`UPDATE`、`DELETE`、`DDL` 或 `OTHER`。
- `sql`：提交给 MCP 的完整 SQL。
- `status`：`planned`、`succeeded` 或 `failed`。
- `result_summary`：执行前为 `null`；执行后填写行数、受影响行数或错误摘要。
- `record_source`：实时记录为 `live`；仅在原始 SQL 和结果可独立恢复时，才允许用 `backfilled` 补录。

每条用于数据验证结论的 MCP SQL，必须能在当日 JSONL 中查到同一 `audit_id` 的 `planned` 和终态记录。
