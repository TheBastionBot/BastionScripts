#!/bin/sh
set -e

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
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
    apt-get install -y git &> /dev/null && echo -e "${CYAN}[Bastion]:${NC} Done \o/" || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install Git.${NC} Before running this installer, try installing git by typing: sudo apt-get install git" && exit 1)
    echo -e "${CYAN}[Bastion]:${NC} Done \o/"
fi
echo ""

echo -e "${CYAN}[Bastion]:${NC} Verifying Node installation..."
if hash node 1>/dev/null 2>&1
then
    echo -e "${CYAN}[Bastion]:${NC} Node already installed. Looks good."
else
    echo -e "${CYAN}[Bastion]:${NC} Node not installed." && echo -e "${CYAN}[Bastion]:${NC} Installing Node..."
		curl -sL https://deb.nodesource.com/setup_7.x -o nodesource_setup.sh || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download Node.${NC} Check your internet connection." && exit 1)
		chmod +x nodesource_setup.sh && ./nodesource_setup.sh 1>/dev/null && apt-get install -y nodejs 1>/dev/null && echo -e "${CYAN}[Bastion]:${NC} Done \o/" || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install Node.${NC} Before running this installer, try installing node manually" && exit 1)
fi
echo ""

echo -e "${CYAN}[Bastion]:${NC} Installing System..."
echo ""
cd ~ && git clone -b master -q --depth 1 https://github.com/snkrsnkampa/Bastion.git || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download Bastion system files.${NC}" && exit 1)
cd Bastion && npm install || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install Bastion system dependencies.${NC} Check your internet connection." && exit 1)
echo -e "${CYAN}[Bastion]:${NC} System Installed."
echo ""

echo -e "${CYAN}[Bastion]:${NC} Finalizing..."
cd settings && cp config_example.json config.json && cp credentials_example.json credentials.json && echo -e "${CYAN}[Bastion]:${NC} Done."
echo ""

echo -e "${CYAN}[Bastion]:${NC} System Initialized. O7"
echo -e "${CYAN}[Bastion]:${NC} %{GREEN}Ready to boot up and start running."
echo ""