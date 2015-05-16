#!/bin/bash
#########################################
# Install nsca_client.sh | Linux Version
# Created by Esteban Monge
# emonge@gbm.net
# 11/12/14
# Version: 2.0
# Complete rewrite
# Less lines
# Less if
# Moved configuration to non standard distro location
# Moved extra plugins to non standard distro location
# Universal installer 
#########################################

#
## Verificar usuario administrador
#

USUARIO=`whoami`
if [ $USUARIO != root ]; then
 echo "Debe ser el usuario root para continuar"
 exit
fi

NSCA_CLIENT_PATH=/usr/local/bin
SEND_NSCA_CONFIG=/usr/local/etc
EXTRA_PLUGINS_PATH=/usr/local/nagios/libexec

#
## Verificar sistema operativo
#

ARCHIVO_DEBIAN=/etc/debian_version
ARCHIVO_CENTOS=/etc/system_release
ARCHIVO_SUSE=/etc/SuSE-release
ARCHIVO_REDHAT=/etc/redhat-release

if [ -f $ARCHIVO_DEBIAN ]
then
	INSTALLTYPE=debian
fi

if [ -f $ARCHIVO_CENTOS ]
then
	INSTALLTYPE=centos
fi
if [ -f $ARCHIVO_SUSE ]
then
	INSTALLTYPE=suse
fi

if [ -f $ARCHIVO_REDHAT ]
then
	INSTALLTYPE=redhat
fi

if [ -z $INSTALLTYPE ]
then
	echo "Lo siento su sistema operativo no esta soportado"
	exit
fi

echo "Tipo de instalacion $INSTALLTYPE"

#
## Verificar plugins
#

if [ -d /usr/lib/nagios/plugins/ -o -d /usr/lib64/nagios/plugins ]
then
	echo "Plugins instalados"
else
	echo "Lo siento los plugins no estan instalados"
	exit
fi

#
## Instalar cliente 
#

if [ -f $NSCA_CLIENT_PATH/nsca_client.sh ]; then
	echo "Se ha detectado una antigua version de nsca_client.sh"
	echo "Creando backup"
	cp $NSCA_CLIENT_PATH/nsca_client.sh $NSCA_CLIENT_PATH/nsca_client`date +%Y%m%d%H%M%S`.sh
fi

if [ -d $SEND_NSCA_CONFIG ]; then
	echo "Todo va bien"
else 
	mkdir /usr/local/etc
fi

if [ -f $SEND_NSCA_CONFIG/send_nsca.cfg ]; then
	echo "Se ha detectado una antigua version de nsca_client.sh"
	echo "Creando backup"
	cp $NSCA_CLIENT_PATH/nsca_client.sh $NSCA_CLIENT_PATH/nsca_client`date +%Y%m%d%H%M%S`.sh
fi

INSTALL_DIRECTORY=`pwd`
cp $INSTALL_DIRECTORY/nsca_client.sh $NSCA_CLIENT_PATH
cp $INSTALL_DIRECTORY/send_nsca.cfg $SEND_NSCA_CONFIG


#
## Instalando plugins extra 
#
mkdir -p $EXTRA_PLUGINS_PATH
cp $INSTALL_DIRECTORY/extra/* $EXTRA_PLUGINS_PATH

#
## Configurar el hostname del equipo
#

HOSTNAME=`hostname`
echo "Vamos a configurar el hostname del equipo"
echo "Recuerde que el formato a utilizar es el siguiente:"
echo "hostname.CLIENTE"
echo "Digite el nombre del cliente:"
read CLIENTE
echo "El hostname actual es $HOSTNAME"
while true; do
    read -p "Desea utilizarlo? " sn
    case $sn in
        [YySs1]* ) echo "Configurando hostname"
		  break;;
        [Nn0]* ) 
		echo "No utilice caracteres especiales, puede utilizar el caracter \"_\" ademas del \".\""
		echo "Digite el nombre del equipo: "
		read HOSTNAME;
		echo "Configurando hostname"
		break;;
        * ) echo "Por favor indique si o no.";;
    esac
done
if [ -z $CLIENTE ]; then
	sed -i s/NOMBREPORDEFECTO/$HOSTNAME/g $NSCA_CLIENT_PATH/nsca_client.sh
else
	sed -i s/NOMBREPORDEFECTO/$HOSTNAME.$CLIENTE/g $NSCA_CLIENT_PATH/nsca_client.sh
fi

#
## Configurar puntos de montaje 
#

echo "Se configuran los siguientes puntos de montaje: "
for i in `df -P | column | egrep -v 'udev|rootfs|tmpfs|Montado|Mounted|loop' | grep -vw '/' | awk '{print $6}'`; do
	echo "" >> $NSCA_CLIENT_PATH/nsca_client.sh
        echo "# $i Partition" >> $NSCA_CLIENT_PATH/nsca_client.sh
        echo "service=\"$i Partition\"" >> $NSCA_CLIENT_PATH/nsca_client.sh
        echo "output=\`check_disk -w 15% -c 10% -p $i\`" >> $NSCA_CLIENT_PATH/nsca_client.sh
        echo "rc=\$?" >> $NSCA_CLIENT_PATH/nsca_client.sh
        echo "echo -e \"\$host\\t\$service\\t\$rc\\t\$output\\n\"|send_nsca -H \$nagioshost -c \$send_nsca_cfg" >> $NSCA_CLIENT_PATH/nsca_client.sh
	echo $i
done

#
## Configurar crontab 
#

PROGRAMADO=`cat /etc/crontab | grep "## Programacion Automatica NSCA Client"`
if [ "$PROGRAMADO" != "" ]; then
	echo "Ya se encuentra programado NSCA Client en este equipo"
	echo "Ha finalizado la instalacion de NSCA Client"
else
	echo "Creando backup de /etc/crontab"
	cp /etc/crontab /etc/crontab`date +%Y%m%d%H%M%S`
	echo "" >> /etc/crontab
	echo "## Programacion Automatica NSCA Client" >> /etc/crontab
	echo "*/5 *    * * *    root    $NSCA_CLIENT_PATH/nsca_client.sh" >> /etc/crontab
	echo "" >> /etc/crontab
	echo "Ha finalizado la instalacion de NSCA Client"
	echo "Consulte el manual para agregar mas puntos de montaje de ser necesario"
fi
