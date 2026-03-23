#!/bin/bash
set -euo pipefail

BASE="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
ENV_FILE="$BASE/scripts/phase3_batch2_executor_env.sh"

if [ ! -f "$ENV_FILE" ]; then
  echo "MISSING_ENV_FILE=$ENV_FILE"
  exit 1
fi

source "$ENV_FILE"

FAIL=0

for key in \
  EP_BENCH_BASELINE_EXEC_CMD \
  EP_BENCH_SCAFFOLD_EXEC_CMD \
  EP_BENCH_EP_EXEC_CMD \
  EP_BENCH_BASELINE_INNER_CMD \
  EP_BENCH_SCAFFOLD_INNER_CMD \
  EP_BENCH_EP_INNER_CMD
do
  value="${!key:-}"
  if [ -z "$value" ]; then
    echo "MISSING_OR_EMPTY=$key"
    FAIL=1
  else
    echo "OK=$key"
  fi
done

if [ $FAIL -ne 0 ]; then
  exit 2
fi

echo "VALIDATION_OK"
