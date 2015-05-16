#!/bin/bash
#########################################
# Uninstall nsca_client.sh | Linux Version
# Created by Esteban Monge
# emonge@gbm.net
# 11/12/14
# Version: 1.0
# The first 
#########################################

#
## Borrando archivos
#

rm /usr/local/bin/nsca_client*
rm /usr/local/etc/send_nsca.cfg
rm /usr/local/nagios/libexec/*
rmdir /usr/local/nagios/libexec/
rmdir /usr/local/nagios

#
## Limpiando crontab
#
