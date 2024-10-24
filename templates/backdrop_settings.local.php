<?php
/*
 * PENDIENTE:
 *
 * Encontrar cómo generar aleatoriamente las dos cadenas que acá se
 * presentan "en duro"
 */

$database = 'mysql://{{ backdrop_db_user }}:{{ lookup("file", "mysql_usr_pass") }}@{{ backdrop_db_host }}/{{ backdrop_db }}';
$database_charset = 'utf8mb4';
$settings['hash_salt'] = 'JEQ99iNwdfE5O60ueeOZLnCn_AKvlRkTbzZUCIifmtU';
// $config_directories['active'] = './files/config_f0a4c571bfc6dcfdde30f3400c8b5b21/active';
// $config_directories['staging'] = './files/config_f0a4c571bfc6dcfdde30f3400c8b5b21/staging';
