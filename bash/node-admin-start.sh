#!/bin/bash
#node-admin-start.sh
# v0.1.1

GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
NC='\e[0m'

SUPPORTED_COINS=(
        'dextro (DXO)'
        'worx (WORX)'
        'e-sports betting coin (ESBC)'
        )

WEBSITE_ALL=(
        'https://dextro.io/'
        'https://worxcoin.io/'
        'http://esbproject.online/'
        )

DXO_INSTALL_CMD=''
WORX_INSTALL_CMD='sudo bash <(curl https://raw.githubusercontent.com/worxcoin/WorxInstaller/master/worx_installer)'
ESBC_INSTALL_CMD=''


clear

echo -e "${GREEN}Masternode Administrator Menu ${NC}"
echo -e "${CYAN} --- ${NC}"
echo -e "${CYAN} supported coins:${NC}"
echo -e "${CYAN} dextro, dinero, worx, ${NC}"
echo -e "${CYAN} --- ${NC}"
echo "*** this is no longer a beta - commands will attempt to execute ***"
echo ""
echo ""
echo -e "${YELLOW}CURRENTLY SUPPORTED COINS${NC}"
for i in $SUPPORTED_COINS; echo $i; done
echo ""
echo "ENTER A COIN NAME FROM THE LIST ABOVE (all lowercase): "
read -e -p " : " coinName

PS3="Please choose a task number (press enter to view menu) : "
options=("start" "stop" "getinfo" "edit config" "mnsync status" "masternode status" "install" "change coin" "list nodes" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "start")
         #systemctl start $coinName
         read -e -p "Which $coinName number? : " mnIteration
	 echo -e "${YELLOW}starting node $coinName$mnIteration ${NC}";
	 sudo "$coinName"d -daemon -datadir=/root/."$coinName$mnIteration"
        echo "";
            ;;
        "stop")
         #systemctl stop $coinName
	 read -e -p "Which $coinName number? : " mnIteration
         echo -e "${YELLOW}stopping $coinName$mnIteration node ${NC}";
         sudo "$coinName"-cli -datadir=/root/."$coinName$mnIteration" stop
        echo "";
            ;;
        "getinfo") 
	read -e -p "Which $coinName number? : " mnIteration
  	  case "$coinName" in
	    *worx*)
             wrxUser="$coinName$mnIteration"
             echo -e using "${GREEN}$wrxUser${NC}" as the worx node user
             sudo su -c "$coinName-cli -datadir=/root/.$coinName$mnIteration getinfo" "$wrxUser"
		;;
	  *)
	  sudo "$coinName"-cli -datadir=/root/."$coinName$mnIteration" getinfo
		;;
	    esac
	    ;;    
         "edit config")
	read -e -p "Which $coinName number? : " mnIteration

          case "$coinName" in
            *worx*)
             wrxUser="$coinName$mnIteration"
             echo -e using "${GREEN}$wrxUser${NC}" as the worx node user
             sudo su -c "nano /root/."$coinName$mnIteration"/"$coinName".conf" "$wrxUser"
                ;;
          *)
          sudo nano /root/."$coinName$mnIteration"/"$coinName".conf
                ;;
            esac
        echo "";
            ;;
         "mnsync status")
	read -e -p "Which $coinName number? : " mnIteration

          case "$coinName" in
            *worx*)
             wrxUser="$coinName$mnIteration"
             echo -e using "${GREEN}$wrxUser${NC}" as the worx node user
	     echo ""
	     echo -e "${YELLOW}$coinName$mnIteration mnsync status: ${NC}";
             sudo su -c ""$coinName"-cli -datadir=/root/.$coinName$mnIteration mnsync status" "$wrxUser"
                ;;
          *)
          echo -e "${YELLOW}$coinName$mnIteration mnsync status: ${NC}";
          sudo "$coinName"-cli -datadir=/root/."$coinName$mnIteration" mnsync status
                ;;
            esac
        echo "";
            ;;
        "masternode status")
	read -e -p "Which $coinName number? : " mnIteration

          case "$coinName" in
            *worx*)
             wrxUser="$coinName$mnIteration"
             echo -e using "${GREEN}$wrxUser${NC}" as the worx node user
	     echo ""
             echo -e "${YELLOW}$coinName$mnIteration masternode status : ${NC}";
             sudo su -c ""$coinName"-cli -datadir=/root/.$coinName$mnIteration masternode status" "$wrxUser"
                ;;
          *)
          echo -e "${YELLOW}$coinName$mnIteration masternode status : ${NC}";
          sudo "$coinName"-cli -datadir=/root/."$coinName$mnIteration" masternode status        
                ;;
            esac
    	echo "";
            ;;
         "install")
        read -e -p "Please confirm that you want to install a $coinName masternode on this server. [y/n] "

          case "$coinName" in
            *worx*)
             wrxUser="$coinName$mnIteration"
             echo -e using "${GREEN}$wrxUser${NC}" as the worx node user
             echo ""
             echo -e "${YELLOW} NEED TO FINISH ${NC}";
             sudo su -c "whoami" "$wrxUser"
	     echo -e "${CYAN}to ask N0X about differences in installing first ${YELLOW}worx${CYAN} node versus additional nodes${NC}"
                ;;
            *dextro*)
             echo -e "${GREEN}NEED TO FINISH${NC}"
             echo ""
             echo -e "${CYAN}to ask N0X about his peferred process for installing ${GREEN}$coinName${CYAN} nodes${NC}"
                ;;
            *esportsbettingcoin*)
             echo -e using "${GREEN}$wrxUser${NC}" as the worx node user
             echo "use the install instructions at:"
	     echo -e "${CYAN}https://github.com/BlockchainFor/ESportBettingCoin${NC}"
             
                ;;

          *)
          echo -e "${YELLOW}$coinName is not supported, idiot. ${NC}";
	echo "";
            ;;
         "list nodes")
        sudo ls -lah /root/ | grep "$coinName" | awk '{print $9}'
        echo "";
            ;;

	 "change coin")
        echo you are currently managing "$coinName".
	echo select a coin to manage:
	read -e -p "dextro, dinero, worx, monero, etc... " coinName
        echo "";
            ;;

        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY"
         clear
           ;;
    esac
done
