#!/bin/bash
# Put this block into the original monthly script only after do_month has been
# calculated and SQL_QUERY has been fully defined. It reuses the caller's Doris
# connection variables and must not replace or modify the original external script.

set -o pipefail

readonly REQUIRED_SHOP_COUNT=10
readonly LOCK_FILE='/tmp/ads_dss_sales_plan_roll_msku_info.lock'

log_info() {
    printf '[sales-plan-roll] %s\n' "$1"
}

log_error() {
    printf '[sales-plan-roll] %s\n' "$1" >&2
}

run_doris_query() {
    mysql -N -B \
        -h"${DORIS_HOST}" \
        -P"${DORIS_PORT}" \
        -u"${DORIS_USERNAME}" \
        -p"${DORIS_PASSWORD}" \
        "${DORIS_DW_DATABASE}" \
        -e "$1"
}

if [ -z "${do_month:-}" ]; then
    log_error 'failed: do_month is required.'
    exit 2
fi

if [ -z "${SQL_QUERY:-}" ]; then
    log_error "failed: SQL_QUERY is required for month=${do_month}."
    exit 2
fi

exec 9>"${LOCK_FILE}" || {
    log_error "failed: cannot open lock file ${LOCK_FILE} for month=${do_month}."
    exit 3
}

if ! flock -n 9; then
    log_error "failed: another run is active for month=${do_month}."
    exit 3
fi

VERSION_EXISTS_SQL="
select case when count(1) > 0 then 1 else 0 end
from jamf_ads.ads_dss_sales_plan_roll_msku_info
where version_no = '${do_month}';
"

version_exists=$(run_doris_query "${VERSION_EXISTS_SQL}") || {
    log_error "failed: target-version precheck query failed for month=${do_month}."
    exit 4
}

if [ "${version_exists}" = '1' ]; then
    log_info "skip: month=${do_month} already exists in jamf_ads.ads_dss_sales_plan_roll_msku_info."
    exit 0
fi

UPLOAD_SHOPS_SQL="
select group_concat(plan_shop_code order by plan_shop_code separator ',')
from (
    select distinct plan_shop_code
    from jamf_dis.upload_dss_sales_plan_roll_info
    where upload_month = '${do_month}'
      and plan_shop_code is not null
      and plan_shop_code <> ''
) a;
"

uploaded_shops=$(run_doris_query "${UPLOAD_SHOPS_SQL}") || {
    log_error "failed: upload-shop query failed for month=${do_month}."
    exit 5
}

shop_count=0
if [ -n "${uploaded_shops}" ]; then
    shop_count=$(printf '%s\n' "${uploaded_shops}" | awk -F',' '{print NF}')
fi

if [ "${shop_count}" -lt "${REQUIRED_SHOP_COUNT}" ]; then
    log_info "waiting: month=${do_month}, uploaded_shop_count=${shop_count}, shops=${uploaded_shops:-<none>}."
    exit 0
fi

log_info "ready: month=${do_month}, uploaded_shop_count=${shop_count}, shops=${uploaded_shops}."

if ! run_doris_query "${SQL_QUERY}"; then
    log_error "failed: SQL_QUERY execution failed for month=${do_month}."
    exit 6
fi

version_exists=$(run_doris_query "${VERSION_EXISTS_SQL}") || {
    log_error "failed: target-version postcheck query failed for month=${do_month}."
    exit 7
}

if [ "${version_exists}" != '1' ]; then
    log_error "failed: month=${do_month} still has no target version after SQL_QUERY."
    exit 8
fi

log_info "completed: month=${do_month}."
