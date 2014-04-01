#!/bin/bash

source /var/system-alerts/instance-list

SEND_EMAIL=1

# to="akash.akkis@gmail.com"
to="akash.akkis@gmail.com"
# to=akash.aakis@gmail.com

function wrap_cpu {
  if [ "$2" != "DB Report Master" ] && [ "$2" != "DB Report Slave" ] ; then
  numcpu=$(ssh root@$1 "cat /proc/cpuinfo | grep processor | wc -l")
  load=$(ssh root@$1 "uptime | rev | cut -d\" \" -f1 | rev")
  percent=$(echo "scale=1; $load * 100 / $numcpu" | bc -l)
  echo $2 $numcpu $load $percent
  tmp=$(echo "$percent > 80" | bc)
  if [ "$tmp" == 1 ]; then
    mesg=$(echo "to=$to&subject=Alert: Load Average High on $2 ($1) - $percent%&body=<pre>#CPU: $numcpu<br>Load: $load")
    if [ $SEND_EMAIL == 1 ]; then
      curl --data "$mesg" https://example.com/email/send
    else
      echo $mesg
    fi
  fi
  fi
}

function wrap_mem {
  total=$(ssh root@$1 "free -m | grep \"Mem:\" | sed \"s/  */ /g\" | cut -d\" \" -f2")
  mem=$(ssh root@$1 "free -m | grep \"buffers/cache\" | sed \"s/  */ /g\" | cut -d\" \" -f3")
  percent=$(echo "scale=1; $mem * 100 / $total" | bc -l)
  echo $2 $total $mem $percent
  tmp=$(echo "$percent > 85" | bc)
  if [ "$tmp" == 1 ]; then
    mesg=$(echo "to=$to&subject=Alert: Memory Utilization High on $2 ($1) - $percent%&body=<pre>Total: $total<br>Used:  $mem")
    if [ $SEND_EMAIL == 1 ]; then
      curl --data "$mesg" https://example.com/email/send
    else
      echo $mesg
    fi
  fi
}

for (( i=0; i<=$(( ${#IP[*]} -1 )); i++ ))
do
  wrap_cpu "${IP[$i]}" "${SERVER[$i]}"
  wrap_mem "${IP[$i]}" "${SERVER[$i]}"
done
