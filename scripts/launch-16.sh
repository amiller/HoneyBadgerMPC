#!/bin/bash

# This script runs an MPC program in 4 processes.
# Usage: sh scripts/launch.sh honeybadgermpc/ipc.py conf/mpc/local

if [ $# -lt 2 ] ; then
    echo '>> Invalid number of args passed.'
    exit 1
fi

if [ -z "$1" ]
  then
    echo "MPC file to run not specified."
fi

if [ -z "$2" ]
  then
    echo "MPC config file prefix not specified."
fi

# Change dir/file.py to dir.file
FILE_PATH=$1
DIRS=(${FILE_PATH//\// })
DOT_SEPARATED_PATH=$(IFS=. ; echo "${DIRS[*]}")
MODULE_PATH=${DOT_SEPARATED_PATH::-3}

CONFIG_PATH=$2

CMD="python -m ${MODULE_PATH}"
echo ">>> Command to be executed: '${CMD}'"

bash scripts/shaper.sh stop
# bash scripts/shaper.sh start

for ID in $(seq 4 49)
do
    echo
    ${CMD} -d -f ${CONFIG_PATH}.${ID}.json > logs-${ID}.log 2>&1 &
done

if [ -z "$3" ]
  then
    set -x
    rm -rf sharedata/
    tmux new-session     "${CMD} -d -f ${CONFIG_PATH}.0.json; sh" \; \
        splitw -h -p 50 "${CMD} -d -f ${CONFIG_PATH}.1.json; sh" \; \
        splitw -v -p 50 "${CMD} -d -f ${CONFIG_PATH}.2.json; sh" \; \
        selectp -t 0 \; \
        splitw -v -p 50 "${CMD} -d -f ${CONFIG_PATH}.3.json; sh"

elif [ "$3" == "dealer" ]
  then
    set -x
    rm -rf sharedata/
    tmux new-session     "${CMD} -d -f ${CONFIG_PATH}.0.json; sh" \; \
        splitw -h -p 50 "${CMD} -d -f ${CONFIG_PATH}.1.json; sh" \; \
        splitw -v -p 50 "sleep 2; ${CMD} -d -f ${CONFIG_PATH}.2.json; sh" \; \
        selectp -t 0 \; \
        splitw -v -p 50 "sleep 4; ${CMD} -d -f ${CONFIG_PATH}.3.json; sh" \; \
        splitw -v -p 50 "${CMD} -d -f ${CONFIG_PATH}.50.json; sh"
fi

