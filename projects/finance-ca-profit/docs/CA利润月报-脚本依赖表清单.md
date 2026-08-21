# CA 利润月报脚本依赖表清单

脚本：`E:\jamf-data-warehouse\jamf-warehouse\ads\ads_bi_finance_ca_profit_month_info.sh`

本文基于脚本中的静态 SQL 引用整理，不执行数据库查询；表名、用途和引用位置均以脚本内容为准。

## 一、表数量概览

| 数据库 | 表数量 | 主要用途 |
|---|---:|---|
| `jamf_dis` | 11 张 | 销售、促销、物流成本、平台回款、广告及利润调整 |
| `jamf_develop_test` | 4 张 | Amazon 1P CA 回款、佣金、促销和广告 |
| **合计** | **15 张** |  |

## 二、`jamf_dis` 下的表

| 序号 | 表名 | 脚本中的业务用途 | 引用行 |
|---:|---|---|---:|
| 1 | `upload_bi_amazon_1p_sales_order_di` | Amazon 1P 上载销售订单；用于补充销售数量和销售金额 | 926 |
| 2 | `upload_bi_walmart_sales_order_di` | Walmart 上载销售订单；用于补充 WM 销售数量和销售金额 | 940 |
| 3 | `upload_bi_wayfair_sales_order_di` | Wayfair 上载销售订单；用于补充 WF 销售数量和销售金额 | 956 |
| 4 | `upload_bi_lg_shipping_order_di` | LG 物流订单；用于订单级物流成本匹配 | 1047、1442 |
| 5 | `amazon_1p_promotion` | Amazon 1P 促销数据；用于生成促销日期、SKU、折扣金额 | 1246 |
| 6 | `upload_bi_lg_shipping_fee_di` | LG 物流费用；用于海运费和头程物流费用 | 1363 |
| 7 | `upload_bi_outbound_cost_sheet_di` | 出库成本表；用于补充海运成本和头程物流费用 | 1415、1494 |
| 8 | `upload_bi_ca_walmart_payment_invoice_di` | Walmart CA 回款账单；用于佣金、退款佣金、固定营销费、佣金调整、补贴和广告费用 | 1659、1680、1699、1717、1737、1822 |
| 9 | `upload_bi_advertising_wm_ca_di` | Walmart CA 广告数据；用于广告费和广告归因销售金额 | 1771 |
| 10 | `upload_bi_wayfair_payment_invoice_di` | Wayfair CA 回款账单；用于 allowance 和 deduction 类回款/退款 | 1855、1893 |
| 11 | `upload_ca_profit_month_adjust_info` | CA 利润月报人工调整数据；用于最终利润结果调整 | 38、39、2663、2823 |

说明：第 38—39 行是该表的注释式建表定义，实际取数引用位于第 2663、2823 行。

## 三、`jamf_develop_test` 下的表

| 序号 | 表名 | 脚本中的业务用途 | 引用行 |
|---:|---|---|---:|
| 1 | `upload_bi_amazon_1p_ca_payment_invoice_di` | Amazon 1P CA 回款账单；用于销售回款和退款金额 | 1518、1611 |
| 2 | `upload_bi_amazon_1p_ca_commission_fee_di` | Amazon 1P CA 佣金明细；用于实际佣金金额 | 1573 |
| 3 | `upload_bi_amazon_1p_ca_estimate_commission_fee_ctt_di` | Amazon 1P CA 佣金/促销相关明细；用于实际促销金额 | 1593 |
| 4 | `upload_bi_advertising_amazon_1p_ca_sp_di` | Amazon 1P CA 广告数据；用于广告花费和广告归因订单金额 | 1629 |

## 四、按利润计算环节归类

| 利润环节 | 使用的表 |
|---|---|
| 销售订单 | `jamf_dis.upload_bi_amazon_1p_sales_order_di`、`jamf_dis.upload_bi_walmart_sales_order_di`、`jamf_dis.upload_bi_wayfair_sales_order_di` |
| 促销 | `jamf_dis.amazon_1p_promotion`、`jamf_develop_test.upload_bi_amazon_1p_ca_estimate_commission_fee_ctt_di` |
| 物流成本 | `jamf_dis.upload_bi_lg_shipping_order_di`、`jamf_dis.upload_bi_lg_shipping_fee_di`、`jamf_dis.upload_bi_outbound_cost_sheet_di` |
| Amazon 1P 回款/佣金/退款 | `jamf_develop_test.upload_bi_amazon_1p_ca_payment_invoice_di`、`jamf_develop_test.upload_bi_amazon_1p_ca_commission_fee_di` |
| Amazon 1P 广告 | `jamf_develop_test.upload_bi_advertising_amazon_1p_ca_sp_di` |
| Walmart 回款、佣金、退款、补贴、营销和广告 | `jamf_dis.upload_bi_ca_walmart_payment_invoice_di`、`jamf_dis.upload_bi_advertising_wm_ca_di` |
| Wayfair 回款和退款 | `jamf_dis.upload_bi_wayfair_payment_invoice_di` |
| 利润人工调整 | `jamf_dis.upload_ca_profit_month_adjust_info` |

## 五、依赖关系简图

```text
jamf_dis 销售订单表
  ├─ Amazon 1P 销售
  ├─ Walmart 销售
  └─ Wayfair 销售
          │
          ├─ 与 ERP 订单匹配
          ├─ 生成销售结果
          └─ 进入利润计算

jamf_dis 促销表 ───────────────┐
jamf_dis 物流订单/费用/成本表 ──┤
jamf_develop_test Amazon 回款类 ─┤→ CA 利润月报中间结果 → 最终利润结果
jamf_dis Walmart 回款/广告类 ────┤
jamf_dis Wayfair 回款类 ─────────┤
jamf_dis 利润调整表 ─────────────┘
```

## 六、范围说明

- 本清单只包含脚本中明确出现的 `jamf_dis` 和 `jamf_develop_test` 表。
- 脚本还使用了 `jamf_ads`、`jamf_erp`、`jamf_ams` 等库中的表，但不在本次清单范围内。
- 本文未验证各表当前是否存在、字段是否变化、数据是否完整；如需做依赖可用性或字段级核验，需要进一步执行数据库元数据查询。
