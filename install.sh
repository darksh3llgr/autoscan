#!/bin/bash

BLUE='\033[94m'
RED='\033[91m'
GREEN='\033[92m'
ORANGE='\033[93m'
RESET='\e[0m'

INSTALL_DIR=/home/tools/autoscan
LOG_DIR=/var/log/autoscan
TOOL_DIR=/home/tools/autoscan/tools

mkdir -p $INSTALL_DIR 2> /dev/null
mkdir -p $LOG_DIR 2> /dev/null
mkdir $TOOL_DIR 2> /dev/null
cd $TOOL_DIR

echo -e "$ORANGE + -- --=[Installing all dependencies...$RESET"
echo -e "$ORANGE + -- --=[download autoscan files in $INSTALL_DIR"
apt-get install ruby rubygems python arachni dos2unix zenmap sslyze uniscan xprobe2 cutycapt unicornscan host whois dirb dnsrecon curl nmap php php-curl hydra iceweasel wpscan sqlmap nbtscan enum4linux cisco-torch theharvester dnsenum nikto smtp-user-enum whatweb sslscan amap
pip install dnspython colorama tldextract urllib3 ipaddress arachni
gem install rake
gem install ruby-nmap net-http-persistent mechanize text-table
cd $INSTALL_DIR
echo -e "$ORANGE + -- --=[Downloading autoscan binary ...$RESET"
wget http://192.168.168.158:88/autoscan/autoscan.sh
cd $TOOL_DIR
echo -e "$ORANGE + -- --=[Downloading tools...$RESET"
git clone https://github.com/1N3/Findsploit.git 
git clone https://github.com/1N3/BruteX.git 
git clone https://github.com/1N3/Goohak.git 
git clone https://github.com/1N3/XSSTracer.git 
git clone https://github.com/1N3/MassBleed.git 
git clone https://github.com/1N3/SuperMicro-Password-Scanner 
git clone https://github.com/Dionach/CMSmap.git 
git clone https://github.com/0xsauby/yasuo.git 
git clone https://github.com/johndekroon/serializekiller.git 
git clone https://github.com/aboul3la/Sublist3r.git 
git clone https://github.com/nccgroup/shocker.git 
git clone https://github.com/drwetter/testssl.sh.git 
git clone https://github.com/lunarca/SimpleEmailSpoofer 
git clone https://github.com/arthepsy/ssh-audit 
wget https://svn.nmap.org/nmap/scripts/http-vuln-cve2017-5638.nse -O /usr/share/nmap/scripts/http-vuln-cve2017-5638.nse
git clone https://github.com/offensive-security/exploit-database.git
git clone https://github.com/GDSSecurity/Windows-Exploit-Suggester.git
cd Windows-Exploit-Suggester
./windows-exploit-suggester.py --update
pip install xlrd --upgrade
cd $TOOL_DIR
git clone https://github.com/infobyte/faraday.git faraday-dev
cd faraday-dev
sudo apt-get install build-essential ipython python-setuptools python-pip python-dev libssl-dev libffi-dev couchdb pkg-config libssl-dev libffi-dev libxml2-devlibxslt1-dev libfreetype6-dev libpng-dev
pip2 install -r requirements_server.txt
pip2 install -r requirements_extras.txt
pip2 install -r requirements_server_extras.txt
pip2 install -r requirements.txt
pip2 install -r require.txt
./install.sh
cd $INSTALL_DIR

echo -e "$ORANGE + -- --=[Setting up downloaded tools ...$RESET"
cd $TOOL_DIR/Findsploit/ && bash install.sh
cd $TOOL_DIR/BruteX/ && bash install.sh
cd $INSTALL_DIR
chmod +x $TOOL_DIR/Goohak/goohak
chmod +x $TOOL_DIR/XSSTracer/xsstracer.py
chmod +x $TOOL_DIR/MassBleed/massbleed
chmod +x $TOOL_DIR/MassBleed/heartbleed.py
chmod +x $TOOL_DIR/MassBleed/openssl_ccs.pl
chmod +x $TOOL_DIR/MassBleed/winshock.sh 
chmod +x $TOOL_DIR/SuperMicro-Password-Scanner/supermicro_scan.sh
chmod +x $TOOL_DIR/testssl.sh/testssl.sh
rm -f /usr/bin/goohak
rm -f /usr/bin/xsstracer
rm -f /usr/bin/findsploit
rm -f /usr/bin/copysploit
rm -f /usr/bin/compilesploit
rm -f /usr/bin/massbleed
rm -f /usr/bin/testssl
ln -s $TOOL_DIR/Goohak/goohak /usr/bin/goohak
ln -s $TOOL_DIR/XSSTracer/xsstracer.py /usr/bin/xsstracer
ln -s $TOOL_DIR/Findsploit/findsploit /usr/bin/findsploit
ln -s $TOOL_DIR/Findsploit/copysploit /usr/bin/copysploit
ln -s $TOOL_DIR/Findsploit/compilesploit /usr/bin/compilesploit
ln -s $TOOL_DIR/MassBleed/massbleed /usr/bin/massbleed
ln -s $TOOL_DIR/testssl.sh/testssl.sh /usr/bin/testssl
echo -e "$GREEN + -- --=[Done!$RESET"


