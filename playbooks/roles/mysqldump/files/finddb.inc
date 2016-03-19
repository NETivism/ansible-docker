<?php
/**
 * Fetch DB info from settings.php.
 *
 * @author	Fuyuan Cheng 
 */
$success = include_once(__DIR__.'/settings.php');
if ($success) {
  if ($databases) {
    $db = $databases['default']['default'];
    $database = $db['database'];
    $username = $db['username'];
    $password = $db['password'];
  } elseif ($db_url) {
    $db = parse_url($db_url);
    $database = substr(urldecode($db['path']) ,1);
    $username = urldecode($db['user']);
    $password = urldecode($db['pass']);
  }
} else {
  echo "Could not find settings.php file.";
}

// dump db by using mysqldump command.
$filename = "backup-" . date("d-m-Y") . ".sql.gz";
$cmd = "mysqldump -u $username -p$password $database | gzip -9 -c > /var/www/html/log/$filename";
exec($cmd);
