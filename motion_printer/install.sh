#!/bin/bash

#Dependencies
apt install motion ffpeg omxplayer hplip cups 

#Cups user
usermod -a -G lpadmin pi

#Config motion
cp motion.conf /etc/motion/motion.conf
cp motion-stop /usr/local/bin

#Install script
cp motion_printer.sh /usr/local/bin

#Set Service
cp ksa_roja.service /etc/systemd/system/ksa_roja.service

systemctl start ksa_roja.service

