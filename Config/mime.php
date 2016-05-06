<?php
    $config = array();
    
    $config['Mime.image'] = array(
        'types' => array('image/jpeg','image/png'),
        'invalid' => 'Solo se permiten archivos PNG y JPG'    
    );
    
    $config['Mime.pdf'] = array(
        'types' => array('application/pdf','application/x-pdf'),
        'invalid' => 'Solo se permiten archivos PDF'    
    );

?>
