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
function cronr {
  CRONRUN=`/etc/init.d/cron status | grep "Active" | grep "failed"`
  if [ -n "$CRONRUN" ]; then
    echo "CRON daemon: $CRONRUN"
  fi
}

function smtpr {
  SMTPRUN=`nc -zv 127.0.0.1 25 2>&1 | grep refused`
  if [ -n "$SMTPRUN" ]; then
    SMTPDOCKER=`docker ps -a --format "{{.Names}}\t{{.Status}} (Created:{{.CreatedAt}})" | grep dovecot`
    echo "SMTP: $SMTPDOCKER"
  fi
}
function imapr {
  SMTPRUN=`nc -zv 127.0.0.1 993 2>&1 | grep refused`
  if [ -n "$SMTPRUN" ]; then
    SMTPDOCKER=`docker ps -a --format "{{.Names}}\t{{.Status}} (Created:{{.CreatedAt}})" | grep dovecot`
    echo "IMAP: $SMTPDOCKER"
  fi
}

MEMP=$(memp)
DISKP=$(diskp)
CPUP=$(cpup)
CRONR=$(cronr)
SMTPR=$(smtpr)
IMAPR=$(imapr)

NOTIFY="live"
if [ $MEMP -gt "90" ] || [ $DISKP -gt "95" ] || [ $CPUP -gt "166" ] || [ -n "$SMTPR" ] || [ -n "$IMAPR" ] || [ -n "$CRONR" ]; then
  NOTIFY=`echo $MEMP $DISKP $CPUP | awk '{printf "M:%d%% D:%d%% C:%d%%", $1, $2, $3}'`
  NOTIFY="${NOTIFY}\n${CRONR}\n${SMTPR}\n{$IMAPR}"
fi
echo -e $NOTIFY > $LIVE
echo $MEMP $DISKP $CPUP | awk '{printf "M:%d%% D:%d%% C:%d%%\n", $1, $2, $3}'
SMTPDOCKER=$(docker ps -a --format "{{.Names}} {{.Status}} (Created:{{.CreatedAt}})" | grep dovecot)
echo "SMTP: $SMTPDOCKER"
