<?php

/* Clase que implementa un mecanismo basico de SharedMemory con MemCached. */

$config = [];
$config['SharedMemory.host'] = '127.0.0.1';
$config['SharedMemory.port'] = '11211';

if( ! class_exists('SharedMemory')){
    class SharedMemory{
        private static $memcached;
        public static $register = [];
        
        /* Elimina los bloques de memoria compartida, solo aquellos bloques que
         * coincidan el password son eliminados, esto asegura que solo la memoria
         * escrita por el proceso actual limpie su basura. */

        public static function flushBlocks(){           
            foreach(self::$register as $key => $password){
                $cachePassword = SharedMemory::password($key);      

                if( ! is_null($password)){
                    if($cachePassword ==  $password){
                        SharedMemory::delete($key);
                    }
                }
            }
        }
        
        /* Registra un bloque de memoria compartida. */

        public static function registerBlock($key,$password){
            self::$register[$key] = $password;
        }
        
        /* Inicia el wrapper de memcache */

        public static function start($host,$port){
            self::$memcached = new Memcached();
            self::$memcached->addServer($host,$port);
        }
        
        /* Realiza una escritura en el servidor memcache */

        public static function write($key,$value,$password=null,$exp=0){
            $superblock = [ 'value' => $value, 'password' => $password];

            if(self::$memcached->set($key,$superblock,$exp)){
                self::registerBlock($key, $password);
                return true;
            }

            return false;
        }
        
        /* Obtiene el password del bloque especificado. */

        public static function password($key){
            $superblock = self::$memcached->get($key);

            if(isset($superblock['password'])){
                return $superblock['password'];
            }

            return null;
        }
        
        
        /* Realiza una lectura del servidor de memoria compartida */

        public static function read($key){
            $superblock = self::$memcached->get($key);

            if(isset($superblock['value'])){
                return $superblock['value'];
            }

            return null;
        }
        
        /* Elimina una entrada del servidor de memoria compartida */

        public static function delete($key){
            return self::$memcached->delete($key);
        }
    }
    
    /* Registramos un callback para limpiar la memoria compartida al terminar el
     * script.. */
    
    register_shutdown_function(array('SharedMemory','flushBlocks'));
}

