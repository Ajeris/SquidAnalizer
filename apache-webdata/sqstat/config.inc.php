<?php
/* global settings */

$use_js=true; // use javascript for the HTML toolkits

// Maximum URL length to display in URI table column
DEFINE("SQSTAT_SHOWLEN",120);


// Timezone for date display (optional, auto-detected if not set)
// Example: "Europe/Moscow", "America/New_York", "Asia/Tokyo"
DEFINE("SQSTAT_TIMEZONE", "Asia/Qyzylorda");

/* proxy settings */

/* Squid proxy server ip address or host name */
$squidhost[0]="192.168.10.11";
/* Squid proxy server port */
$squidport[0]=8080;
/* cachemgr_passwd in squid.conf. Leave blank to disable authorisation */
$cachemgr_passwd[0]="secret";
/* Resolve user IP addresses or print them as numbers only [true|false] */
$resolveip[0]=false; 
/* uncomment next line if you want to use hosts-like file. 
   See hosts.txt.dist. */
// $hosts_file[0]="hosts.txt"
/* Group users by hostname - "host" or by User - "username". Username work only 
   with squid 2.6+ */ 
//$group_by[0]="host";
$group_by[0]="username";

/* you can specify more than one proxy in the configuration file, e.g.: */
$squidhost[1]="192.168.10.3";
$squidport[1]=8080;
$cachemgr_passwd[1]="secret";
$resolveip[1]=true;
$group_by[1]="host"; 
// $hosts_file[1]="otherhosts.txt"

/* you can specify more than one proxy in the configuration file, e.g.: */
$squidhost[2]="192.168.10.70";
$squidport[2]=3128;
$cachemgr_passwd[2]="secret";
$resolveip[2]=true;
$group_by[2]="username"; 
// $hosts_file[1]="otherhosts.txt"

/* you can specify more than one proxy in the configuration file, e.g.: */
$squidhost[3]="192.168.12.24";
$squidport[3]=3128;
$cachemgr_passwd[3]="secret";
$resolveip[3]=true;
$group_by[3]="username"; 
// $hosts_file[1]="otherhosts.txt"
?>
