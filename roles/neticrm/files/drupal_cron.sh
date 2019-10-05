# !/bin/bash

docker_cron_run(){
  docker exec -i $1 bash -c "cd /var/www/html && drush -l $2 cron --quiet"
}

docker_cron_run_neticrm(){
  docker exec -i $1 bash -c "cd /var/www/html && drush -l $2 neticrms run_civimail"
  docker exec -i $1 bash -c "cd /var/www/html && drush -l $2 neticrms run_civimail_process"
  docker exec -i $1 bash -c "cd /var/www/html && drush -l $2 neticrms run_contact_greeting_update"
  docker exec -i $1 bash -c "cd /var/www/html && drush -l $2 neticrms run_participant_processor"
  docker exec -i $1 bash -c "cd /var/www/html && drush -l $2 neticrms run_membership_status_update"
  # prevent upload dir being root
  docker exec -i $1 bash -c "ls -ld /tmp/$1 | grep -v 'www-data www-data' | awk '{ print \$NF }' | xargs chown -R www-data:www-data"
}

# make sure we have
COUNT=0

# make sure we can run at least 40 sites per 30 mins
LIMIT_NUM=15
LIMIT_MIN=25

for RUN in `find /var/www/sites/*/sites/*/settings.php -mmin +$LIMIT_MIN -printf "%C@ %p\n" | sort | awk '{ print $2 }'` ; do
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
    echo "$(date +"%Y-%m-%d %H:%M:%S") $NAME cron run" >> /var/log/drupal_cron.log
    touch $RUN
    docker_cron_run $NAME $SITE
    CRMSETTING=${RUN/settings.php/civicrm.settings.php}
    if [ -f $CRMSETTING ]; then
      echo "$(date +"%Y-%m-%d %H:%M:%S") $NAME civicrm cron run" >> /var/log/drupal_cron.log
      docker_cron_run_neticrm $NAME $SITE
    fi
    COUNT=$(($COUNT+1))
  fi
done
