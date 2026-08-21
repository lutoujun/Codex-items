# CA 月报月度上载模板设计说明

## 1. 目标与范围

本设计用于固化 CA 利润月报的人工月度上载模板。模板以现有脚本
`E:\jamf-data-warehouse\jamf-warehouse\ads\ads_bi_finance_ca_profit_month_info.sh`
为下游计算依据，并沿用业务已设计的 Excel 样式。

范围仅包含脚本中需要人工上载的 `upload_*` 数据；`jamf_dis.amazon_1p_promotion` 不纳入本模板。

## 2. 统一模板规范

### 2.1 工作簿结构

工作簿由 1 个总表和 12 个明细上载 Sheet 构成。

- 第 1 行：英文物理字段名。
- 第 2 行：中文业务说明。
- 明细从第 3 行开始填写。
- `id` 为每行唯一主键，由上载人员填写；不得重复、不得为空。
- 代码、订单号、SKU、账单号等均按文本保存；数量和金额按数值保存。
- 金额字段不在模板中填写公式，保留来源原始金额。

### 2.2 月份填写规则

除“CA 月报调整表”外，所有模板使用字段 `dt_month`，填写为每月第一天：

```text
2026-08-01
```

原因：现有月报脚本按 `dt_month = yyyy-MM-01` 过滤上载数据。

现有截图中 `dt_month` 的中文说明为“分区日期YYYY-MM”；字段名不变，建议在最终模板中将中文说明修正为“分区日期YYYY-MM-01”。

“CA 月报调整表”使用 `stat_month`，填写为：

```text
2026-08
```

## 3. 总表设计

总表沿用业务已设计的索引样式，字段如下：

| 序号 | 上载表名 | 上载表名称 | Excel名称 | Excel超链接 | 关键信息 | 上载状态 | 上载日期 | 填报人 | 校验结果 |
|---:|---|---|---|---|---|---|---|---|---|

其中“关键信息”应写明适用店铺、平台、供应商或关键业务限制；“上载状态”建议统一为：未收集、待校验、待上载、已上载、退回修改。

### 3.1 `jamf_dis` 建表命名

| Sheet | 规范表名 |
|---|---|
| 01-平台订单信息 | `jamf_dis.upload_bi_ca_sales_order_di` |
| 02-出库成本表 | `jamf_dis.upload_bi_ca_outbound_cost_sheet_di` |
| 03-快递订单表 | `jamf_dis.upload_bi_ca_shipping_order_di` |
| 04-快递账单表 | `jamf_dis.upload_bi_ca_shipping_fee_di` |
| 05-Amazon回款账单 | `jamf_dis.upload_bi_ca_amazon_payment_invoice_di` |
| 06-Amazon佣金账单 | `jamf_dis.upload_bi_ca_amazon_commission_fee_di` |
| 07-Amazon促销回款 | `jamf_dis.upload_bi_ca_amazon_promotion_payment_di` |
| 08-Amazon广告表 | `jamf_dis.upload_bi_ca_amazon_advertising_di` |
| 09-Walmart回款账单 | `jamf_dis.upload_bi_ca_walmart_payment_invoice_di` |
| 10-Walmart广告表 | `jamf_dis.upload_bi_ca_walmart_advertising_di` |
| 11-Wayfair回款账单 | `jamf_dis.upload_bi_ca_wayfair_payment_invoice_di` |
| 12-CA月报调整表 | `jamf_dis.upload_ca_profit_month_adjust_info` |

## 4. 已设计 Sheet 的固化口径

### 4.1 01-平台订单信息

保留业务已设计字段顺序：

| 英文字段 | 中文说明 | 填写规则 |
|---|---|---|
| `id` | 序号/主键 | 必填且唯一 |
| `dt_month` | 分区日期YYYY-MM-01 | 必填，例如 `2026-08-01` |
| `shop_code` | 店铺代码 | 必填：`CA-VC`、`CA-WM-WS`、`CA-WF` |
| `seller_sku_code` | SellerSKU代码 | 必填 |
| `platform_order_number` | 平台订单号 | 必填 |
| `order_status` | 订单状态 | 按平台原始状态填写 |
| `order_create_time` | 订单创建时间 | 按平台原始时间填写 |
| `sales_num` | 销售数量 | 数值 |
| `sales_price` | 销售单价 | 数值 |
| `sales_amount` | 销售金额 | 数值，建议与数量×单价核对 |

该 Sheet 是合并模板：按 `shop_code` 分流至脚本原有的 Amazon 1P、Walmart、Wayfair 三类销售订单上载表。

### 4.2 02-出库成本表

保留业务已设计字段顺序：

| 英文字段 | 中文说明 | 填写规则 |
|---|---|---|
| `id` | 主键 | 必填且唯一 |
| `dt_month` | 分区日期YYYY-MM-01 | 必填，例如 `2026-08-01` |
| `sku_code` | 单箱SKU代码 | 必填 |
| `warehouse` | 仓库 | 当前脚本取值为 `LECANGS` |
| `ddp_total_cost` | DDP成本合计 | 数值 |
| `fob_cost` | 产品FOB成本 | 数值 |
| `shipping_cost` | 海运费成本 | 数值 |
| `logistics_fee` | 头程物流费用 | 数值 |
| `product_tariffs` | 产品关税 | 数值 |
| `storage_fee` | 入库费 | 数值 |

对应新上载表：`jamf_dis.upload_bi_ca_outbound_cost_sheet_di`。

## 5. 待补齐 Sheet 设计

### 5.1 03-快递订单表

对应新上载表：`jamf_dis.upload_bi_ca_shipping_order_di`。

| 英文字段 | 中文说明 |
|---|---|
| `id` | 主键 |
| `dt_month` | 分区日期YYYY-MM-01 |
| `shop_code` | 店铺代码 |
| `platform_order_number` | 平台订单号 |
| `reference_no` | 客户单号 |
| `sku_code` | 单箱SKU代码 |
| `express_amount` | 快递费金额 |
| `package_status` | 包裹状态 |

脚本规则：仅使用 `CA-VC`、`CA-WM-WS`、`CA-WF` 三个店铺，且剔除“已作废”包裹。

### 5.2 04-快递账单表

对应新上载表：`jamf_dis.upload_bi_ca_shipping_fee_di`。

| 英文字段 | 中文说明 |
|---|---|
| `id` | 主键 |
| `dt_month` | 分区日期YYYY-MM-01 |
| `shop_code` | 店铺代码 |
| `platform_order_number` | 平台订单号 |
| `reference_no` | 客户单号 |
| `sku_code` | 单箱SKU代码 |
| `outbound_handling_fee` | 出库处理费 |
| `express_amount` | 快递费金额 |

费用口径：

```text
快递账单总费用 = 出库处理费 + 快递费金额
```

两项费用均应按来源账单原始金额填写；无对应费用时填 `0`，不留空。这样可同时支持当前利润月报中的尾程费用汇总，以及后续对出库处理费和快递费的单独分析。

### 5.2.1 与现有脚本的衔接

现有脚本读取 `jamf_dis.upload_bi_lg_shipping_fee_di.total_fee` 作为快递费金额。新表上线后，脚本需要同步改为读取新表，并使用：

```text
express_amount = nvl(outbound_handling_fee,0) + nvl(express_amount,0)
```

在脚本改造完成前，新表不能直接替代现有来源表；月报仍应继续使用旧表，避免快递费用漏算。

### 5.3 05-Amazon回款账单

对应新上载表：`jamf_dis.upload_bi_ca_amazon_payment_invoice_di`。

| 英文字段 | 中文说明 |
|---|---|
| `id` | 主键 |
| `dt_month` | 分区日期YYYY-MM-01 |
| `shop_code` | 店铺代码，固定 `CA-VC` |
| `invoice_number` | Amazon账单/平台订单号 |
| `description` | 账单描述 |
| `terms_discount_taken` | 账期折扣金额 |
| `invoice_amount` | 账单金额 |

脚本使用该表计算销售回款、账期金额和 Damage Allowance 类退款。

### 5.4 06-Amazon佣金账单

对应新上载表：`jamf_dis.upload_bi_ca_amazon_commission_fee_di`。

| 英文字段 | 中文说明 |
|---|---|
| `id` | 主键 |
| `dt_month` | 分区日期YYYY-MM-01 |
| `shop_code` | 店铺代码，固定 `CA-VC` |
| `amazon_sku_asin` | Amazon ASIN |
| `platform_order_number` | 平台订单号 |
| `new_vendor_funding` | 新版供应商佣金金额 |
| `vendor_funding_in_agreement_currency` | 协议币种佣金金额 |

脚本优先取 `new_vendor_funding`；为空时取 `vendor_funding_in_agreement_currency`。

### 5.5 07-Amazon促销回款

对应新上载表：`jamf_dis.upload_bi_ca_amazon_promotion_payment_di`。

| 英文字段 | 中文说明 |
|---|---|
| `id` | 主键 |
| `dt_month` | 分区日期YYYY-MM-01 |
| `shop_code` | 店铺代码，固定 `CA-VC` |
| `seller_sku_code` | SellerSKU代码 |
| `payment_promot_amount` | 实际促销回款金额 |

### 5.6 08-Amazon广告表

对应新上载表：`jamf_dis.upload_bi_ca_amazon_advertising_di`。

| 英文字段 | 中文说明 |
|---|---|
| `id` | 主键 |
| `dt_month` | 分区日期YYYY-MM-01 |
| `shop_code` | 店铺代码，固定 `CA-VC` |
| `amazon_sku_asin` | 投放ASIN |
| `ad_spend` | 广告花费 |
| `ad_sales_14d` | 14天归因销售额 |

### 5.7 09-Walmart回款账单

对应新上载表：`jamf_dis.upload_bi_ca_walmart_payment_invoice_di`。

| 英文字段 | 中文说明 |
|---|---|
| `id` | 主键 |
| `dt_month` | 分区日期YYYY-MM-01 |
| `shop_code` | 店铺代码，固定 `CA-WM-WS` |
| `transaction_type` | 交易类型 |
| `seller_sku_code` | SellerSKU代码 |
| `platform_order_number` | 平台订单号 |
| `product_price` | 商品单价 |
| `shipped_qty` | 发货数量 |
| `referral_amount` | 佣金金额 |
| `pay_to_partner` | 与商家结算金额 |

`transaction_type` 是必填分类字段，当前脚本至少使用：`Sales`、`Returns`、`SFSEM`、`Commission Adjust`、`Reimbursements`、`AdSpendFee`。

### 5.8 10-Walmart广告表

对应新上载表：`jamf_dis.upload_bi_ca_walmart_advertising_di`。

| 英文字段 | 中文说明 |
|---|---|
| `id` | 主键 |
| `dt_month` | 分区日期YYYY-MM-01 |
| `shop_code` | 店铺代码，固定 `CA-WM-WS` |
| `campaign_name` | 广告活动名称 |
| `ad_spend` | 广告花费 |
| `total_attributed_sales` | 广告归因销售额 |

### 5.9 11-Wayfair回款账单

对应新上载表：`jamf_dis.upload_bi_ca_wayfair_payment_invoice_di`。

| 英文字段 | 中文说明 |
|---|---|
| `id` | 主键 |
| `dt_month` | 分区日期YYYY-MM-01 |
| `shop_code` | 店铺代码，固定 `CA-WF` |
| `platform_order_number` | 平台订单号 |
| `invoice_type` | 账单类型 |
| `wayfair_ca_allowance_for_damages` | 损耗Allowance金额 |
| `product_amount` | 商品回款金额 |
| `payment_amount` | 退款金额 |

脚本中 `invoice_type = Deduction` 计为退款，其他类型计入正常回款。

### 5.10 12-CA月报调整表

对应脚本来源表：`jamf_dis.upload_ca_profit_month_adjust_info`。

| 英文字段 | 中文说明 |
|---|---|
| `id` | 主键 |
| `stat_month` | 统计月份YYYY-MM |
| `shop_code` | 店铺代码 |
| `seller_sku_code` | SellerSKU代码 |
| `sales_num` | 销售数量调整 |
| `sales_amount` | 销售金额调整 |
| `terms_amount` | 账期金额调整 |
| `commission_amount` | 佣金金额调整 |
| `promot_amount` | 促销金额调整 |
| `last_mile_express_amount` | 尾程快递费调整 |
| `brushing_expense_amount` | 刷单费用调整 |
| `remark_info` | 调整原因说明 |

调整表只填写需要人工修正的记录；未调整的指标保持空值或 0，并在 `remark_info` 中说明原因与依据。

## 6. 模板与现有脚本的字段映射原则

业务模板采用统一字段名，脚本现有来源表的字段差异由上载转换处理：

| 模板字段 | Amazon订单原字段 | Walmart订单原字段 | Wayfair订单原字段 |
|---|---|---|---|
| `seller_sku_code` | `sku` | `sku` | `item_number` |
| `platform_order_number` | `order_id` | `po_number` | `po_number` |
| `sales_num` | `item_quantity` | `qty` | `quantity` |
| `sales_price` | `item_cost` | `item_cost` | `wholesale_price` |
| `order_create_time` | `order_place_date` | `order_date` | `po_date_time` |

物流模板同理统一为 `shop_code`、`sku_code`、`platform_order_number`、`express_amount`；上载转换时再映射到 LG 订单或账单原字段。

优化后的快递账单表例外：它新增 `outbound_handling_fee`，脚本改造时应将该字段与 `express_amount` 相加后作为当前月报中的尾程快递费用；若后续利润报表需要拆分展示，两字段可分别进入新增指标。

## 7. 月度使用流程

```text
收集各平台/供应商原始文件
  → 按对应 Sheet 填写或粘贴
  → 检查月份、店铺、主键、金额和关键分类字段
  → 在总表更新文件链接、状态和校验结果
  → 进行上载转换并写入对应 upload 表
  → 新快递账单表上线后，核对出库处理费 + 快递费金额与旧账单总费用
  → 运行 CA 利润月报脚本
```

## 8. 验收标准

- 12 个明细 Sheet 均使用双行表头。
- 字段顺序与本文一致，已有 01、02 Sheet 不改变业务已设计的字段结构。
- 订单类数据可通过 `shop_code` 区分 CA-VC、CA-WM-WS、CA-WF。
- 每条记录都有唯一 `id`，每个 Sheet 的月份格式符合脚本过滤条件。
- Walmart 回款的 `transaction_type`、Wayfair 回款的 `invoice_type`、物流订单的 `package_status` 均可支持脚本分支计算。
- 快递账单表同时具备 `outbound_handling_fee` 与 `express_amount` 两个金额字段；新旧切换时，两字段之和需与旧账单总费用核对一致。
