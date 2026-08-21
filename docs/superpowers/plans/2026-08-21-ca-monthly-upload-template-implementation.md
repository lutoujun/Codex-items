# CA 月报月度上载模板 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 创建一个与业务截图风格一致、含总表和 12 个上载 Sheet 的 CA 月报月度上载 Excel 模板。

**Architecture:** 使用 `@oai/artifact-tool` 构建一个空白工作簿。每个明细 Sheet 采用英文物理字段第 1 行、中文说明第 2 行的双行表头；总表维护上载清单和状态。模板不写入业务数据，仅提供规范表头、列格式和可编辑的数据验证。

**Tech Stack:** Node.js、`@oai/artifact-tool`、Excel `.xlsx`。

## Global Constraints

- 工作簿只创建于 `E:\Codex-items\outputs\` 下。
- 所有金额和数量列必须存为数值格式，订单号/SKU/账单号必须存为文本格式。
- 所有 `dt_month` 的中文提示必须为“分区日期YYYY-MM-01”；调整表的 `stat_month` 提示必须为“统计月份YYYY-MM”。
- 04-快递账单表必须包含 `outbound_handling_fee` 与 `express_amount` 两列，且不使用单一合并费用列。
- 仅创建模板，不修改任何 Doris 表或 CA 月报脚本。

---

### Task 1: 准备工作簿构建环境与字段清单

**Files:**
- Create: `E:\Codex-items\tmp\ca-monthly-upload-template\build_ca_monthly_upload_template.mjs`
- Read: `E:\Codex-items\docs\superpowers\specs\2026-08-21-ca-monthly-upload-template-design.md`

**Interfaces:**
- Consumes: 已确认的模板设计说明。
- Produces: 可重复运行的 `.mjs` 构建脚本，导出路径为 `E:\Codex-items\outputs\CA月报月度上载模板.xlsx`。

- [ ] **Step 1: 加载工作区依赖并创建隔离的构建目录**

运行工作区依赖加载工具，取得 Node.js、`@oai/artifact-tool` 和 `node_modules` 路径；在 `E:\Codex-items\tmp\ca-monthly-upload-template\` 创建构建目录，并将 `node_modules` 以 Windows junction 方式指向加载器提供的依赖目录。

- [ ] **Step 2: 将字段设计写入构建脚本中的结构化常量**

在构建脚本中声明下列 Sheet 与字段数组，字段顺序必须与设计说明一致：

```js
const sheets = [
  '总表',
  '01-平台订单信息', '02-出库成本表', '03-快递订单表', '04-快递账单表',
  '05-Amazon回款账单', '06-Amazon佣金账单', '07-Amazon促销回款',
  '08-Amazon广告表', '09-Walmart回款账单', '10-Walmart广告表',
  '11-Wayfair回款账单', '12-CA月报调整表',
];
```

`04-快递账单表` 的字段数组必须包含：

```js
['id', 'dt_month', 'shop_code', 'platform_order_number', 'reference_no', 'sku_code', 'outbound_handling_fee', 'express_amount']
```

- [ ] **Step 3: 验证字段清单覆盖设计说明**

在构建脚本中添加断言：Sheet 数量为 13（含总表）；`04-快递账单表` 同时包含 `outbound_handling_fee` 和 `express_amount`；`12-CA月报调整表` 使用 `stat_month` 而不使用 `dt_month`。

### Task 2: 创建并格式化 Excel 模板

**Files:**
- Modify: `E:\Codex-items\tmp\ca-monthly-upload-template\build_ca_monthly_upload_template.mjs`
- Create: `E:\Codex-items\outputs\CA月报月度上载模板.xlsx`

**Interfaces:**
- Consumes: Task 1 中的 Sheet、字段和中文说明定义。
- Produces: 一份含总表和 12 个明细上载 Sheet 的 Excel 工作簿。

- [ ] **Step 1: 标记本次产物创建操作**

在第一次写入工作簿前，运行：

```powershell
node container_tools/mark_artifact_operation_started.mjs --operation-kind create --expected-output-count 1 --output-format xlsx
```

- [ ] **Step 2: 创建总表**

总表使用蓝色表头，列顺序固定为：

```text
序号、上载表名、上载表名称、Excel名称、Excel超链接、关键信息、上载状态、上载日期、填报人、校验结果
```

预填 12 行明细 Sheet 索引；“上载状态”设置为下拉值：`未收集`、`待校验`、`待上载`、`已上载`、`退回修改`。

- [ ] **Step 3: 创建并格式化所有明细 Sheet**

每个明细 Sheet 执行以下操作：

```text
第 1 行：英文物理字段，蓝底白字。
第 2 行：中文字段说明，红字。
冻结前两行；为第 1、2 行启用自动换行；设置筛选；预留第 3 至第 502 行用于填写。
```

按字段类型设置格式：

```text
id、shop_code、SKU、订单号、账单号、ASIN、状态和类型：文本。
dt_month：yyyy-mm-dd。
stat_month：yyyy-mm。
数量：#,##0。
金额：#,##0.00;[Red]-#,##0.00。
```

- [ ] **Step 4: 添加数据验证与填写提示**

为下列字段添加下拉验证：

```text
shop_code：CA-VC、CA-WM-WS、CA-WF。
09-Walmart回款账单.transaction_type：Sales、Returns、SFSEM、Commission Adjust、Reimbursements、AdSpendFee。
11-Wayfair回款账单.invoice_type：Deduction、Non-Deduction。
03-快递订单表.package_status：已作废、非已作废。
```

在 `04-快递账单表` 的第二行中文说明中明确显示“出库处理费”和“快递费金额”，并在 Sheet 顶部注释或填写提示中说明两项之和是快递账单总费用。

### Task 3: 校验、渲染并导出成品

**Files:**
- Modify: `E:\Codex-items\tmp\ca-monthly-upload-template\build_ca_monthly_upload_template.mjs`
- Create: `E:\Codex-items\outputs\CA月报月度上载模板.xlsx`

**Interfaces:**
- Consumes: Task 2 创建的工作簿。
- Produces: 经结构、公式错误和视觉检查的 `.xlsx` 文件。

- [ ] **Step 1: 检查关键 Sheet 的表头和值类型**

使用 `workbook.inspect` 检查：

```text
总表!A1:J13
01-平台订单信息!A1:J3
02-出库成本表!A1:J3
04-快递账单表!A1:H3
09-Walmart回款账单!A1:J3
12-CA月报调整表!A1:L3
```

验证字段顺序、中文说明和 `04-快递账单表` 的两项费用列均正确。

- [ ] **Step 2: 扫描公式错误**

使用正则搜索：

```text
#REF!|#DIV/0!|#VALUE!|#NAME\?|#N/A
```

预期结果为零个匹配项。

- [ ] **Step 3: 渲染全部 Sheet 进行视觉检查**

逐 Sheet 渲染 `A1` 至最后一个表头列、第 20 行；检查：标题未裁剪、双行表头可读、中文说明完整、金额列可见、筛选和冻结区域正常。

- [ ] **Step 4: 导出最终工作簿**

将工作簿导出为：

```text
E:\Codex-items\outputs\CA月报月度上载模板.xlsx
```

- [ ] **Step 5: 最终核对**

重新读取导出文件，确认包含 13 个 Sheet，并检查 `04-快递账单表` 中第 1 行的 G、H 列分别为 `outbound_handling_fee`、`express_amount`。
