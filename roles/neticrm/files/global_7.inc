<?php
# This file will included at the end of settings.php

global $conf, $base_url;

# HTTP only
ini_set("session.cookie_httponly", 1);

# Limit to 5 login attempts from one IP address per 30 minutes
$conf['user_failed_login_ip_limit'] = 5;
$conf['user_failed_login_ip_window'] = 1800;

# we can only reset error_reporting here (after bootstrap env done)
ini_set('error_reporting', E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED);

# for docker, sometime we will fail with http request
$conf['drupal_http_request_fails'] = FALSE;

# support cloudflare ssl
if (isset($_SERVER['HTTP_CF_VISITOR'])) {
  if (preg_match('/https/i', $_SERVER['HTTP_CF_VISITOR'])) {
    $_SERVER['HTTPS'] = 'On';
    $_SERVER['HTTP_X_FORWARDED_PORT'] = 443;
    $_SERVER['SERVER_PORT'] = 443;
  }
}

# memcache support
/*
if(file_exists("profiles/neticrmp/modules/memcache/memcache.inc")){
  $prefix = 'drupal_'.sprintf("%u", crc32('http://'.$_SERVER['HTTP_HOST']));
  $conf['memcache_key_prefix'] = $prefix;
  $conf['cache_backends'][] = 'profiles/neticrmp/modules/memcache/memcache.inc';
  $conf['lock_inc'] = 'profiles/neticrmp/modules/memcache/memcache-lock.inc';
  $conf['memcache_stampede_protection'] = TRUE;
  $conf['cache_default_class'] = 'MemCacheDrupal';

  // The 'cache_form' bin must be assigned to non-volatile storage.
  $conf['cache_class_cache_form'] = 'DrupalDatabaseCache';

  // refs #16161, https://www.drupal.org/node/1679344
  $conf['cache_class_cache_field'] = 'DrupalDatabaseCache';

  // Don't bootstrap the database when serving pages from the cache.
  $conf['page_cache_without_database'] = TRUE;
  $conf['page_cache_invoke_hooks'] = FALSE;
  $conf['memcache_servers'] = array('dockerhost:11211' => 'default');
}
*/
