#!/bin/bash
if [ -z "$1" ]; then
  echo "  Usage: "
  echo "    $0 module_name status"
  echo "  If sites not docker container, export these variable first"
  echo "    export NO_DOCKER=1"
  echo "    export WWW_ROOT=/var/aegir/platforms (no trailing slash)"
  exit 1
fi

if [ -n "$1" ]; then
  MODULE="$1"
fi

if [ -n "$2" ]; then
  STATUS="$2"
else
  STATUS="enabled"
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
    RESULT=$(drush -l $SITE pm-list --type=module --status=$STATUS --no-core --pipe | grep $MODULE)
  else
    RUNNING=$(docker ps -q -f name=$SITE)
    if [ -n "$RUNNING" ]; then
      RESULT=$(docker exec -i $SITE bash -c "drush -l $SITE pm-list --type=module --status=$STATUS --no-core --pipe | grep $MODULE")
    fi
  fi
  if [ -n "$RESULT" ]; then
    echo "$SITE $DIR $MODULE $STATUS"
  fi
done
