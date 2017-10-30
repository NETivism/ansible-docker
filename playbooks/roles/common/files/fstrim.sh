#!/bin/sh
/usr/bin/docker ps -qa | xargs /usr/bin/docker inspect --format='{{ .State.Pid }}' | xargs -IZ /sbin/fstrim /proc/Z/root/
