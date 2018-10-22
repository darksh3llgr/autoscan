#!/bin/bash
#
# Import XML Files in Metasploit and Faraday
# by @darkshellGR
# please dont copy, do a fork ;-)
# You need metasploit installed and faraday local on your host
# start the script ./MSFaradayimport.sh TARGET Customername LOGFOLDER REPORTSERVER
# example: ./MSFaradayimport.sh 1.2.3.4 Blabla /var/log 11.22.33.44
#
CUSTOMER=$2
echo $CUSTOMER
echo "Log path is: $2"
LOG=$3
echo $LOG
LOG_DIR=$LOG/$CUSTOMER
echo $LOG_DIR
echo "Report Server IP / URL is: $3"
ReportServer=$3
echo $ReportServer
echo "reportserver $ReportServer" > /etc/hosts 
#
OKBLUE='\033[94m'
OKRED='\033[91m'
OKGREEN='\033[92m'
OKORANGE='\033[93m'
RESET='\e[0m'
#
CustomerName=$CUSTOMER
workspace=$CUSTOMER
"pwd"$Dir
workdir=$Dir
#
echo -e "${OKGREEN}====================================================================================${RESET}"
echo -e "$OKRED Import all files in metasploit  $RESET"
echo -e "${OKGREEN}====================================================================================${RESET}"
echo "automated metasploit import tool for xml files by @darksh3llgr"
service postgresql restart
service couchdb restart
msfconsole -x "workspace -a $workspace; workspace $workspace; db_import $LOG_DIR/*.xml; db_impor $LOG_DIR/*.nessus; exit"
msfconsole -x "workspace -a $workspace; workspace $workspace; db_export -f xml $LOG_DIR/$CUSTOMER.msf.xml;exit"
#
DATE=$(date)
#
echo -e "${GREEN}====================================================================================${RESET}"
echo -e "$RED Import all files in Fraday ${RESET}"
echo -e "${GREEN}====================================================================================${RESET}"
echo '#!/usr/bin/python2.7' > $LOG_DIR/$CustomerName.py
echo 'from persistence.server import server'  >> $LOG_DIR/$CustomerName.py
echo 'import time' >> $LOG_DIR/$CustomerName.py
echo 'server.FARADAY_UP = False' >> $LOG_DIR/$CustomerName.py
echo 'server.SERVER_URL = "http://reportserver:5985"'  >> $LOG_DIR/$CustomerName.py
echo 'server.AUTH_USER = "faraday"'  >> $LOG_DIR/$CustomerName.py
echo 'server.AUTH_PASS = "changeme"'  >> $LOG_DIR/$CustomerName.py
echo 'date_today = int(time.time() * 1000)'  >> $LOG_DIR/$CustomerName.py
echo "server.create_workspace('$CustomerName', '$CustomerName', 'DATE', 'DATE', '$CustomerName')" >> $LOG_DIR/$CustomerName.py
#
scp -P 22 -o StrictHostKeyChecking=no $LOG_DIR/$CustomerName.py root@$ReportServer:/root/infobyte/faraday/.
ssh -p 22 -o StrictHostKeyChecking=no root@$ReportServer  "cd /root/infobyte/faraday;python $CustomerName.py;exit"
#
faraday=/root/infobyte/faraday
cd $LOG_DIR
#
for XMLfile in $(ls -al | grep  xml | awk '{print $9}');
        do 
	echo "Import $XMLfile to faraday"
	python $faraday/faraday.pyc --cli --workspace $CustomerName -r $LOG_DIR/$XMLfile
done;
