<?php
// SqStat configuration for Docker environment

// Squid proxy settings
$squid_host = 'squid-proxy-service';  // Docker service name
$squid_port = 3128;                   // Internal Squid port
$cachemgr_passwd = 'squid_stats';     // Password from squid.conf

// Alternative configuration for external access
// $squid_host = 'localhost';
// $squid_port = 8078;  // External mapped port

// Display settings
$refresh_time = 30;  // Auto-refresh time in seconds
$show_graphs = true;
$show_details = true;

// Language settings
$language = 'en';  // en, ru, etc.
?>
