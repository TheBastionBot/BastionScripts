#!/bin/sh
set -e

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'

cd ~
reset

echo "-------------------------------"
echo "     Bastion BOT Installer"
echo "-------------------------------"
echo ""

echo -e "${CYAN}[Bastion]:${NC} Initializing System..."
echo ""

echo -e "${CYAN}[Bastion]:${NC} Verifying Git installation..."
if hash git 1>/dev/null 2>&1
then
    echo -e "${CYAN}[Bastion]:${NC} Git already installed. Looks good."
else
    echo -e "${CYAN}[Bastion]:${NC} Git not installed." && echo -e "${CYAN}[Bastion]:${NC} Installing Git..."
    if hash apt-get 1>/dev/null 2>&1
    then apt-get install -y git &> /dev/null && echo -e "${CYAN}[Bastion]:${NC} Done \o/" || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install Git.${NC} Before running this installer, try installing git by typing: sudo apt-get install git" && exit 1)
    elif hash yum 1>/dev/null 2>&1
    then yum install -y git &> /dev/null && echo -e "${CYAN}[Bastion]:${NC} Done \o/" || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install Git.${NC} Before running this installer, try installing git by typing: sudo yum install git" && exit 1)
    else echo -e "${CYAN}[Bastion]: ${ORANGE}[WARNING] Your package manager is currently not supported.${NC} Contact the Bastion BOT team in the help server (https://discord.gg/fzx8fkt) for guide with manual installation." && exit 1
    fi
    echo -e "${CYAN}[Bastion]:${NC} Done \o/"
fi
echo ""

echo -e "${CYAN}[Bastion]:${NC} Verifying Node installation..."
if hash node 1>/dev/null 2>&1
then
    echo -e "${CYAN}[Bastion]:${NC} Node already installed. Looks good."
else
    echo -e "${CYAN}[Bastion]:${NC} Node not installed." && echo -e "${CYAN}[Bastion]:${NC} Installing Node..."
    if hash apt-get 1>/dev/null 2>&1
    then
        curl -sL https://deb.nodesource.com/setup_7.x -o nodesource_setup.sh || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download Node.${NC} Check your internet connection." && exit 1)
        chmod +x nodesource_setup.sh && ./nodesource_setup.sh 1>/dev/null && apt-get install -y nodejs 1>/dev/null || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install Node.${NC} Before running this installer, try installing node manually." && exit 1)
    elif hash yum 1>/dev/null 2>&1
    then
        wget https://nodejs.org/download/release/v7.4.0/node-v7.4.0.tar.gz || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download Node.${NC} Check your internet connection." && exit 1)
        tar xvf node-v7.4.0.tar.gz && cd node-v7.4.0 && yum install gcc gcc-c++ && ./configure && make && make install || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install Node.${NC} Before running this installer, try installing node manually." && exit 1)
    else echo -e "${CYAN}[Bastion]: ${ORANGE}[WARNING] Your package manager is currently not supported.${NC} Contact the Bastion BOT team in the help server (https://discord.gg/fzx8fkt) for guide with manual installation." && exit 1
    fi
    echo -e "${CYAN}[Bastion]:${NC} Done \o/"
fi
echo ""

echo -e "${CYAN}[Bastion]:${NC} Installing system files..."
echo ""
cd ~ && git clone -b master -q --depth 1 https://github.com/snkrsnkampa/Bastion.git || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download Bastion system files.${NC}" && exit 1)
cd Bastion && npm install || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download and install Bastion system dependencies.${NC} Check your internet connection." && exit 1)
echo -e "${CYAN}[Bastion]:${NC} System files successfully installed."
echo ""

echo -e "${CYAN}[Bastion]:${NC} Finalizing..."
cd settings && cp config_example.json config.json && cp credentials_example.json credentials.json && echo -e "${CYAN}[Bastion]:${NC} Done."
echo ""

echo -e "${CYAN}[Bastion]:${NC} System Initialized. O7"
echo -e "${CYAN}[Bastion]:${NC} Ready to boot up and start running."
echo ""
