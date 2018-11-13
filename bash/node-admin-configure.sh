#!/bin/bash
#node-admin-configure.sh
MY_VERSION=0.1.2

# for things like:
# new VPS setup, adding git, nano, wget, ansible, SSH key
# adding new sudo users
# fail2ban
# configure IPv6 in /etc/network/interfaces
# install bootstrap
# call ansible plays

GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
NC='\e[0m'

get_latest_release() {
  curl --silent "$1" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

PKGS='git vim nano wget htop gzip ansible autotools-dev automake omake cmake libssl-dev libtool curl tree rsync software-properties-common pkg-config libevent-dev bsdmainutils libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev libdb4.8-dev libdb4.8++-dev'

clear

echo -e "${GREEN}Masternode Admin Configure - BETA ${NC}"
echo -e "${CYAN} --- ${NC}"
echo -e "${CYAN} server sysadmin tasks ${NC}"
echo -e "${CYAN}  ${NC}"
echo -e "${CYAN} --- ${NC}"
echo "*** working ***"
echo ""
echo ""

PS3="Please choose a task number (press enter to view menu) : "
options=("initial setup" "add sudo user" "reset user password" "install fail2ban" "configure ipv6" "install bootstrap" "task7" "update node" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "initial setup")
	 echo "${GREEN}this will update and configure a newly provisioned server.${NC}"
	 echo "${GREEN}this will update then isntall following packages via apt-get: ${NC}"
	 echo -e "${YELLOW} $PKGS ${NC}";
	 echo ""
	 sudo apt-get update
	 sudo apt-get upgrade -y
	 for pkg in $PKGS; do sudo apt-get install -y $pkg; done
	 echo -e "${GREEN} almost done... ${NC}"
	 sudo apt-get update
	 curl https://raw.githubusercontent.com/CobraKenji/thawed/master/ansible/keyzon/keyzon-fullplay.yml -o keyzon-fullplay.yml
	 ansible-playbook keyzon-fullplay.yml
	 RESULT=$?
	 if [ $RESULT -eq 0 ]; then
	  echo -e "${GREEN}success ${NC}"
	 else
	  echo -e "${YELLOW}failed. screenshot and contact your script kiddy ${NC}"
	 fi
	 #cat /root/ansible/keyzon.tmp.yml
	 rm keyzon-fullplay.yml
	 echo "...done..."
         echo "";
            ;;
        "add sudo user")
         #call ansible playbook to add new sudo user
	 echo -e "${GREEN} Grant sudo to a user. Creates new sudo user if not present. ${NC}"
	 echo -e "${YELLOW}!!! This will grant passwordless sudo access !!! ${NC}"
	 read -e -p "Enter sudo user name : " newSudoer
         echo -e "${YELLOW} Veryfing passwordless sudo access for $newSudoer ... ${NC}";
         echo ""
	 echo ""
	 curl https://raw.githubusercontent.com/CobraKenji/ubuntu1604/master/ansible/create-sudoer.yml -o create-sudoer.yml
	 ansible-playbook create-sudoer.yml --extra-vars "newSudoer=$newSudoer" --ask-become-pass
	 RESULT=$?
	 if [ $RESULT -eq 0 ]; then
  	  echo -e "${GREEN} $newSudoer is a passwordless sudo user. ${NC}"
	 else
  	  echo -e "${YELLOW}user sudo check failed. screenshot and contact your script kiddy${NC}"
	 fi
	 rm create-sudoer.yml
        echo "";
            ;;
        "reset user password")
	echo -e "${GREEN} Password reset ${NC}"
	read -e -p "Which user's password do you wish to set? : " newPwduser
	echo -e "${CYAN}changing password for $newPwduser ...${NC}"
	echo ""
	sudo passwd $newPwduser
        RESULT=$?
        if [ $RESULT -eq 0 ]; then
         echo -e "${CYAN}password for $newPwduser updated. ${NC}"
        else
         echo -e "${YELOW}failed. screenshot and contact your script kiddy${NC}"
        fi
        echo "";
            ;;
         "install fail2ban")
	read -e -p "Install Fail2ban? [y/n]" yesno

          case "$yesno" in
            y|Y )
		echo -e "${CYAN}Select an install profile: basic or strict?${NC}"
		read -e -p " : " f2bType
                case "$f2bType" in
                *basic*)
                        echo -e configuring "${GREEN}basic fail2ban${NC}" setup
                        echo ""
			sudo apt-get install fail2ban -y
                        echo -e "${YELLOW} Fail2ban installed ${NC}";
                        echo -e "${CYAN}you can edit the configuration at ${YELLOW}/etc/fail2ban/jail.local${CYAN} - Please be careful if you decide to edit this.${NC}"
                        ;;
                *strict*)
                        echo -e "${GREEN}NEED TO FINISH${NC}"
                        echo ""
                        echo -e "${CYAN}to install Fail2ban with a ${GREEN}HEAVY${NC}${CYAN} ban hammer${NC}"
			sudo apt-get install fail2ban -y
			sudo sed -i 's/bantime  = 600/bantime  = 10000/1' jail.conf
			sudo sed -i 's/findtime  = 600/findtime  = 10000 /1' jail.conf
			echo -e "${CYAN}Fail2ban installed and configured. More than 5 failed login attempts${NC}"
			echo -e "${CYAN}in 2.75 hours ${YELLOW}WILL BLACKLIST ${CYAN} your IP address for 2.75 hours.${NC}"
			echo -e "${YELLOW}Please do not guess your SSH password.${NC}"
                        ;;
                *)
                        echo -e "${YELLOW}$f2bType is not a valid option, idiot. Check your spelling.${NC}";
                        echo "";
                        esac
                        ;;
            n|N ) ;;
            * ) echo "invalid";;
            esac
            ;;
         "configure ipv6")
	read -e -p "Question? : " var2
        echo -e "${YELLOW} $var2 ${NC}";
        echo "something"
        echo "This task has not been completed.";
        echo "";
            ;;
         "install bootstrap")
	echo -e ""
	echo -e "${CYAN} --- ${NC}"
	echo 'coins with available bootstrap installers: worx '
	echo -e "${CYAN} --- ${NC}"
	read -e -p "Which coin do you want to bootstrap? " coinName
	read -e -p "Which $coinName user number? : " mnIteration
	case "$coinName" in
	    *worx[2-*])
             wrxUser="$coinName$mnIteration"
	     bstrap_path=/home/$wrxUser/.worx/
             echo -e using "${CYAN}$wrxUser${NC}" as the worx node user
	     echo -e using "${CYAN}$bstrap_path${NC}" during bootstrap install
             cd $bstrap_path
	     rm -rf blocks chainstate database banlist.dat peers.dat 2>/dev/null
	     echo -e "${YELLOW}Downloading Bootstrap...${NC}"
	     wget -q http://files.worxcoin.io/bootstrap.tar.gz -O bootstrap.tar.gz
	     echo -e "${YELLOW}time to untar${NC}"
	     tar -zxvf bootstrap.tar.gz >/dev/null 2>&1
	     echo -e "${YELLOW}Removing bootstap.tar.gz${NC}"
	     rm bootstrap.tar.gz; cd ~
	     echo -e "${CYAN}Done.${NC}"
		;;
	    worx)
             wrxUser="$coinName$mnIteration"
	     bstrap_path=/root/.worx/
             echo -e using "${CYAN}$wrxUser${NC}" as the worx node user
	     echo -e using "${CYAN}$bstrap_path${NC}" during bootstrap install
             cd $bstrap_path
	     rm -rf blocks chainstate database banlist.dat peers.dat 2>/dev/null
	     echo -e "${YELLOW}Downloading Bootstrap...${NC}"
	     wget -q http://files.worxcoin.io/bootstrap.tar.gz -O bootstrap.tar.gz
	     echo -e "${YELLOW}time to untar${NC}"
	     tar -zxvf bootstrap.tar.gz >/dev/null 2>&1
	     echo -e "${YELLOW}Removing bootstap.tar.gz${NC}"
	     rm bootstrap.tar.gz; cd ~
	     echo -e "${CYAN}Done.${NC}"
		;;
	     *)
	     echo -e "${YELLOW} Sorry - bootstrap install is not configured for the requested coin. ${NC}"
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
        echo -e "${YELLOW} Bootstrap installed to ${NC}";
        echo "$coinName"-cli -conf=/root/."$coinName$mnIteration"/"$coinName".conf -datadir=/root/."$coinName$mnIteration" masternode status
    	echo "";
    	echo "";
            ;;
         "task7")
        read -e -p "Which $coinName number? : " mnIteration
        echo EMPTY TASK SLOT 
        echo "";
            ;;
	 "update node")
        echo You are currently managing as user: "$(whoami)".
	echo -e "${YELLOW}You will need the URL to the updated version.${NC}"
	echo -e "${YELLOW}This will wget the tar, un-archive, then install the new version${NC}"
	echo -e "${YELLOW}No version checking is performed. Use with caution.${NC}"
	read -e -p "Enter URL to new wallet version : " newVersion
        echo "$newVersion";

	get_latest_release 'https://github.com/BlockchainFor/ESportBettingCoin/releases'
	curl -s https://api.github.com/repos/BlockchainFor/ESportBettingCoin/releases/latest \
	| grep "browser_download_url" \
	| cut -d : -f 2,3 \
	| tr -d \" \
	| wget -qi -

# my epic one-liner is maybe viable
curl -s https://api.github.com/repos/BlockchainFor/ESportBettingCoin/releases/latest | grep "browser_download_url.*tar.gz" | cut -d : -f 2,3 | sed '1q' | tr -d \" | xargs

            ;;


        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY"
         clear
           ;;
    esac
done


