#!/bin/bash
# Author Name: Daniel Aboyewa
# email: info@lolubyte.com
# url: www.lbitc.com
# Secondry Url: www.lolubyte.com 
# Testing webhook
/etc/rc.d/init.d/nagios start
/usr/sbin/httpd -k start
tail -f /var/log/httpd/access_log /var/log/httpd/error_log
