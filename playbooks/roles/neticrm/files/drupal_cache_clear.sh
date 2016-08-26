# !/bin/bash

TYPE=$1
if [ -z "$TYPE" ]; then
  TYPE="all"
fi
for RUN in `find /var/www/sites/*/sites/*/settings.php` ; do
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
    docker exec -i $NAME bash -c "drush -l $SITE cache-clear $1 --yes"
  fi
done
