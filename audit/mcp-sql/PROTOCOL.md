# MCP SQL 审计执行协议（P0）

适用范围：所有通过 MCP 提交 SQL 的数据查询、schema 核验、数据验证、DML 和 DDL。

## 每条 SQL 的固定流程

1. 生成唯一 `audit_id`，确定 MCP 服务、数据库、操作类型和完整 SQL。
2. 向当日 `YYYY-MM-DD.jsonl` 追加 `planned` 记录。
3. 读取文件最后一行，确认该行是本次 `audit_id` 的 `planned` 记录且 SQL 完整一致。
4. 仅在第 3 步成功后调用 MCP。
5. 无论成功或失败，立即追加相同 `audit_id` 的终态记录。
6. 输出验证结论前，逐一检查本次使用的所有 `audit_id` 均已闭环。

## 阻断条件

出现以下任一情况，停止 MCP SQL 操作并说明阻断原因：

- 审计目录不存在或不可写。
- 无法生成、追加或回读 `planned` 记录。
- SQL 与已记录的 `planned.sql` 不完全一致。
- 无法追加上一条 MCP 调用的终态记录。

## 最小记录示例

```jsonl
{"audit_id":"20260730-100000-doris-001","timestamp":"2026-07-30T10:00:00+08:00","mcp_server":"doris-jamf-develop","database":"jamf_ads","operation":"SHOW","sql":"SHOW COLUMNS FROM jamf_ads.example;","status":"planned","result_summary":null,"record_source":"live"}
{"audit_id":"20260730-100000-doris-001","timestamp":"2026-07-30T10:00:02+08:00","mcp_server":"doris-jamf-develop","database":"jamf_ads","operation":"SHOW","sql":"SHOW COLUMNS FROM jamf_ads.example;","status":"succeeded","result_summary":"returned 12 columns","record_source":"live"}
```

## 交付引用格式

数据验证结论中必须附：`审计：audit/mcp-sql/YYYY-MM-DD.jsonl，audit_id=<ID>`。
