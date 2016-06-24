# !/bin/bash

for RUN in `find /var/www/sites/*/sites/*/civicrm.settings.php` ; do
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
    docker exec -i $NAME bash -c "drush -l $SITE updb --yes &> /var/www/html/log/neticrm_update.log"
  fi
done
