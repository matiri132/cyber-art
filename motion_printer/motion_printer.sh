#!/bin/bash

VIDEO_DIR="/home/pi/videos"

LOG_DIR="/var/log/new_picture"
PREV_LOG="${LOG_DIR}/prev"
ACTUAL_LOG="${LOG_DIR}/actual"

PRINTER="HP_Ink_Tank"
PRINTER_BRAND="HP"

if [ $# -eq 0 ]; then
	INTERVAL=5
else
	INTERVAL=$1
fi

verify_dirs() {
	if [ ! -d $LOG_DIR ]; then
	       mkdir $LOG_DIR
	fi	       
	if [ ! -f $PREV_LOG ]; then
		touch $PREV_LOG
	fi
	
	if [ ! -f $ACTUAL_LOG ]; then
		touch $ACTUAL_LOG
	fi

	if [ ! -d $VIDEO_DIR ]; then
		mkdir $VIDEO_DIR
	fi
}

verify_printer() {
	lsusb | grep ${PRINTER_BRAND} > /dev/null
	if [ $? -eq 0 ]; then 
		lpstat -p ${PRINTER} | grep idle > /dev/null
		if [ $? -eq 0 ];then
			return 0	
		else
			return 1
		fi
	else
		return 2
	fi	
}

ref_actual() {	
	ls ${VIDEO_DIR} -t | grep jpg > $ACTUAL_LOG
}

ref_prev() {
	cat $ACTUAL_LOG > $PREV_LOG
}

verify_dirs
ref_actual
ref_prev

while [ true ]
do
	ref_actual
	NEW_PIC=$(diff $ACTUAL_LOG $PREV_LOG | tail -1 | cut -d " " -f 2)
	if [ ! -z $NEW_PIC ]; then
		echo "Enviando a imprimir: $NEW_PIC"
		verify_printer
		STATUS=$?
		if [ ${STATUS} -eq 0 ]; then
			lp -d ${PRINTER} -o media=Custom.360x550 ${VIDEO_DIR}/${NEW_PIC} 
		else
			echo "Failed to print ${NEW_PIC}. ERROR ${STATUS}"
		fi
	fi
	ref_prev
	sleep $INTERVAL
done




