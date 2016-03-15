#!/bin/bash

for RUN in `find /var/www/sites/*/sites/*/settings.php -printf "%C@ %p\n" | sort | awk '{ print $2 }'` ; do
  NAME=${RUN//\/var\/www\/sites\//}
  NAME=${NAME%%/*}
  TMP=${RUN%/*}
  TMP=${TMP##*/}
  SITE=""
  if [ "$TMP" != "default" ]; then
    SITE=$TMP
  else
    SITE=$NAME
  fi
  RUNNING=$(docker ps -q -f name=$NAME)
  if [ -n "$RUNNING" ]; then
    docker exec -d $RUNNING php /var/www/html/sites/default/finddb.inc
  fi
done
