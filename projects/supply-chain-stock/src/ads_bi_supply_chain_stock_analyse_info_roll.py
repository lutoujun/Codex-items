#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
补足 SH 脚本末尾【按周滚动库存推演】（SQL 无法自然递归，改用 Python 内存迭代）

用法：
  python3 ads_bi_supply_chain_stock_analyse_info_roll.py ${do_date}
  python3 ads_bi_supply_chain_stock_analyse_info_roll.py 2026-06-04 [start_week] [end_week]

粒度：stat_date × plan_data_source(PMC/运营/实销) × msku_code × week_flag
三类计划来源各自独立递归推算，互不串联。

公式：
  首周期初 = 海外仓 + 平台仓
  可用     = MAX(期初 - estimated_msku_sale_num, 0)   # 期末滚推用预估销量
  期末     = 可用 + 到港
  下周期初 = 本周期末
  可售天数 = 期初 × 7 / estimated_msku_sale_num（展示取整）
  周期分桶：仅原始天数为 0 时标「0」；有库存但不足 1 天（如 0.01）归入 [0-15]
  库存分层（按期初、以30天库存结构销量为容量）：正常 / 过剩 / 风险 / 呆滞
"""

import hashlib
import os
import sys
from collections import defaultdict
from datetime import datetime
from zoneinfo import ZoneInfo

import pymysql

SRC = "jamf_ads.ads_bi_supply_chain_stock_analyse_info_tmp99"
DST = "jamf_ads.ads_bi_supply_chain_stock_analyse_info"

HOST = os.getenv("DORIS_HOST") or os.getenv("DORIS_HISTORY_HOST", "172.16.254.118")
PORT = int(os.getenv("DORIS_PORT") or os.getenv("DORIS_HISTORY_PORT", "19030"))
USER = os.getenv("DORIS_USERNAME") or os.getenv("DORIS_HISTORY_USERNAME", "system_scheduling_rw_db")
PASS = os.getenv("DORIS_PASSWORD") or os.getenv("DORIS_HISTORY_PASSWORD", "VBswYKYX80")
DB = os.getenv("DORIS_DW_DATABASE") or os.getenv("DORIS_HISTORY_TEST_DATABASE", "jamf_ads")


def ws_modify_time_now() -> str:
    """数仓修改时间，默认美西时间（与 SH 中 pst_time 一致）。"""
    override = os.getenv("WS_MODIFY_TIME")
    if override:
        return override
    return datetime.now(ZoneInfo("America/Los_Angeles")).strftime("%Y-%m-%d %H:%M:%S")


def i(v):
    try:
        return int(float(v or 0))
    except (TypeError, ValueError):
        return 0


def pkey(stat_date, plan_data_source, msku, week_flag):
    return hashlib.md5(
        f"{stat_date}#{plan_data_source or ''}#{msku}#{week_flag}".encode()
    ).hexdigest()


def calc_sale_days(opening, sale_num):
    """返回 (展示天数, 原始天数)。原始天数用于周期分桶。"""
    if sale_num > 0:
        raw = opening * 7.0 / sale_num
        return int(round(raw)), raw
    if opening > 0:
        raw = float(999 * 7)
        return 999 * 7, raw
    return 0, 0.0


def cycle_flag(days_raw):
    """周期分桶：仅纯 0 天为「0」；有库存但不足 1 天（如 0.01）归入 [0-15]。"""
    if days_raw == 0:
        cyc = "0"
    elif days_raw <= 15:
        cyc = "[0-15]"
    elif days_raw <= 30:
        cyc = "[15-30]"
    elif days_raw <= 60:
        cyc = "[30-60]"
    elif days_raw <= 90:
        cyc = "[60-90]"
    elif days_raw <= 120:
        cyc = "[90-120]"
    else:
        cyc = "[120以上]"
    if days_raw == 0:
        flag = "正常库存"
    elif days_raw <= 30:
        flag = "正常库存"
    elif days_raw <= 60:
        flag = "过剩库存"
    elif days_raw <= 90:
        flag = "风险库存"
    else:
        flag = "呆滞库存"
    return cyc, flag


def layer_stock(opening, sale_num):
    """
    按库存结构销量将期初库存拆到四档（天数档位 0-30 / 30-60 / 60-90 / >90）：
      每档容量 = round(estimated_msku_sale_num × 30 / 7)
      自前向后填满：正常 → 过剩 → 风险 → 剩余进呆滞
    销量为 0 且期初 > 0：全部计入呆滞。
    """
    if opening <= 0:
        return 0, 0, 0, 0
    if sale_num <= 0:
        return 0, 0, 0, opening

    cap = int(round(sale_num * 30.0 / 7.0))
    if cap <= 0:
        return 0, 0, 0, opening

    remain = opening
    normal = min(remain, cap)
    remain -= normal
    excess = min(remain, cap)
    remain -= excess
    risk = min(remain, cap)
    remain -= risk
    slow = remain
    return normal, excess, risk, slow


def roll(rows, start_week=None, end_week=None):
    # 三类计划来源各自独立滚推：按 (plan_data_source, msku_code) 分组
    by_key = defaultdict(list)
    for r in rows:
        by_key[(r[2], r[3])].append(r)

    out = []
    for (_src, msku), weeks in by_key.items():
        weeks.sort(key=lambda x: i(x[9]))  # week_id
        opening = 0
        for idx, r in enumerate(weeks):
            (
                _pkey,
                stat_date,
                plan_data_source,
                msku_code,
                level,
                level_desc,
                cat2_id,
                cat2_name,
                week_flag,
                week_id,
                w_start,
                w_end,
                purchase_plan_msku_flag,
                hw,
                pt,
                arrival,
                estimated_sale,
                stock_str_sale,
            ) = r
            week_id = i(week_id)
            hw = i(hw)
            pt = i(pt)
            estimated_sale = i(estimated_sale)
            stock_str_sale = i(stock_str_sale)
            arrival = i(arrival)
            if idx == 0:
                opening = hw + pt

            week_opening = opening
            # 期末滚推：扣减 estimated_msku_sale_num
            closing = max(opening - estimated_sale, 0) + arrival
            # 可售天数 / 周期标签 / 库存分层：用 estimated_msku_sale_num
            days, days_raw = calc_sale_days(week_opening, estimated_sale)
            cyc, flag = cycle_flag(days_raw)
            normal, excess, risk, slow = layer_stock(week_opening, estimated_sale)

            if (start_week is None or week_id >= start_week) and (
                end_week is None or week_id <= end_week
            ):
                out.append(
                    (
                        _pkey
                        or pkey(stat_date, plan_data_source, msku_code, week_flag),
                        stat_date,
                        plan_data_source,
                        msku_code,
                        level,
                        level_desc,
                        cat2_id,
                        cat2_name,
                        week_flag,
                        week_id,
                        w_start,
                        w_end,
                        purchase_plan_msku_flag,
                        hw,
                        pt,
                        arrival,
                        estimated_sale,
                        stock_str_sale,
                        week_opening,
                        closing,
                        days,
                        cyc,
                        flag,
                        normal,
                        excess,
                        risk,
                        slow,
                    )
                )
            opening = closing
    return out


def main():
    if len(sys.argv) < 2:
        print(
            "用法: python3 ads_bi_supply_chain_stock_analyse_info_roll.py "
            "<do_date> [start_week] [end_week]"
        )
        return 1

    do_date = sys.argv[1]
    start_week = int(sys.argv[2]) if len(sys.argv) > 2 else None
    end_week = int(sys.argv[3]) if len(sys.argv) > 3 else None

    print(f"[roll] start do_date={do_date} week=[{start_week}, {end_week}] host={HOST}:{PORT}")

    conn = pymysql.connect(
        host=HOST, port=PORT, user=USER, password=PASS, database=DB,
        charset="utf8mb4", autocommit=False,
    )
    try:
        with conn.cursor() as cur:
            cur.execute(
                f"""
                SELECT pkey, stat_date, plan_data_source, msku_code,
                       msku_product_level, msku_product_level_desc,
                       msku_category2_id, msku_category2_name, week_flag, week_id,
                       week_start_date, week_end_date, purchase_plan_msku_flag,
                       msku_hwstock_num, msku_ptstock_num,
                       msku_port_arrival_num, estimated_msku_sale_num,
                       stock_str_msku_sale_num
                FROM {SRC}
                WHERE stat_date = %s
                ORDER BY plan_data_source, msku_code, week_id
                """,
                (do_date,),
            )
            rows = cur.fetchall()
            print(f"[roll] loaded tmp99 rows={len(rows)}")

            results = roll(rows, start_week, end_week)
            print(f"[roll] computed rows={len(results)}")

            by_src = defaultdict(int)
            for r in results:
                by_src[r[2] or ""] += 1
            print(f"[roll] by plan_data_source: {dict(by_src)}")

            ws_time = ws_modify_time_now()
            results = [(*r, ws_time) for r in results]

            cur.execute(f"DELETE FROM {DST} WHERE stat_date = %s", (do_date,))
            print(f"[roll] deleted old rows affected={cur.rowcount}")

            sql = f"""
                INSERT INTO {DST} (
                    pkey, stat_date, plan_data_source, msku_code,
                    msku_product_level, msku_product_level_desc,
                    msku_category2_id, msku_category2_name, week_flag, week_id,
                    week_start_date, week_end_date, purchase_plan_msku_flag,
                    msku_hwstock_num, msku_ptstock_num, msku_port_arrival_num,
                    estimated_msku_sale_num, stock_str_msku_sale_num,
                    msku_opening_stock_num, msku_stock_num,
                    msku_estimated_sale_days, msku_estimated_cycle, stock_flag_desc,
                    normal_stock_num, excess_stock_num, risk_stock_num, slow_stock_num,
                    ws_modify_time
                ) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
            """
            batch = 2000
            for i0 in range(0, len(results), batch):
                part = results[i0 : i0 + batch]
                cur.executemany(sql, part)
                print(f"[roll] insert {i0 + len(part)}/{len(results)}")

        conn.commit()
        print("[roll] done")
        return 0
    except Exception as e:
        conn.rollback()
        print(f"[roll] FAILED: {e}")
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    sys.exit(main())
