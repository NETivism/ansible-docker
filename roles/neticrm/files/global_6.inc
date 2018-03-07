<?php
# This file will included at the end of settings.php

global $conf, $base_url;

# HTTP only
ini_set("session.cookie_httponly", 1);

# https://www.drupal.org/node/2476237
ini_set('arg_separator.output',     '&');

# we can only reset error_reporting here (after bootstrap env done)
ini_set('error_reporting', E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED);

# memcache support
/*
if(file_exists("profiles/neticrmp/modules/memcache/memcache.inc")){
  $prefix = 'd'.sprintf("%u", crc32($base_url));
  $conf['cache_inc'] = 'profiles/neticrmp/modules/memcache/memcache.inc';
  $conf['memcache_servers'] = array(
    'dockerhost:11211' => 'default',
  );
  $conf['memcache_bins'] = array(
    'cache_form' => 'database',
  );
}
*/
