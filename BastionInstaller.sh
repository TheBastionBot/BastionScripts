#!/bin/bash
set -e
reset

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'

if [ "$(id -u)" != "0" ]; then
  echo -e "${CYAN}[Bastion]: ${ORANGE}[ERROR] Bastion BOT Installer requires root permissions."
  hash sudo 1>/dev/null 2>&1 || (echo -e "${CYAN}[Bastion]: ${NC} Run this installer with root permissions.\n" && exit 1)
  sudo ./BastionInstaller.sh
  exit 1
fi

cd ~

echo "-------------------------------"
echo "     Bastion BOT Installer"
echo "-------------------------------"
echo

echo -e "${CYAN}[Bastion]:${NC} Initializing System..."
echo -e "${CYAN}[Bastion]:${NC} Updating your system, this may take a while."
if hash apt-get 1>/dev/null 2>&1
then
  apt-get update &>/dev/null || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to update system.${NC} Check your internet connection and try running this installer again." && exit 1)
  apt-get install -y checkinstall &>/dev/null
  apt-get install -y build-essential &>/dev/null || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install build-essential.${NC} Before running this installer, try installing build-essential by typing: sudo apt-get install build-essential" && exit 1)
elif hash yum 1>/dev/null 2>&1
then
  yum update --exclude=kernel* &>/dev/null || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to update system.${NC} Check your internet connection and try running this installer again." && exit 1)
  apt-get install -y checkinstall &>/dev/null
  yum groupinstall "Development Tools" &>/dev/null || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install build-essential.${NC} Before running this installer, try installing Development Tools by typing: sudo yum groupinstall \"Development Tools\"" && exit 1)
else echo -e "${CYAN}[Bastion]: ${ORANGE}[WARNING] Your package manager is currently not supported (by this installer).${NC} Contact the Bastion BOT team in the help server (https://discord.gg/fzx8fkt) for guide with manual installation." && exit 1
fi
echo

echo -e "${CYAN}[Bastion]:${NC} Verifying Git installation..."
if hash git 1>/dev/null 2>&1
then
    echo -e "${CYAN}[Bastion]:${NC} Git already installed. Looks good."
else
    echo -e "${CYAN}[Bastion]:${NC} Git not installed." && echo -e "${CYAN}[Bastion]:${NC} Installing Git..."
    if hash apt-get 1>/dev/null 2>&1
    then (apt-get install -y git &>/dev/null && echo -e "${CYAN}[Bastion]:${NC} Done \o/") || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install Git.${NC} Before running this installer, try installing git by typing: sudo apt-get install git" && exit 1)
    elif hash yum 1>/dev/null 2>&1
    then (yum install -y git &>/dev/null && echo -e "${CYAN}[Bastion]:${NC} Done \o/") || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install Git.${NC} Before running this installer, try installing git by typing: sudo yum install git" && exit 1)
    else echo -e "${CYAN}[Bastion]: ${ORANGE}[WARNING] Your package manager is currently not supported (by this installer).${NC} Contact the Bastion BOT team in the help server (https://discord.gg/fzx8fkt) for guide with manual installation." && exit 1
    fi
    echo -e "${CYAN}[Bastion]:${NC} Done \o/"
fi
echo

echo -e "${CYAN}[Bastion]:${NC} Verifying Node installation..."
if hash node 1>/dev/null 2>&1
then
    echo -e "${CYAN}[Bastion]:${NC} Node already installed. Looks good."
else
    echo -e "${CYAN}[Bastion]:${NC} Node not installed." && echo -e "${CYAN}[Bastion]:${NC} Installing Node..."
    if hash apt-get 1>/dev/null 2>&1
    then
        curl -sL https://deb.nodesource.com/setup_7.x -o nodesource_setup.sh || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download Node.${NC} Check your internet connection." && exit 1)
        (chmod +x nodesource_setup.sh && ./nodesource_setup.sh 1>/dev/null && apt-get install -y nodejs 1>/dev/null) || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install Node.${NC} Before running this installer, try installing node manually." && exit 1)
    elif hash yum 1>/dev/null 2>&1
    then
        wget https://nodejs.org/download/release/v7.4.0/node-v7.4.0.tar.gz || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download Node.${NC} Check your internet connection." && exit 1)
        (tar xvf node-v7.4.0.tar.gz && cd node-v7.4.0 && yum install gcc gcc-c++ && ./configure && make && checkinstall) || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install Node.${NC} Before running this installer, try installing node manually." && exit 1)
    else echo -e "${CYAN}[Bastion]: ${ORANGE}[WARNING] Your package manager is currently not supported (by this installer).${NC} Contact the Bastion BOT team in the help server (https://discord.gg/fzx8fkt) for guide with manual installation." && exit 1
    fi
    echo -e "${CYAN}[Bastion]:${NC} Done \o/"
fi
echo

echo -e "${CYAN}[Bastion]:${NC} Installing music module (ffmpeg)..."
if hash ffmpeg 1>/dev/null 2>&1
then
  echo -e "${CYAN}[Bastion]:${NC} ffmpeg already installed. Looks good."
else
  if [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then
    OS='Debian'
    VER=$(< /etc/debian_version grep -oP "[0-9]+" | head -1 )
  elif [ -f /etc/centos-release ]; then
    OS='CentOS'
    VER=$(< /etc/centos-release grep -oP "[0-9]+" | head -1 )
  else
    OS=$(uname -s)
    VER=$(uname -r)
  fi
  if [ "$OS" = "Ubuntu" ]; then
    if [ "$VER" = "14.04" ]; then
      (add-apt-repository ppa:mc3man/trusty-media &>/dev/null && apt-get update &>/dev/null) || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to update system configurations.${NC} Check your internet connection and try running this installer again." && exit 1)
    fi
    apt-get install -y ffmpeg &>/dev/null
  elif [ "$OS" = "Debian" ]; then
    if [ "$VER" = "8" ]; then
      (echo "deb http://ftp.debian.org/debian jessie-backports main" | tee /etc/apt/sources.list.d/debian-backports.list &>/dev/null && apt-get update &>/dev/null) || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to update system configurations.${NC} Check your internet connection and try running this installer again." && exit 1)
    fi
    apt-get install -y ffmpeg &>/dev/null
  elif [ "$OS" = "CentOS" ]; then
    if [ "$VER" = "7" ]; then
      (rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro &>/dev/null && rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm &>/dev/null && yum update --exclude=kernel* &>/dev/null) || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to update system configurations.${NC} Check your internet connection and try running this installer again." && exit 1)
    elif [ "$VER" = "6" ]; then
      (rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro &>/dev/null && rpm -Uvh http://li.nux.ro/download/nux/dextop/el6/x86_64/nux-dextop-release-0-2.el6.nux.noarch.rpm &>/dev/null && yum update --exclude=kernel* &>/dev/null) || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to update system configurations.${NC} Check your internet connection and try running this installer again." && exit 1)
    fi
    yum install -y ffmpeg &>/dev/null
  fi
  if hash ffmpeg 1>/dev/null 2>&1
  then
    echo -e "${CYAN}[Bastion]:${NC} Done \o/"
  else
    (cd ~ && git clone -q --depth 1 git://source.ffmpeg.org/ffmpeg) || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download ffmpeg.${NC} Check your internet connection." && exit 1)
    (cd ffmpeg && ./configure --enable-gpl --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-librtmp --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-nonfree --enable-version3 && make && checkinstall --pkgname=ffmpeg --pkgversion="5:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default) || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install ffmpeg.${NC} Ask for help in the Bastion BOT help server (https://discord.gg/fzx8fkt)." && exit 1)
    echo -e "${CYAN}[Bastion]:${NC} Done \o/"
    cd ~
  fi
fi
echo

echo -e "${CYAN}[Bastion]:${NC} Installing system files..."
echo
(cd ~ && git clone -b master -q --depth 1 https://github.com/snkrsnkampa/Bastion.git) || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download Bastion system files.${NC}" && exit 1)
(cd Bastion && npm install) || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download and install Bastion system dependencies.${NC} Check your internet connection." && exit 1)
echo -e "${CYAN}[Bastion]:${NC} System files successfully installed."
echo

echo -e "${CYAN}[Bastion]:${NC} Finalizing..."
cd settings && cp config_example.json config.json && cp credentials_example.json credentials.json && echo -e "${CYAN}[Bastion]:${NC} Done."
echo
echo -e "${CYAN}[Bastion]:${NC} Do you want to setup credentials now?"
echo -en "${GREEN}[User]:${NC} "
read -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo -e "${CYAN}[Bastion]:${NC} Please enter the BOT ID"
    echo -en "${GREEN}[User]:${NC} "
    read -r botId
    echo -e "${CYAN}[Bastion]:${NC} Please enter the BOT Token"
    echo -en "${GREEN}[User]:${NC} "
    read -r token
    echo -e "${CYAN}[Bastion]:${NC} Please enter the Owner ID"
    echo -en "${GREEN}[User]:${NC} "
    read -r ownerId
fi
{
  echo "{"
  echo "  \"botId\": \"$botId\","
  echo "  \"token\": \"$token\","
  echo "  \"ownerId\": ["
  echo "    \"$ownerId\""
  echo "  ]"
  echo "}"
} > credentials.json
echo
echo -e "${CYAN}[Bastion]:${NC} Do you want to configure BOT now?"
echo -en "${GREEN}[User]:${NC} "
read -n 1 -r
echo
prefix="?bas"
status="online"
game="with servers"
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo -e "${CYAN}[Bastion]:${NC} What should be the commands' prefix? [Default: ?bas]"
    echo -en "${GREEN}[User]:${NC} "
    read -r prefix
    echo -e "${CYAN}[Bastion]:${NC} What should be the BOT's status? [Default: online]"
    echo -e "${CYAN}[Bastion]:${NC} [online / idle / dnd / invisible]"
    echo -en "${GREEN}[User]:${NC} "
    read -r status
    echo -e "${CYAN}[Bastion]:${NC} What should be the BOT's game? [Default: with servers]"
    echo -en "${GREEN}[User]:${NC} "
    read -r game
fi
{
  echo "{"
  echo "  \"prefix\": \"$prefix\","
  echo "  \"status\": \"$status\","
  echo "  \"game\": \"$game\""
  echo "}"
} > config.json

echo -e "${CYAN}[Bastion]:${NC} System Initialized. O7"
echo -e "${CYAN}[Bastion]:${NC} Ready to boot up and start running."
echo
