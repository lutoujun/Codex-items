# SFP 履约日报指标计算说明

## 一、数据范围

数据来源：`jamf_dw.dwd_shipping_order_info`

统一筛选范围：

- 店铺：VG（`US-VG`）、WS（`US-WS`）
- 包裹类型：SFP
- 发货状态：已推送、已发货
- 补发标记：不补发
- 仓库：CA、GA、IL、NJ、TX

仓库代码与通知简称对应关系：

| 仓库代码 | 通知简称 |
|---|---|
| `SLM-CA3` | CA |
| `SLM-GA3` | GA |
| `SLM-IL1` | IL |
| `SLM-NJ7` | NJ |
| `SLM-TX` | TX |

## 二、日期范围

日报日期为 `do_date`，脚本按美西时间计算：

- `do_last1_date`：日报日前一天
- `do_last2_date`：日报日前两天

| 通知指标 | 数据日期 | 业务含义 |
|---|---|---|
| 今日 SFP 订单 | `us_platform_order_create_date = do_last1_date` | 报表日前一天创建的平台订单 |
| 昨日 OTD | `us_platform_latest_delivery_date = do_last2_date` | 到达最晚送达日期的订单 |
| 昨日 PICKUP | `us_platform_latest_shipping_date = do_last2_date` | 到达最晚发货日期的订单 |

说明：通知中的“今日”和“昨日”是日报展示口径，实际数据日期以表格为准。

## 三、指标计算过程

### 1. 今日 SFP 订单

订单去重规则：

```text
订单唯一标识 = tracking_number
tracking_number 为空时使用 shipping_order_id
```

计算：

```text
今日 SFP 订单数
= 去重后的订单唯一标识数量
```

通知示例：

```text
VG【119】、WS【457】
```

### 2. 今日无法豁免订单

在“今日 SFP 订单”范围内，若订单标签包含以下任一内容，则计入无法豁免订单：

- `准时送达率受保护`
- `准时送达率受保护多箱订单`

计算：

```text
今日无法豁免订单数
= 命中上述标签的去重订单数量
```

通知示例：

```text
VG【112】、WS【451】
```

### 3. OTD（最晚送达）

数据范围：

```text
us_platform_latest_delivery_date = do_last2_date
```

达标规则：

```text
实际送达日期 us_deliver_date
<= 平台最晚送达日期 us_platform_latest_delivery_date
```

满足条件计为达标，否则计为不达标。实际送达日期为空时，按未达标处理。

计算：

```text
OTD 达标率 = 达标订单数 / OTD 订单总数 × 100%
不达标数 = OTD 订单总数 - 达标订单数
```

通知示例：

```text
VG：64 / 126 = 50.8%，不达标 62
WS：398 / 563 = 70.7%，不达标 165
```

### 4. PICKUP（最晚发货）

数据范围：

```text
us_platform_latest_shipping_date = do_last2_date
```

达标规则：

```text
快递第一枪日期 us_first_shoot_date
<= 平台最晚发货日期 us_platform_latest_shipping_date
```

满足条件计为达标，否则计为不达标。第一枪日期为空时，按未达标处理。

计算：

```text
PICKUP 达标率 = 达标订单数 / PICKUP 订单总数 × 100%
不达标数 = PICKUP 订单总数 - 达标订单数
```

通知示例：

```text
VG：0 / 3 = 0.0%，不达标 3
```

### 5. 平均 Zone

平均 Zone 按发货 SKU 数量加权计算：

```text
平均 Zone
= Σ（发货 SKU 数量 × Zone）/ Σ（发货 SKU 数量）
```

因此不是各订单 Zone 的简单平均，也不是各仓库平均值的简单平均。

通知示例：

```text
VG【3.28】、WS【3.37】
```

## 四、通知内容与指标对应关系

| 钉钉通知内容 | 对应指标 |
|---|---|
| 今日 SFP 订单 | 去重后的 SFP 订单数 |
| 今日无法豁免订单 | 命中无法豁免标签的去重订单数 |
| 平均 Zone | 按发货 SKU 数量加权的平均 Zone |
| 昨日 OTD | 最晚送达达标率 |
| 昨日 PICKUP | 最晚发货达标率 |
| `64/126` | 达标订单数 / 订单总数 |
| `异常：不达标62` | 不达标订单数 |
| CA、GA、IL、NJ、TX | 各仓库明细 |

## 五、指标计算链路

```text
dwd_shipping_order_info
  → 按店铺、仓库和日期筛选 SFP 订单
  → 计算订单是否达标、是否无法豁免
  → 按店铺和仓库汇总订单数、达标数、不达标数、平均 Zone
  → 生成钉钉日报
```
