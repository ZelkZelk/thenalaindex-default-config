<?php

$config = [];

/* 
 * Configura el Componente React, se especifica el path completo a los
 * javascripts que incluyen la libreria.
 */

$config['react_js_path'] = 'http://backend.nala/react/node_modules/react/dist/react.js';
$config['react_dom_js_path'] = 'http://backend.nala/react/node_modules/react-dom/dist/react-dom.js';
$config['babel_js_path'] = 'https://cdnjs.cloudflare.com/ajax/libs/babel-core/5.8.23/browser.min.js';

/* React para el modulo de Notificaciones*/

$config['react']['notifications']['email'] = 'http://backend.nala/react/notifications/email.js';