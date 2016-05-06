<?php

$config = [];
$config['Login.url'] = [ 'controller' => 'pages','action' => 'login'];
$config['Logout.url'] = [ 'controller' => 'pages','action' => 'logout'];
$config['Login.loginField'] = 'user_name';
$config['Login.passwordField'] = 'password';
$config['Login.maxAttempts'] = 3;
$config['Login.banTime'] = 3600;
$config['Login.lastLoginField'] = 'last_login';
$config['Login.lastLoginIpField'] = 'last_login_ip';
$config['Login.lastLoginAttempField'] = 'last_login_attempt';
$config['Login.loginAttemptsField'] = 'login_attempts';
$config['Login.crypto'] = 'md5';
$config['Login.salt'] = 'HD#D@)@D@D(@D@HD@DJ@F#B#F#)';
