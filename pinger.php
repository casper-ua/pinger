<?
/*
 *
 * Copyright (c) 2001-2002 Andrey S Pankov <casper@casper.org.ua>
 * pinger V1.1.0
 * License: GPL v2
 *
 */
    clearstatcache();
    if (file_exists ("pinger.pid")) {
	echo "<html><head><META HTTP-EQUIV=\"Refresh\" CONTENT=\"60\"></head>\n";
	echo "<body><h1>Please wait...</h1></body></html>";
    } else {
	require "pinger.html";
    }
?>