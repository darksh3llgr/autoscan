#!/bin/bash

echo "IP / URL is: $1"
TARGET=$1
echo $TARGET

echo "Customer is: $2"
CUSTOMER=$2
echo $CUSTOMER

echo "Log path is: $3"
LOG=$3
echo $LOG
LOG_DIR=$LOG/$CUSTOMER
echo $LOG_DIR

echo "Report Server IP / URL is: $4"
ReportServer=$4
echo $ReportServer
#
OKBLUE='\033[94m'
OKRED='\033[91m'
OKGREEN='\033[92m'
OKORANGE='\033[93m'
RESET='\e[0m'
#
LOG_DIR=$LOG/$CUSTOMER
CustomerName=$CUSTOMER
workspace=$TARGET
WORK_DIR="/home/tools/autoscan/"
TOOL_DIR="/home/tools/autoscan/tools/"
WORKSPACE=$TARGET

DATE=$(date)
#
echo -e "${GREEN}====================================================================================${RESET}"
echo -e "$RED Import all files in Fraday ${RESET}"
echo -e "${GREEN}====================================================================================${RESET}"
echo '#!/usr/bin/python2.7' > $LOG_DIR/$CustomerName.py
echo 'from persistence.server import server'  >> $LOG_DIR/$CustomerName.py
echo 'import time' >> $LOG_DIR/$CustomerName.py
echo 'server.FARADAY_UP = False' >> $LOG_DIR/$CustomerName.py
echo 'server.SERVER_URL = "http://192.168.43.246:5985"'  >> $LOG_DIR/$CustomerName.py
echo 'server.AUTH_USER = "faraday"'  >> $LOG_DIR/$CustomerName.py
echo 'server.AUTH_PASS = "changeme"'  >> $LOG_DIR/$CustomerName.py
echo 'date_today = int(time.time() * 1000)'  >> $LOG_DIR/$CustomerName.py
echo "server.create_workspace('$CustomerName', '$CustomerName', 'DATE', 'DATE', '$CustomerName')" >> $LOG_DIR/$CustomerName.py

scp -P 22 -o StrictHostKeyChecking=no $LOG_DIR/$CustomerName.py root@$ReportServer:/root/infobyte/faraday/.
ssh -p 22 -o StrictHostKeyChecking=no root@$ReportServer  "cd /root/infobyte/faraday;python $CustomerName.py;exit"

faraday=/root/infobyte/faraday
cd $LOG_DIR

for XMLfile in $(ls -al | grep  xml | awk '{print $9}');
        do
        echo "Import  $XMLfile to faraday"
        python $faraday/faraday.pyc --cli --workspace $CustomerName -r $LOG_DIR/$XMLfile
done;
