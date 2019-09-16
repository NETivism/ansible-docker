#!/bin/bash
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

  # skip symbolic link
  if [ -L $TMP ]; then
    continue
  fi

  SITE=""
  if [ "$TMP" != "default" ]; then
    SITE=$TMP
  else
    SITE=$NAME
  fi

  RUNNING=$(docker ps -q -f name=$SITE)
  if [ -n "$RUNNING" ]; then
    echo "Checking drush neticrms for $SITE ..."
    LINE=$(/usr/bin/docker exec -i $RUNNING bash -c "drush -l $SITE neticrms 2>&1" | grep run_civimail | wc -l)
    if [ -z "$LINE" ]; then
      echo "neticrms NOT found. clear drush ..."
      $(/usr/bin/docker exec -i $RUNNING bash -c "drush -l $SITE cc drush")
    else
      echo "neticrms found, go to next site."
    fi
  fi
done
