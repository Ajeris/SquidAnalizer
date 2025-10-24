<?php
// SqStat main page
require_once 'config.inc.php';

echo "<h1>SqStat - Squid Statistics</h1>";
echo "<p>Configuration:</p>";
echo "<ul>";
echo "<li>Squid Host: " . $squidhost[0] . "</li>";
echo "<li>Squid Port: " . $squidport[0] . "</li>";
echo "<li>CacheMgr Password: " . (empty($cachemgr_passwd[0]) ? "Not set" : "***") . "</li>";
echo "</ul>";

// Простая проверка подключения к Squid
$connection_test = @fsockopen($squidhost[0], $squidport[0], $errno, $errstr, 5);
if ($connection_test) {
    echo "<p style='color: green;'>✓ Connection to Squid: OK</p>";
    fclose($connection_test);
} else {
    echo "<p style='color: red;'>✗ Connection to Squid: FAILED ($errno: $errstr)</p>";
    echo "<p>Try alternative configuration:</p>";
    echo "<pre>";
    echo "\$squidhost[0]=\"localhost\";\n";
    echo "\$squidport[0]=8078;  // external port\n";
    echo "</pre>";
}

echo "<p><a href='index.php'>Full SqStat Interface</a></p>";
?>
