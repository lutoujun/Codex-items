# Codex-items 工作台

本目录用于承载多个独立的数据开发与分析项目。业务文件按项目归集；第三方工具、缓存和可再生产物不与业务源码混放。

## 项目入口

- `projects/supply-chain-stock/`：供应链库存分析滚动计算。
- `projects/finance-ca-profit/`：CA 利润月报逻辑、SQL 与核验材料。

## 目录约定

- `projects/<project>/src`：业务源码。
- `projects/<project>/tests`：自动化测试。
- `projects/<project>/sql`：可复用 SQL。
- `projects/<project>/docs`：口径、说明与交付文档。
- `projects/<project>/mindmaps`：脑图交付物。
- `projects/<project>/evidence`：查询结果、截图和核验依据。
- `_tools`：第三方工具源码，仅用于本地辅助，不纳入版本控制。
- `_generated`：缓存和可再生产物，不作为业务交付物。
- `audit/mcp-sql`：MCP SQL 调用的追加式审计日志与字段说明。
- `graphify-out`：Graphify 的固定输出目录，保留在根目录以支持其增量更新。

## 新文件规则

1. 先确定所属项目，再放入对应功能目录；不要直接放到根目录。
2. 数据核验交付必须同时保留 SQL、执行日期和结果摘要。
3. 文件命名使用“主题_用途_YYYYMMDD_vNN.扩展名”；脚本和测试可沿用既有命名。
4. 可再生产内容放入 `_generated` 或工具约定目录，并保持在 `.gitignore` 中。

详细归属见 [FILE_MANIFEST.md](FILE_MANIFEST.md)。

团队使用 AI 的统一流程见 [AI_DATA_WORKFLOW.md](docs/AI_DATA_WORKFLOW.md)。
