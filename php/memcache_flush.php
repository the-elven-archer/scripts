#!/usr/bin/php
<?php
// Script de flusheo de memcaches
// Consultas: santiago.buczak@vostu.com
if (empty($argv[1])) {
        echo "Falta listado de Servers\n";
        usage();
        return 1;
        exit;
}
////////////////////////////////////////////////////////////////////////////////////
// Funciones

//usage
//Muestra como usar el script si el usuario metio la pata en los parametros
function usage() {
        echo "Cache Cleaner - Script para flusheo de Memcaches\n";
        echo "Usage:\n";
        echo "memcache_flush.php <ARCHIVO_LISTA_SERVERS>";
}

//getServers
//Lee el archivo de servidores y devuelve un array con cada una de las lineas
function getServers ($servers_file) {
        if (is_file($servers_file)) {
                $file_handle = fopen ($servers_file, "r");
                $file_output = rtrim(fread($file_handle, filesize($servers_file)));
                $data = explode ("\n",$file_output);
                return $data;
        } else {
                echo "Listado de servers \"$servers_file\" no existe\n";
                exit;
        }
}

// Variables:
$servers_file = $argv[1];
echo "Server file is: $servers_file\n";
/////////////////////////////////////////////////////////////////////////////////////
//Tomo la data
//
$servidores = getServers($servers_file);
//print_r($servidores);
/////////////////////////////////////////////////////////////////////////////////////
foreach ($servidores as $server_string) {
        $server_components = explode(":",$server_string);
        echo "--------------------- BEGIN $server_components[0]:$server_components[1] ---------------------\n";
//Conectamos al memcache
        $memcache = new Memcache;
        $memcache->connect($server_components[0],$server_components[1]) or die ("No me puedo conectar a ".print_r($server_components));
                if ($memcache->flush()) {
                        echo "[OK]\n";
                } else {
                        echo "[FAIL]\n";
                }
        echo "--------------------- END $server_components[0]:$server_components[1] -----------------------\n";
}

?>
