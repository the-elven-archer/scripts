#!/usr/bin/php
<?php

// Cache cleaner - Limpio las caches de memcache :D
// Consultas: santiago.buczak@vostu.com
// Chequeos previos
if (empty($argv[1])) {
	echo "Falta listado de Servers\n";
	usage();
	return 1;
	exit;
}
if (empty($argv[2])) {
        echo "Falta listado de IDs\n";
	usage();
	return 2;
        exit;
}
////////////////////////////////////////////////////////////////////////////////////
// Funciones

//usage
//Muestra como usar el script si el usuario metio la pata en los parametros
function usage() {
	echo "Cache Cleaner - Script para limpieza de Memcaches\n";
	echo "Usage:\n";
	echo "memcache_delete.php <ARCHIVO_LISTA_SERVERS> <ARCHIVO_LISTA_IDS>";
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

//getIds
//Lee el archivo de IDs a borrar y lo devuelve en una variable
function getIds ($ids_file) {
	if (is_file($ids_file)) {
		$file_ids_handle = fopen ($ids_file, "r");
		$file_ids_output = fread($file_ids_handle, filesize($ids_file));
		$ids = $file_ids_output;
		return $ids;
	} else {
		echo "Listado de IDs \"$ids_file\" no existe\n";
		exit;
	}
}

// Variables:
$servers_file = $argv[1];
echo "Server file is: $servers_file\n";

$ids_file = $argv[2];
echo "IDs file is: $ids_file\n";

/////////////////////////////////////////////////////////////////////////////////////
//Tomo la data
//
$servidores = getServers($servers_file);
//print_r($servidores);

$listado = getIds ($ids_file);
//echo $listado;

/////////////////////////////////////////////////////////////////////////////////////

foreach ($servidores as $server_string) {
	$server_components = explode(":",$server_string);
	echo "--------------------- BEGIN $server_components[0]:$server_components[1] ---------------------\n";
//Conectamos al memcache
	$memcache = new Memcache;
	$memcache->connect($server_components[0],$server_components[1]) or die ("No me puedo conectar a ".print_r($server_components));
//Si, ya se, es un quilombo haber metido la lista de IDs en un array AHORA... Peeeero, mejor tarde que nunca	
	$Ids_array = explode("\n",rtrim($listado));
	foreach ($Ids_array as $ID) {
		echo "Removing $server_components[0]:$server_components[1] ---> $ID\t";
		if ($memcache->delete($ID)) {
			echo "[OK]\n";
		} else {
			echo "[FAIL]\n";
		}
	}
	echo "--------------------- END $server_components[0]:$server_components[1] -----------------------\n";
}
?>

