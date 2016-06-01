<?php

$config = [];
$config['Frontend.api.index'] = '/v1/targets.json';
$config['Frontend.url.index'] = '/';

$config['Frontend.api.histories'] = '/v1/histories.json';
$config['Frontend.url.histories'] = '/historico/%id%/%target%.html';
$config['Frontend.querystring.histories'] = [
    'target_id' => 'id'
];