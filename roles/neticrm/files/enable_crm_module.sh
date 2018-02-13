#!/bin/bash
if [ -z "$1" ]; then
  echo "  Usage: "
  echo "    $0 module_name"
  exit 1
fi

if [ -n "$1" ]; then
  MODULE="$1"
fi

WWW_ROOT=$WWW_ROOT
if [ -z "$WWW_ROOT" ]; then
  if [ -d "/var/www/sites" ]; then
    WWW_ROOT="/var/www/sites";
  else
    echo "You must export WWW_ROOT to correct directory first."
    exit 1
  fi
fi

for RUN in `find $WWW_ROOT/*/sites/*/civicrm.settings.php` ; do
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
  RUNNING=$(docker ps -q -f name=$SITE)
  if [ -n "$RUNNING" ]; then
    echo "enabling $MODULE for $SITE ..."
    ENABLED=$(/usr/bin/docker exec -i $RUNNING bash -c "drush -l $SITE pm-enable $MODULE --yes")
    echo "done!"
    echo ""
  fi
done
