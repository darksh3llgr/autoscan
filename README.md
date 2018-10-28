# autoscan

## Automated Scanning, Pentesting, Exploiting and Reporting

## Overview
## `autoscan.sh` 
Autoscan is a fully automated penetration testing tool linked to Metasploit and faraday.
Autoscan identifies the status of all opened ports on the target server and executes the exploit.
## Other tools
* Brutex
* CMSmap
* exploit-database
* Findsploit
* Goohak
* listmap
* MassBled
* serializekiller
* shoker
* ssh-audit
* Sublist3r
* testssl
* Windows-Exploit-Suggester
* XSSTracer
* yasuo
* arachni
* wpscan
* ...
* ..
* .

#Scann all TCP ports, and the most used UDP Ports.
#Many services enumerated and exploited.
#Generate for every tool action a logfile, so the pentester can red it after start the tool and come back from coffe (..or two...)... # then can start the real pentest ;-) # Enumerate the System OS and start exploits for this OS. Enumerated the service over port and start another tool or exploit, or both. # Import automated all generated xml, csv and nessus files to faraday reporting and colaboration server. I am not the owner of this tools! Most of the tools started from $TOOL_DIR. So if a tool not exist, look if the required tool is instaled or linked in your ToolDIR (../autoscan/tools/).

## Reporting
For Reporting you need a comercial license from Farady. This tool never include a Faraday license.
For more informations about faraday, please contact the faraday team.

## Install and execute
You need before use it, install some tools. The most of this tools are installed in Kali Linux
This script are testet with Kali Linux. 
Installscript exist, but is in development, if you use it, you use it at your own risk.
Download the scripts to /home/tools/autoscan. If the directory dont exist, make it.
Clone the repository in this folder.

## Windows
This script use standard exploits to exploit Windows Server 2012, Win7, WinXP and other Windows based OS, Websites and CMS systems and other services.

## Linux
The functionality exploiting remote unixoide OS systems are in progress.
But, many services enumerated and exploited also if the server is a linux host.

## Development
New tools are work in progress.
This tools at the moment have issues, so I never give a garanty for work without errors.
If you use it, you use it at your own risk.

## Webinterface
Exist, is a simple PHP Script, in development.

## Video
Yes, not on youtube :-)

## Images

![](Used_Tools_structure.png)

![](autoscan1.png)

![](autoscan2.png)

![](autoscan3.png)

![](autoscan4.png)

![](autoscan5.png)
 
## to do
* start nessus scan
* start a burp scan with the burp api
* add more tools and exploits
* solve all issues and complete the install script
* add veil support and nps_payload to distribute the payload over smb port
* add kerberos silver ticket extraction without msf
* more in smb enum and enum4linux ....
* compare more the output, example: is port 445 and win system then do .... also in linux .....
* ...... ......


