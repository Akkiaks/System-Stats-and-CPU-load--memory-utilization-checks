#!/bin/bash

source /var/system-alerts/instance-list

DAY=$(date +"%Y-%m-%d")
DIR=/mnt/tmp
OUTCPU=DailyCPU.$DAY
OUTMEM=DailyMEM.$DAY

cd $DIR

function wrap_cpu {
  time=$(date "+%H:%M")
  load=$(ssh root@$1 "uptime | rev | cut -d\" \" -f1 | rev")
  line=$(echo -n "$time " ; echo $load)
  echo $line >> $OUTCPU@$1
}

function wrap_mem {
  time=$(date "+%H:%M")
  total=$(ssh root@$1 "free -m | grep \"Mem:\" | sed \"s/  */ /g\" | cut -d\" \" -f2")
  mem=$(ssh root@$1 "free -m | grep \"buffers/cache\" | sed \"s/  */ /g\" | cut -d\" \" -f3,4")
  line=$(echo -n "$time " ; echo -n "$total " ; echo $mem)
  echo $line >> $OUTMEM@$1
}

for s in "${IP[@]}"
do
 wrap_cpu $s
 wrap_mem $s
done
