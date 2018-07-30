#!/bin/bash
if [ -z "$1" ]; then
  echo "  Usage: "
  echo "    $0 mysql parameter"
  echo "  If sites not docker container, export these variable first"
  echo "    export NO_DOCKER=1"
  echo "    export WWW_ROOT=/var/aegir/platforms (no trailing slash)"
  exit 1
fi

if [ -n "$1" ]; then
  MYSQLPARAM="$1"
fi

NO_DOCKER=$NO_DOCKER
WWW_ROOT=$WWW_ROOT
if [ -z "$WWW_ROOT" ]; then
  if [ -d "/var/www/sites" ]; then
    WWW_ROOT="/var/www/sites";
  else
    echo "You must export WWW_ROOT to correct directory first."
    exit 1
  fi
fi

for RUN in `find $WWW_ROOT/*/sites/*/settings.php` ; do
  NAME=${RUN//$WWW_ROOT\//}
  NAME=${NAME%%/*}
  DIR=$(dirname "$RUN")
  TMP=${RUN%/*}
  TMP=${TMP##*/}
  SITE=""
  if [ "$TMP" != "default" ]; then
    SITE=$TMP
  else
    SITE=$NAME
  fi

  RESULT=""
  if [ -n "$NO_DOCKER" ]; then
    cd $DIR
    RESULT=$(drush -l $SITE pm-list --type=module --status=$STATUS --no-core --pipe | grep $MYSQLPARAM)
  else
    RUNNING=$(docker ps -q -f name=$SITE)
    if [ -n "$RUNNING" ]; then
      RESULT=$(docker exec $SITE bash -c "drush -l $SITE sqlq \"SHOW VARIABLES LIKE 'innodb_file_format'\"")
    else
      echo "!$SITE no container running"
    fi
  fi
  if [ -n "$RESULT" ]; then
    echo "$SITE $RESULT"
  fi
done
