#!/bin/bash
############################################
# nsca_client.sh
# Send checks to NSCA Server
# Created by Mike
# http://beginlinux.com
# September 15, 2009
# Modified by Esteban Monge
# emonge@gbm.net
# 27/01/13
# Version: 0.2
# Change check_ping by check_dummy
# Fix in disk,uptime and SWAP thresholds
# Fix in send_nsca path in Debian/Ubuntu
# 15/12/14
# Version: 0.3
# Universal configuration
############################################

# Configuracion
send_nsca_cfg=/usr/local/etc/send_nsca.cfg
nagioshost=CHANGEME
host=NOMBREPORDEFECTO
PATH=$PATH:/usr/lib/nagios/plugins:/usr/lib64/nagios/plugins:/usr/local/nagios/libexec

# Verificacion de Host
#output=`check_dummy 0 "This GNU/Linux arrived tuanis"`
#rc=$?
#echo -e "$host\t$rc\t$output\n"|send_nsca -H $nagioshost -c $send_nsca_cfg

# Servicios

# CPU Load
service="CPU Load"
output=`check_load -w 15,10,5 -c 30,25,20`
rc=$?
echo -e "$host\t$service\t$rc\t$output\n"|send_nsca -H $nagioshost -c $send_nsca_cfg

# Root Partition
service="Root Partition"
output=`check_disk -w 15% -c 10% -p /`
rc=$?
echo -e "$host\t$service\t$rc\t$output\n"|send_nsca -H $nagioshost -c $send_nsca_cfg

# SWAP
service="Swap Usage"
output=`check_swap -w 40% -c 35%`
rc=$?
echo -e "$host\t$service\t$rc\t$output\n"|send_nsca -H $nagioshost -c $send_nsca_cfg

# Uptime
service="Check Uptime"
output=`check_uptime3 -w 1440 -c 60`
rc=$?
echo -e "$host\t$service\t$rc\t$output\n"|send_nsca -H $nagioshost -c $send_nsca_cfg

# OS Version
service="Version"
output=`version.sh`
rc=$?
echo -e "$host\t$service\t$rc\t$output\n"|send_nsca -H $nagioshost -c $send_nsca_cfg

# NTP
service="NTP"
output=`check_ntp_time -H 172.16.1.253`
rc=$?
echo -e "$host\t$service\t$rc\t$output\n"|send_nsca -H $nagioshost -c $send_nsca_cfg

# nmon
#service="nmon"
#output=`check_procs -C nmon -w 1:1 -c 1:1`
#rc=$?
#echo -e "$host\t$service\t$rc\t$output\n"|send_nsca -H $nagioshost -c $send_nsca_cfg

# iostat
#service="iostat"
#output=`check_procs -C iostat -w 1:1 -c 1:1`
#rc=$?
#echo -e "$host\t$service\t$rc\t$output\n"|send_nsca -H $nagioshost -c $send_nsca_cfg


## Agregue aqui los puntos de montaje adicionales

