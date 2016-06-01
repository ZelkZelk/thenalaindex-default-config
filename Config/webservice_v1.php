<?php

$config = [];
$config['Webservice.targets'] = [ 
    'get' => true, 
    'post' => false 
];

$config['Webservice.histories'] = [
    'get' => true, 
    'post' => true, 
    'data' => [ 
        'target_id' => [ 'required' => true, 'type' => 'int'  ], 
        'page' => [ 'default' => 1, 'type' => 'int' ], 
        'limit' => [ 'default' => 5, 'type' => 'int', 'readonly' => true ]
    ],
];
