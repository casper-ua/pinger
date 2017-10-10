#!/usr/bin/perl
#/*
# *
# * Copyright (c) 2001-2002 Andrey S Pankov <casper@casper.org.ua>
# * pinger V1.1.0 
# * License: GPL v2
# *
# */


$workdir="/usr/local/www/noc/utils/pinger";
$router_ip="10.0.1.1";
$router_user="magdee";
$fhosts="pinger.conf";
$fconf="pinger.pid";
$fhtml="pinger.html";
$falarm="pinger.alarm";
$flost="pinger.lost";
$date=`date "+%Y-%m-%d %H:%M:%S"`;
$time=time();
chomp($date);

chdir($workdir);
open (CONFF, ">$fconf");
open (HOSTSF, "<$fhosts");
open (HTMLF, ">$fhtml");

print HTMLF "<html><head>\n";
print HTMLF "<META HTTP-EQUIV=\"Refresh\" CONTENT=\"350\">\n";
print HTMLF "<META HTTP-EQUIV=\"Pragma\" CONTENT=\"no-cache\">\n";
print HTMLF "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=koi8-r\">\n";
print HTMLF "</head><body bgcolor=\"#CCCCCC\">\n";
print HTMLF "<table width=\"100\%\"><tr>\n";
print HTMLF "<td weight=\"60%\" align=\"right\"><h2>Network status</h2></td>\n";
print HTMLF "<td align=\"right\" valign=\"top\"><font size=\"-1\">$date</font></td>\n";
print HTMLF "</tr></table>\n";

while (<HOSTSF>){
 ($host_ip, $host_desc, $host_num, $host_time, $host_status)=split(/:/);
 chomp($host_status);
 @stat=`/usr/bin/rsh $router_ip -l $router_user "ping $host_ip" && echo $?`;
 $stat5="x@stat[5]";
 ($s1,$s2)=split(/,/,@stat[4]);
 ($v1,$v2,$v3,$percent,$v5,$v6)=split(/ /,$s1);
 ($v1,$v2,$v3,$v4,$v5)=split(/ /,$s2);
 ($min,$avg,$max)=split(/\//,$v5);

 if ($host_time eq "") {
  $host_time=$time;
 }
 if ($percent eq "0") {
  $host_status_new="0";
  open(ALARM, ">>$falarm");
  print ALARM "$date $host_ip $host_num\n";
  close ALARM;
  # Status changed from UP to DOWN
  if ($host_status eq "1") {
   $host_time_new=$time;
   `echo "$date\n$host_desc ($host_ip) DOWN" | mail -s "Network status [$host_ip DOWN]" admin\@newtel`;
  } else {
   $host_time_new=$host_time;
  }
 } else {
  $host_status_new="1";
  # Status changed from DOWN to UP
  if ($host_status eq "0") {
   $host_time_new=$time;
   $host_down_time=sprintf("%01.0f",($host_time_new-$host_time)/60);
   `echo "$date\n$host_desc ($host_ip) UP\nDown for $host_down_time min." | mail -s "Network status [$host_ip UP]" admin\@newtel`;
  } else {
   $host_time_new=$host_time;
  }
 }

 print CONFF "$host_ip:$host_desc:$host_num:$host_time_new:$host_status_new\n";
 
 # Log LOSTs into file
 if (($percent < 100) and ($percent > 0)) {
  open(LOST, ">>$flost");
  print LOST "$date $host_ip $host_num $percent $min $avg $max\n";
  close LOST;
 }
 
 # Print web output
 $color="#0000AA";
 if ($percent eq "0") {
  $color="#FF0000";
  $min="0";
  $avg="0";
  $max="0";
 }
 if ($percent eq "100") {
  $color="#00AA00";
 }
 print HTMLF "<b>$host_desc $host_num</b> <tt>($host_ip)</tt><br>\n";
 if ($stat5 eq "x") {
    print HTMLF "<tt><font color=\"$color\">Status unavailable</font></tt><br><br>\n";
 } else {
    print HTMLF "<font color=\"$color\"><tt>$percent%";
    print HTMLF " $min/$avg/$max</tt>&nbsp;<font size=\"-1\">(";
    printf HTMLF "%01.1f",(($time-$host_time_new)/3600);
    print HTMLF "&nbsp;h)</font></font><br><br>\n";
 }
}
print HTMLF "<hr>\n";
print HTMLF "<center>";
print HTMLF "<a href=\"http://noc.newtel/utils/pinger/pinger.alarm\" target=\"_blank\">Failures</a>\n";
print HTMLF "&nbsp;|&nbsp;<a href=\"http://noc.newtel/utils/pinger/pinger.lost\" target=\"_blank\">Packets lost</a>\n";
print HTMLF "</center>";
print HTMLF "</body></html>";
close HTMLF;

close CONFF;
close HOSTSF;
rename ("$fconf", "$fhosts");
