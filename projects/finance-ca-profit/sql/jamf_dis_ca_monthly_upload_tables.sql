## CA 利润月报人工上载表
## 数据库：jamf_dis
## 说明：dt_month 统一填写为 yyyy-MM-01；调整表 stat_month 填写为 yyyy-MM

##  -- CREATE TABLE jamf_dis.upload_bi_ca_sales_order_di
CREATE TABLE IF NOT EXISTS jamf_dis.upload_bi_ca_sales_order_di (
    id                    bigint          NOT NULL COMMENT '主键'                    ,
    dt_month              date            DEFAULT NULL COMMENT '分区日期YYYY-MM-01' ,
    shop_code             varchar(50)     DEFAULT NULL COMMENT '店铺代码'            ,
    seller_sku_code       varchar(100)    DEFAULT NULL COMMENT 'SellerSKU代码'       ,
    platform_order_number varchar(100)    DEFAULT NULL COMMENT '平台订单号'          ,
    order_status          varchar(64)     DEFAULT NULL COMMENT '订单状态'            ,
    order_create_time     varchar(64)     DEFAULT NULL COMMENT '订单创建时间'        ,
    sales_num             bigint          DEFAULT NULL COMMENT '销售数量'            ,
    sales_price           decimalv3(18,6) DEFAULT NULL COMMENT '销售单价'            ,
    sales_amount          decimalv3(18,6) DEFAULT NULL COMMENT '销售金额'
) ENGINE=olap
UNIQUE KEY(id)
COMMENT 'CA月报-平台订单上载表'
DISTRIBUTED BY HASH(id) BUCKETS 1
PROPERTIES ('replication_num' = '1');

##  -- CREATE TABLE jamf_dis.upload_bi_ca_outbound_cost_sheet_di
CREATE TABLE IF NOT EXISTS jamf_dis.upload_bi_ca_outbound_cost_sheet_di (
    id               bigint          NOT NULL COMMENT '主键'                    ,
    dt_month         date            DEFAULT NULL COMMENT '分区日期YYYY-MM-01' ,
    sku_code         varchar(100)    DEFAULT NULL COMMENT '单箱SKU代码'         ,
    warehouse        varchar(64)     DEFAULT NULL COMMENT '仓库'                ,
    ddp_total_cost   decimalv3(18,6) DEFAULT NULL COMMENT 'DDP成本合计'         ,
    fob_cost         decimalv3(18,6) DEFAULT NULL COMMENT '产品FOB成本'         ,
    shipping_cost    decimalv3(18,6) DEFAULT NULL COMMENT '海运费成本'          ,
    logistics_fee    decimalv3(18,6) DEFAULT NULL COMMENT '头程物流费用'        ,
    product_tariffs  decimalv3(18,6) DEFAULT NULL COMMENT '产品关税'            ,
    storage_fee      decimalv3(18,6) DEFAULT NULL COMMENT '入库费'
) ENGINE=olap
UNIQUE KEY(id)
COMMENT 'CA月报-出库成本上载表'
DISTRIBUTED BY HASH(id) BUCKETS 1
PROPERTIES ('replication_num' = '1');

##  -- CREATE TABLE jamf_dis.upload_bi_ca_shipping_order_di
CREATE TABLE IF NOT EXISTS jamf_dis.upload_bi_ca_shipping_order_di (
    id                    bigint          NOT NULL COMMENT '主键'                    ,
    dt_month              date            DEFAULT NULL COMMENT '分区日期YYYY-MM-01' ,
    shop_code             varchar(50)     DEFAULT NULL COMMENT '店铺代码'            ,
    platform_order_number varchar(100)    DEFAULT NULL COMMENT '平台订单号'          ,
    reference_no          varchar(100)    DEFAULT NULL COMMENT '客户单号'            ,
    sku_code              varchar(100)    DEFAULT NULL COMMENT '单箱SKU代码'         ,
    express_amount        decimalv3(18,6) DEFAULT NULL COMMENT '快递费金额'          ,
    package_status        varchar(64)     DEFAULT NULL COMMENT '包裹状态'
) ENGINE=olap
UNIQUE KEY(id)
COMMENT 'CA月报-快递订单上载表'
DISTRIBUTED BY HASH(id) BUCKETS 1
PROPERTIES ('replication_num' = '1');

##  -- CREATE TABLE jamf_dis.upload_bi_ca_shipping_fee_di
CREATE TABLE IF NOT EXISTS jamf_dis.upload_bi_ca_shipping_fee_di (
    id                    bigint          NOT NULL COMMENT '主键'                    ,
    dt_month              date            DEFAULT NULL COMMENT '分区日期YYYY-MM-01' ,
    shop_code             varchar(50)     DEFAULT NULL COMMENT '店铺代码'            ,
    platform_order_number varchar(100)    DEFAULT NULL COMMENT '平台订单号'          ,
    reference_no          varchar(100)    DEFAULT NULL COMMENT '客户单号'            ,
    sku_code              varchar(100)    DEFAULT NULL COMMENT '单箱SKU代码'         ,
    outbound_handling_fee decimalv3(18,6) DEFAULT NULL COMMENT '出库处理费'          ,
    express_amount        decimalv3(18,6) DEFAULT NULL COMMENT '快递费金额'
) ENGINE=olap
UNIQUE KEY(id)
COMMENT 'CA月报-快递账单上载表'
DISTRIBUTED BY HASH(id) BUCKETS 1
PROPERTIES ('replication_num' = '1');

##  -- CREATE TABLE jamf_dis.upload_bi_ca_amazon_payment_invoice_di
CREATE TABLE IF NOT EXISTS jamf_dis.upload_bi_ca_amazon_payment_invoice_di (
    id                   bigint          NOT NULL COMMENT '主键'                    ,
    dt_month             date            DEFAULT NULL COMMENT '分区日期YYYY-MM-01' ,
    shop_code            varchar(50)     DEFAULT NULL COMMENT '店铺代码'            ,
    invoice_number       varchar(100)    DEFAULT NULL COMMENT 'Amazon账单号'        ,
    description          varchar(500)    DEFAULT NULL COMMENT '账单描述'            ,
    terms_discount_taken decimalv3(18,6) DEFAULT NULL COMMENT '账期折扣金额'        ,
    invoice_amount       decimalv3(18,6) DEFAULT NULL COMMENT '账单金额'
) ENGINE=olap
UNIQUE KEY(id)
COMMENT 'CA月报-Amazon回款账单上载表'
DISTRIBUTED BY HASH(id) BUCKETS 1
PROPERTIES ('replication_num' = '1');

##  -- CREATE TABLE jamf_dis.upload_bi_ca_amazon_commission_fee_di
CREATE TABLE IF NOT EXISTS jamf_dis.upload_bi_ca_amazon_commission_fee_di (
    id                                      bigint          NOT NULL COMMENT '主键'                    ,
    dt_month                                date            DEFAULT NULL COMMENT '分区日期YYYY-MM-01' ,
    shop_code                               varchar(50)     DEFAULT NULL COMMENT '店铺代码'            ,
    amazon_sku_asin                         varchar(100)    DEFAULT NULL COMMENT 'Amazon ASIN'         ,
    platform_order_number                   varchar(100)    DEFAULT NULL COMMENT '平台订单号'          ,
    new_vendor_funding                      decimalv3(18,6) DEFAULT NULL COMMENT '新版供应商佣金金额',
    vendor_funding_in_agreement_currency    decimalv3(18,6) DEFAULT NULL COMMENT '协议币种佣金金额'
) ENGINE=olap
UNIQUE KEY(id)
COMMENT 'CA月报-Amazon佣金账单上载表'
DISTRIBUTED BY HASH(id) BUCKETS 1
PROPERTIES ('replication_num' = '1');

##  -- CREATE TABLE jamf_dis.upload_bi_ca_amazon_promotion_payment_di
CREATE TABLE IF NOT EXISTS jamf_dis.upload_bi_ca_amazon_promotion_payment_di (
    id                    bigint          NOT NULL COMMENT '主键'                    ,
    dt_month              date            DEFAULT NULL COMMENT '分区日期YYYY-MM-01' ,
    shop_code             varchar(50)     DEFAULT NULL COMMENT '店铺代码'            ,
    seller_sku_code       varchar(100)    DEFAULT NULL COMMENT 'SellerSKU代码'       ,
    payment_promot_amount decimalv3(18,6) DEFAULT NULL COMMENT '实际促销回款金额'
) ENGINE=olap
UNIQUE KEY(id)
COMMENT 'CA月报-Amazon促销回款上载表'
DISTRIBUTED BY HASH(id) BUCKETS 1
PROPERTIES ('replication_num' = '1');

##  -- CREATE TABLE jamf_dis.upload_bi_ca_amazon_advertising_di
CREATE TABLE IF NOT EXISTS jamf_dis.upload_bi_ca_amazon_advertising_di (
    id              bigint          NOT NULL COMMENT '主键'                    ,
    dt_month        date            DEFAULT NULL COMMENT '分区日期YYYY-MM-01' ,
    shop_code       varchar(50)     DEFAULT NULL COMMENT '店铺代码'            ,
    amazon_sku_asin varchar(100)    DEFAULT NULL COMMENT '投放ASIN'             ,
    ad_spend        decimalv3(18,6) DEFAULT NULL COMMENT '广告花费'            ,
    ad_sales_14d    decimalv3(18,6) DEFAULT NULL COMMENT '14天归因销售额'
) ENGINE=olap
UNIQUE KEY(id)
COMMENT 'CA月报-Amazon广告上载表'
DISTRIBUTED BY HASH(id) BUCKETS 1
PROPERTIES ('replication_num' = '1');

##  -- CREATE TABLE jamf_dis.upload_bi_ca_walmart_payment_invoice_di
CREATE TABLE IF NOT EXISTS jamf_dis.upload_bi_ca_walmart_payment_invoice_di (
    id                    bigint          NOT NULL COMMENT '主键'                    ,
    dt_month              date            DEFAULT NULL COMMENT '分区日期YYYY-MM-01' ,
    shop_code             varchar(50)     DEFAULT NULL COMMENT '店铺代码'            ,
    transaction_type      varchar(100)    DEFAULT NULL COMMENT '交易类型'            ,
    seller_sku_code       varchar(100)    DEFAULT NULL COMMENT 'SellerSKU代码'       ,
    platform_order_number varchar(100)    DEFAULT NULL COMMENT '平台订单号'          ,
    product_price         decimalv3(18,6) DEFAULT NULL COMMENT '商品单价'            ,
    shipped_qty           bigint          DEFAULT NULL COMMENT '发货数量'            ,
    referral_amount       decimalv3(18,6) DEFAULT NULL COMMENT '佣金金额'            ,
    pay_to_partner        decimalv3(18,6) DEFAULT NULL COMMENT '与商家结算金额'
) ENGINE=olap
UNIQUE KEY(id)
COMMENT 'CA月报-Walmart回款账单上载表'
DISTRIBUTED BY HASH(id) BUCKETS 1
PROPERTIES ('replication_num' = '1');

##  -- CREATE TABLE jamf_dis.upload_bi_ca_walmart_advertising_di
CREATE TABLE IF NOT EXISTS jamf_dis.upload_bi_ca_walmart_advertising_di (
    id                       bigint          NOT NULL COMMENT '主键'                    ,
    dt_month                 date            DEFAULT NULL COMMENT '分区日期YYYY-MM-01' ,
    shop_code                varchar(50)     DEFAULT NULL COMMENT '店铺代码'            ,
    campaign_name            varchar(255)    DEFAULT NULL COMMENT '广告活动名称'        ,
    ad_spend                 decimalv3(18,6) DEFAULT NULL COMMENT '广告花费'            ,
    total_attributed_sales   decimalv3(18,6) DEFAULT NULL COMMENT '广告归因销售额'
) ENGINE=olap
UNIQUE KEY(id)
COMMENT 'CA月报-Walmart广告上载表'
DISTRIBUTED BY HASH(id) BUCKETS 1
PROPERTIES ('replication_num' = '1');

##  -- CREATE TABLE jamf_dis.upload_bi_ca_wayfair_payment_invoice_di
CREATE TABLE IF NOT EXISTS jamf_dis.upload_bi_ca_wayfair_payment_invoice_di (
    id                                 bigint          NOT NULL COMMENT '主键'                    ,
    dt_month                           date            DEFAULT NULL COMMENT '分区日期YYYY-MM-01' ,
    shop_code                          varchar(50)     DEFAULT NULL COMMENT '店铺代码'            ,
    platform_order_number              varchar(100)    DEFAULT NULL COMMENT '平台订单号'          ,
    invoice_type                       varchar(100)    DEFAULT NULL COMMENT '账单类型'            ,
    wayfair_ca_allowance_for_damages   decimalv3(18,6) DEFAULT NULL COMMENT '损耗Allowance金额'  ,
    product_amount                     decimalv3(18,6) DEFAULT NULL COMMENT '商品回款金额'        ,
    payment_amount                     decimalv3(18,6) DEFAULT NULL COMMENT '退款金额'
) ENGINE=olap
UNIQUE KEY(id)
COMMENT 'CA月报-Wayfair回款账单上载表'
DISTRIBUTED BY HASH(id) BUCKETS 1
PROPERTIES ('replication_num' = '1');

##  -- CREATE TABLE jamf_dis.upload_ca_profit_month_adjust_info
CREATE TABLE IF NOT EXISTS jamf_dis.upload_ca_profit_month_adjust_info (
    id                       bigint          NOT NULL COMMENT '主键'              ,
    stat_month               varchar(7)      DEFAULT NULL COMMENT '统计月份YYYY-MM',
    shop_code                varchar(50)     DEFAULT NULL COMMENT '店铺代码'        ,
    seller_sku_code          varchar(100)    DEFAULT NULL COMMENT 'SellerSKU代码'   ,
    sales_num                bigint          DEFAULT NULL COMMENT '销售数量调整'    ,
    sales_amount             decimalv3(18,6) DEFAULT NULL COMMENT '销售金额调整'    ,
    terms_amount             decimalv3(18,6) DEFAULT NULL COMMENT '账期金额调整'    ,
    commission_amount        decimalv3(18,6) DEFAULT NULL COMMENT '佣金金额调整'    ,
    promot_amount            decimalv3(18,6) DEFAULT NULL COMMENT '促销金额调整'    ,
    last_mile_express_amount decimalv3(18,6) DEFAULT NULL COMMENT '尾程快递费调整'  ,
    brushing_expense_amount  decimalv3(18,6) DEFAULT NULL COMMENT '刷单费用调整'    ,
    remark_info              varchar(500)    DEFAULT NULL COMMENT '调整原因说明'
) ENGINE=olap
UNIQUE KEY(id)
COMMENT 'CA月报人工调整上载表'
DISTRIBUTED BY HASH(id) BUCKETS 1
PROPERTIES ('replication_num' = '1');
