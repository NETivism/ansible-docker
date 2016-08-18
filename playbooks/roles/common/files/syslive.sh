#!/bin/bash
LIVE="/var/www/sites-unavailable/live/live.htm"
function memp {
  MEMTOTAL=`cat /proc/meminfo | grep 'MemTotal' | awk '{ print $2 }'`
  MEMAVAILABLE=`cat /proc/meminfo | grep 'MemAvailable' | awk '{ print $2 }'`
  MEMUSED=`echo "$MEMTOTAL - $MEMAVAILABLE" | bc`
  MEMUSED=`echo "$MEMUSED $MEMTOTAL" | awk '{printf "%d", $1*100/$2}'`
  echo $MEMUSED
}
function diskp {
  DISKP=`df -h | awk '$NF=="/"{printf "%s", $5}'`
  echo "$DISKP" | awk '{print substr($1, 1, length($1)-1)}'
}
function cpup {
  CPUPROCESSOR=`cat /proc/cpuinfo | grep processor | wc -l`
  CPUPROCESSOR=`echo "$CPUPROCESSOR*100" | bc`
  CPULOAD=`top -bn1 | grep "load average" | awk '{printf "%.2f\n", $(NF-1)}'`
  CPULOAD=`echo "$CPULOAD*100" | bc`
  echo "$CPULOAD $CPUPROCESSOR" | awk '{printf "%d", $1*100/$2}'
}

MEMP=$(memp)
DISKP=$(diskp)
CPUP=$(cpup)

NOTIFY="live"
if [ $MEMP -gt "90" ] || [ $DISKP -gt "95" ] || [ $CPUP -gt "90" ]; then
  NOTIFY=`echo $MEMP $DISKP $CPUP | awk '{printf "M:%d%% D:%d%% C:%d%%", $1, $2, $3}'`
fi
echo $NOTIFY > $LIVE
echo $MEMP $DISKP $CPUP | awk '{printf "M:%d%% D:%d%% C:%d%%\n", $1, $2, $3}'
