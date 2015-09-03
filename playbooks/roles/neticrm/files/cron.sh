# !/bin/bash

docker_cron_run(){
  docker exec -i $1 bash -c "cd /var/www/html && drush cron --quiet"
}

docker_cron_run_neticrm(){
  docker exec -i $1 bash -c "cd /var/www/html && drush neticrms run_civimail"
  docker exec -i $1 bash -c "cd /var/www/html && drush neticrms run_civimail_process"
  docker exec -i $1 bash -c "cd /var/www/html && drush neticrms run_contact_greeting_update"
  docker exec -i $1 bash -c "cd /var/www/html && drush neticrms run_participant_processor"
  docker exec -i $1 bash -c "cd /var/www/html && drush neticrms run_membership_status_update"
}

# make sure we have 
COUNT=0
LIMIT_NUM=3
LIMIT_MIN=30

# find /var/www/sites/*/cron.php -mmin +10 -printf "%C@ %p\n" | sort | awk '{ print $2 }'
for DIR in `find /var/www/sites/*/cron.php -mmin +$LIMIT_MIN -printf "%C@ %p\n" | sort | awk '{ print $2 }'` ; do
  BASE=${DIR%/cron.php}
  NAME=${BASE//\/var\/www\/sites\//}
  RUNNING=$(docker ps -q -f name=$NAME)
  if [ -n "$RUNNING" ]; then
    if [ $COUNT -gt $LIMIT_NUM ]; then
      echo $COUNT
      echo "Excceed $LIMIT_NUM of sites in each cron"
      break
    fi
    docker_cron_run $NAME
    if [ -f $BASE/sites/all/modules/civicrm/civicrm-version.txt ]; then
      docker_cron_run_neticrm $NAME
    fi
    COUNT=$(($COUNT+1))
  fi
done
