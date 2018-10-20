#!/bin/bash
#autoscan and report to faraday by darksh3llgr
#19.06.2018

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

BLUE='\033[94m'
RED='\033[91m'
GREEN='\033[92m'
ORANGE='\033[93m'
#
#apt-get install nikto
#apt-get install arachni
#
LOG_DIR=$LOG/$CUSTOMER
mkdir -p $LOG_DIR
CustomerName=$CUSTOMER
workspace=$TARGET
WORK_DIR="/home/tools/autoscan"
TOOL_DIR="/home/tools/autoscan/tools"
USER_FILE="/usr/share/brutex/wordlists/simple-users.txt"
PASS_FILE="/usr/share/brutex/wordlists/password.lst"
DNS_FILE="/usr/share/brutex/wordlists/namelist.txt"
UDP_PORTS="53,67,68,69,88,123,161,162,137,138,139,389,520,2049"
SAMRDUMP="/home/tools/autoscan/bin/samrdump.py"
WORKSPACE=$TARGET
USER_FILE="/usr/share/wordlists/unix_users.txt"
PASS_FILE="/usr/share/wordlists/rockyou.txt"
LHOST=$(ifconfig  eth0 | grep -w inet | awk {'print $2'})
SRVHOST=$LHOST
#

#nikto -h https://$TARGET -Format xml -o $LOG_DIR/$TARGET.nikto_443.xml
arachni --report-save-path=$LOG_DIR/ --output-only-positives --checks=active/* https://$TARGET
arachni_reporter $LOG_DIR/*.afr --report=xml:outfile=$LOG_DIR/$TARGET-http_443.xml
#
echo -e "${GREEN}====================================================================================${RESET}"
echo -e "$RED Import all files in Fraday ${RESET}"
echo -e "${GREEN}====================================================================================${RESET}"
echo '#!/usr/bin/python2.7' > $LOG_DIR/$CustomerName.py
echo 'from persistence.server import server'  >> $LOG_DIR/$CustomerName.py
echo 'import time' >> $LOG_DIR/$CustomerName.py
echo 'server.FARADAY_UP = False' >> $LOG_DIR/$CustomerName.py
echo 'server.SERVER_URL = "http://80.147.112.98:55985"'  >> $LOG_DIR/$CustomerName.py
echo 'server.AUTH_USER = "faraday"'  >> $LOG_DIR/$CustomerName.py
echo 'server.AUTH_PASS = "changeme"'  >> $LOG_DIR/$CustomerName.py
echo '####'  >> $LOG_DIR/$CustomerName.py
echo 'date_today = int(time.time() * 1000)'  >> $LOG_DIR/$CustomerName.py
echo "server.create_workspace('$CustomerName', '$CustomerName', date_today, date_today, '$CustomerName')" >> $LOG_DIR/$CustomerName.py
#
scp -P 65022 -o StrictHostKeyChecking=no $LOG_DIR/$CustomerName.py root@$ReportServer:/root/infobyte/faraday/.
ssh -p 65022 -o StrictHostKeyChecking=no root@$ReportServer  "cd /root/infobyte/faraday;python $CustomerName.py;exit"
#
faraday=/root/infobyte/faraday
cd $LOG_DIR

for XMLfile in $(ls -al | grep  xml | awk '{print $9}');
        do
        echo -e "${GREEN}====================================================================================${RESET}"
        echo -e "$RED Import all files in Faraday  ${RESET}"
        echo -e "${GREEN}====================================================================================${RESET}"
        python $faraday/faraday.pyc --cli --workspace $CustomerName -r $LOG_DIR/$XMLfile
done;

