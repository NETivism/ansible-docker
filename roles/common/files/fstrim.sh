#!/bin/sh
PIDS=`/usr/bin/docker ps -qa | xargs /usr/bin/docker inspect --format='{{ .State.Pid }}'`

for PID in $(echo $PIDS); do
  if [ "$PID" -ne "0" ]; then
    /sbin/fstrim /proc/$PID/root/
  fi
done
