#!/bin/bash
######################################
# Identify and show the Linux Version
# Created by Esteban Monge
# emonge@gbm.net
# Version: 0.1
# 07/01/12
# Version: 0.2
# 09/01/12
# Detect RedHat OS
######################################

FILE=/etc/debian_version
if [ -f $FILE ]
then
 echo "Debian GNU/Linux "`cat /etc/debian_version`" con el kernel "`uname -r`
else
 FILE=/etc/system-release
 if [ -f $FILE ]
 then
  echo `cat /etc/system-release`" con el kernel "`uname -r`
 else
  FILE=/etc/SuSE-release
  if [ -f $FILE ]
  then
    echo `cat /etc/SuSE-release`" KERNEL = "`uname -r`
  else
   FILE=/etc/redhat-release
   if [ -f $FILE ]
   then
    echo `cat /etc/redhat-release`" con el kernel "`uname -r`
   else
    echo "Otro sabor de Linux "`uname -rmvo`
   fi
  fi
 fi
fi

