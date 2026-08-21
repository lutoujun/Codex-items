# 月滚动销售计划监控 Shell Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 创建可嵌入原月滚动计划脚本的 Shell，在十家店铺上传达标后执行原有 SQL，并按月防止重复入库。

**Architecture:** 新 Shell 作为可复制到原脚本中的监控段，直接沿用前面已计算好的 `do_month` 和已加载的 Doris 配置，串行加锁、查询上传店铺与目标版本。达标后仅执行调用方提供的 `SQL_QUERY`，并复查 ADS 版本记录；原三步 SQL 不在新文件中复制或改写。测试用 mock `mysql` 和 mock `flock` 运行 Shell，验证各分支与执行顺序。

**Tech Stack:** Bash、GNU date、flock、mysql CLI、ShellCheck（若环境提供）。

## Global Constraints

- `do_month` 复用原脚本上方的参数/日期计算口径；新 Shell 不另行计算月份。
- 上传店铺数固定为 `count(distinct plan_shop_code)`，空店铺编码不计入。
- 店铺数小于 10 时输出当前数量和店铺列表，并以退出码 0 结束。
- 已有 `jamf_ads.ads_dss_sales_plan_roll_msku_info.version_no = do_month` 时，不执行 SQL。
- 达标后执行调用方传入的原始 `SQL_QUERY`；SQL 成功后必须复查目标版本记录存在。
- 不调用任何 HTTP 接口。
- 所有 Shell 内嵌 SQL 使用单引号；SQL 文本中不使用 ASCII 双引号和 `#` 注释。

---

### Task 1: 编写可嵌入的月度门禁 Shell

**Files:**
- Create: `projects/sales-plan-roll/ads/ads_dss_sales_plan_roll_msku_info_monitor.sh`

**Interfaces:**
- Consumes: 已由调用方计算的环境变量 `do_month`、`SQL_QUERY`；`DORIS_HOST`、`DORIS_PORT`、`DORIS_USERNAME`、`DORIS_PASSWORD`、`DORIS_DW_DATABASE`。
- Produces: 退出码 `0`（跳过、等待或成功）或非 `0`（锁、查询、SQL、版本复查失败）；标准输出包含 `[sales-plan-roll]` 前缀的可审计日志。

- [ ] **Step 1: 创建脚本头与输入校验**

```bash
#!/bin/bash
set -o pipefail

readonly REQUIRED_SHOP_COUNT=10
readonly LOCK_FILE='/tmp/ads_dss_sales_plan_roll_msku_info.lock'

if [ -z "${do_month:-}" ]; then
    echo '[sales-plan-roll] do_month is required.' >&2
    exit 2
fi

if [ -z "${SQL_QUERY:-}" ]; then
    echo "[sales-plan-roll] SQL_QUERY is required for month=${do_month}." >&2
    exit 2
fi
```

- [ ] **Step 2: 实现非阻塞文件锁和 MySQL 查询封装**

```bash
exec 9>"${LOCK_FILE}"
if ! flock -n 9; then
    echo "[sales-plan-roll] another run is active; month=${do_month}." >&2
    exit 3
fi

run_doris_query() {
    mysql -N -B -h"${DORIS_HOST}" -P"${DORIS_PORT}" -u"${DORIS_USERNAME}" -p"${DORIS_PASSWORD}" "${DORIS_DW_DATABASE}" -e "$1"
}
```

- [ ] **Step 3: 实现版本幂等检查**

```bash
VERSION_EXISTS_SQL="select case when count(1) > 0 then 1 else 0 end
from jamf_ads.ads_dss_sales_plan_roll_msku_info
where version_no = '${do_month}';"
version_exists=$(run_doris_query "${VERSION_EXISTS_SQL}") || exit 4

if [ "${version_exists}" = '1' ]; then
    echo "[sales-plan-roll] skip: month=${do_month} already exists."
    exit 0
fi
```

- [ ] **Step 4: 实现十店铺检查与等待日志**

```bash
UPLOAD_SHOPS_SQL="select group_concat(plan_shop_code order by plan_shop_code separator ',')
from (
    select distinct plan_shop_code
    from jamf_dis.upload_dss_sales_plan_roll_info
    where upload_month = '${do_month}'
      and plan_shop_code is not null
      and plan_shop_code <> ''
) a;"
uploaded_shops=$(run_doris_query "${UPLOAD_SHOPS_SQL}") || exit 5
shop_count=0
[ -n "${uploaded_shops}" ] && shop_count=$(awk -F',' '{print NF}' <<< "${uploaded_shops}")

if [ "${shop_count}" -lt "${REQUIRED_SHOP_COUNT}" ]; then
    echo "[sales-plan-roll] waiting: month=${do_month}, uploaded_shop_count=${shop_count}, shops=${uploaded_shops:-<none>}."
    exit 0
fi
```

- [ ] **Step 5: 执行原 SQL 并复查落库版本**

```bash
echo "[sales-plan-roll] ready: month=${do_month}, uploaded_shop_count=${shop_count}."
if ! mysql -h"${DORIS_HOST}" -P"${DORIS_PORT}" -u"${DORIS_USERNAME}" -p"${DORIS_PASSWORD}" "${DORIS_DW_DATABASE}" -e "${SQL_QUERY}"; then
    echo "[sales-plan-roll] failed: SQL_QUERY failed for month=${do_month}." >&2
    exit 6
fi

version_exists=$(run_doris_query "${VERSION_EXISTS_SQL}") || exit 7
if [ "${version_exists}" != '1' ]; then
    echo "[sales-plan-roll] failed: month=${do_month} has no target version after SQL." >&2
    exit 8
fi
echo "[sales-plan-roll] completed: month=${do_month}."
```

- [ ] **Step 6: 检查语法**

Run: `bash -n projects/sales-plan-roll/ads/ads_dss_sales_plan_roll_msku_info_monitor.sh`

Expected: exit code 0 and no output.

### Task 2: 创建 mock 驱动的分支验证脚本

**Files:**
- Create: `projects/sales-plan-roll/tests/test_ads_dss_sales_plan_roll_msku_info_monitor.sh`
- Test: `projects/sales-plan-roll/ads/ads_dss_sales_plan_roll_msku_info_monitor.sh`

**Interfaces:**
- Consumes: 通过 `PATH` 覆盖的 mock `mysql` 与 `flock`，并以 `do_month` 和 `SQL_QUERY` 调用被测脚本。
- Produces: 验证已入库跳过、不足十家等待、达标执行且复查通过、SQL 后版本缺失失败四个场景的退出码和关键日志。

- [ ] **Step 1: 写入最小 mock mysql**

```bash
#!/bin/bash
case "$*" in
  *'ads_dss_sales_plan_roll_msku_info'*'version_no'*)
    version_call_file="${MOCK_STATE_DIR}/version_call_count"
    version_call_count=$(cat "${version_call_file}" 2>/dev/null || printf '0')
    version_call_count=$((version_call_count + 1))
    printf '%s' "${version_call_count}" > "${version_call_file}"
    printf '%s\n' "$(cut -d, -f"${version_call_count}" <<< "${MOCK_VERSION_RESULTS}")"
    ;;
  *'upload_dss_sales_plan_roll_info'*) printf '%s\n' "${MOCK_SHOPS}" ;;
  *'select 1 as original_sql'*) : ;;
  *) exit 91 ;;
esac
```

- [ ] **Step 2: 写入四个断言场景**

```bash
run_case() {
    local expected_code="$1" expected_text="$2"
    shift
    shift
    export MOCK_STATE_DIR
    rm -f "${MOCK_STATE_DIR}/version_call_count"
    set +e
    output=$(PATH="${mock_dir}:$PATH" do_month='2026-08' SQL_QUERY='select 1 as original_sql;' "$@" 2>&1)
    code=$?
    set -e
    [ "${code}" -eq "${expected_code}" ] || { printf '%s\n' "${output}"; return 1; }
    [[ "${output}" == *"${expected_text}"* ]]
}

MOCK_VERSION_RESULTS=1 MOCK_SHOPS='' run_case 0 'skip: month=2026-08 already exists' "${script_path}"
MOCK_VERSION_RESULTS=0 MOCK_SHOPS='S01,S02' run_case 0 'waiting: month=2026-08, uploaded_shop_count=2' "${script_path}"
MOCK_VERSION_RESULTS=0,1 MOCK_SHOPS='S01,S02,S03,S04,S05,S06,S07,S08,S09,S10' run_case 0 'completed: month=2026-08' "${script_path}"
```

- [ ] **Step 3: 为 SQL 后复查为空补充顺序型 mock**

```bash
MOCK_VERSION_RESULTS=0,0 MOCK_SHOPS='S01,S02,S03,S04,S05,S06,S07,S08,S09,S10' \
    run_case 8 'has no target version after SQL' "${script_path}"

printf '%s\n' '4 scenarios passed'
```

Run: `bash projects/sales-plan-roll/tests/test_ads_dss_sales_plan_roll_msku_info_monitor.sh`

Expected: exit code 0 and output containing `4 scenarios passed`.

### Task 3: 完成静态检查与嵌入说明

**Files:**
- Modify: `projects/sales-plan-roll/ads/ads_dss_sales_plan_roll_msku_info_monitor.sh`

**Interfaces:**
- Consumes: 原脚本完成日期计算后的 `do_month` 与完整 `SQL_QUERY`。
- Produces: 脚本顶部注释，精确说明调用方式和嵌入点。

- [ ] **Step 1: 增加嵌入示例注释**

```bash
# 将本文件中从 REQUIRED_SHOP_COUNT 到 completed 日志的代码块，
# 放在原脚本已完成 do_month 计算、已定义 SQL_QUERY 的位置；
# 原脚本无需传入或导出新的日期参数。
```

- [ ] **Step 2: 运行 Bash 语法与测试验证**

Run: `bash -n projects/sales-plan-roll/ads/ads_dss_sales_plan_roll_msku_info_monitor.sh && bash projects/sales-plan-roll/tests/test_ads_dss_sales_plan_roll_msku_info_monitor.sh`

Expected: exit code 0 and output containing `4 scenarios passed`.

- [ ] **Step 3: 可选执行 ShellCheck**

Run: `shellcheck projects/sales-plan-roll/ads/ads_dss_sales_plan_roll_msku_info_monitor.sh`

Expected: exit code 0. If `shellcheck` is not installed, record that Bash syntax check and mocked behavior tests passed instead.
