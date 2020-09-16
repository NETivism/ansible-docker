# !/bin/bash
# make sure we have counter on this
COUNT=0

# make sure we can run 5 sites per 5 mins
LIMIT_NUM=5
LIMIT_MIN=4

for RUN in `find /var/www/sites/*/sites/*/civicrm.settings.php -mmin +$LIMIT_MIN -printf "%C@ %p\n" | sort | awk '{ print $2 }'` ; do
  NAME=${RUN//\/var\/www\/sites\//}
  NAME=${NAME%%/*}
  CONFPATH=${RUN%/*}

  # exclude symbolic link directory
  if [ -L $CONFPATH ]; then
    continue
  fi
  TMP=${CONFPATH##*/}
  SITE=""
  if [ "$TMP" != "default" ]; then
    SITE=$TMP
  else
    SITE=$NAME
  fi
  RUNNING=$(docker ps -q -f name=$NAME)
  if [ -n "$RUNNING" ]; then
    if [ $COUNT -gt $LIMIT_NUM ]; then
      echo $COUNT
      echo "Excceed $LIMIT_NUM of sites in each cron"
      break
    fi
    touch $RUN
    sleep $(( ( RANDOM % 3 )  + 1 ))

    BATCH_RUN_OUTPUT=$(docker exec -i $NAME bash -c "cd /var/www/html && drush -l $SITE neticrm-batch-run" 2>&1)
    if [[ $BATCH_RUN_OUTPUT = *"[ok]"* ]]; then
      echo "$(date +"%Y-%m-%d %H:%M:%S") $NAME neticrm cron run" >> /var/log/neticrm_cron.log
      COUNT=$(($COUNT+1))
    fi
    echo $COUNT
  fi
done
