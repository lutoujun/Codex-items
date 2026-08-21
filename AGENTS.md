# Global development standards

## Workspace role routing

For a task in this repository, first read `roles/README.md`. When the user does not explicitly name a role, use `roles/workspace-orchestrator.md` to select the primary and any supporting roles, then state the reusable deliverable. An explicitly named role takes precedence for task framing, but cannot weaken the DWE/PUD/DVT/PAR routing, MCP SQL audit, evidence, authorization, or file-safety rules below.

Use Chinese by default; retain established English technical terms.

## Domain routing

For every data-warehouse, product/UI, data-validation, or product-acceptance task, first read `.codex/cursor-rules/00-role-orchestrator.mdc`, classify the dominant mode, and state the intended reusable deliverable.

- DWE — data warehouse, ODS/DWD/DWS/ADS, ETL, Hive, Spark, Doris, MaxCompute, dimensional modeling, metrics: also read `.codex/cursor-rules/01-data-warehouse-engineer.mdc`.
- PUD — page/product design, prototype, interaction, information architecture, PRD, user story, UI component/specification: also read `.codex/cursor-rules/02-product-ui-designer.mdc`.
- DVT — data validation, quality, reconciliation, metric definition, regression, idempotency, null/duplicate/timeliness/completeness/accuracy, Great Expectations, dbt test: also read `.codex/cursor-rules/03-data-validation-tester.mdc`.
- PAR — acceptance, UAT, go-live, Go/No-Go, defect, walkthrough, delivery, milestone, acceptance report/checklist: also read `.codex/cursor-rules/04-product-acceptance-reviewer.mdc`.

If SQL or shell scripts are created, changed, or reviewed, also read `.codex/cursor-rules/05-sql-style.mdc` and follow its checklist. When modes overlap, select the mode that matches the user's primary goal and load any supporting mode rules needed for the hand-off.

## Evidence and hand-offs

- Never invent schema, table names, column names, metric definitions, or data results. Inspect provided sources and available configured data tools first; if evidence is unavailable, say what is missing.
- Do not declare data trustworthy or a product ready for release without reproducible evidence.
- Preserve the role boundaries and the PUD → DWE → DVT → PAR hand-off rules defined in the referenced standards.

## MCP SQL audit

### P0 hard gate — applies to every MCP SQL call

This rule overrides convenience, urgency and any request to "run one quick query". It applies to all MCP tools that submit SQL, including schema inspection (`SHOW` / `DESCRIBE` / `EXPLAIN`), validation queries and DML/DDL.

1. Generate one unique `audit_id` for **each** MCP SQL call, then append a `planned` record to `audit/mcp-sql/YYYY-MM-DD.jsonl` **before** invoking MCP.
2. Read back and confirm the just-written `planned` record. If the directory, file, append operation or read-back check fails, stop: **do not call MCP SQL**.
3. Submit exactly the SQL recorded in that `planned` record. If SQL changes, abandon that audit ID and create a new `planned` record for the changed SQL.
4. Immediately after the MCP call, append one terminal record with the same `audit_id` and status `succeeded` or `failed`; include a concise, non-sensitive result summary.
5. Before giving any data-validation conclusion, verify that every audit ID used in the conclusion has one `planned` and one terminal record. The final response must cite the audit date file and audit ID(s).

### Required fields and prohibitions

- Each record must include `audit_id`, timestamp (`+08:00`), MCP server, database, operation, full SQL, status and result summary; never record credentials or tokens.
- JSONL is append-only. Never overwrite, edit, delete or fabricate historical audit records.
- Prohibited: calling MCP first and logging later; logging only successful calls; combining multiple SQL calls under one audit ID; using a shell/database client to bypass the audit; declaring validation complete without audit IDs.
- A previous missing audit record is a compliance failure, not permission to create an unverified backfill. Only append a historical record when the original SQL and outcome are independently recoverable, and mark it `backfilled` in `record_source`.

See `audit/mcp-sql/README.md` for the field contract and `audit/mcp-sql/PROTOCOL.md` for the execution checklist.

## Workspace context

For a selected domain role, check the applicable `context/warehouse-catalog.md`, `context/metrics-dict.md`, `context/lineage-guide.md`, and `context/standards.md` files in the target project before relying on their facts. If a required bridge is absent or incomplete, state the precise missing input.
