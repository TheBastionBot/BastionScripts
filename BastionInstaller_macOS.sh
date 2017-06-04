#!/bin/bash
set -e
reset

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'

if [ "$(id -u)" != "0" ]; then
  echo -e "${CYAN}[Bastion]: ${ORANGE}[ERROR] Bastion BOT Installer requires root permissions.${NC}"
  hash sudo &>/dev/null || (echo -e "${CYAN}[Bastion]: ${NC} Run this installer with root permissions.\n" && exit 1)
  sudo ./BastionInstaller_macOS.sh
  exit 1
fi

INS_DIR=/home/$SUDO_USER
cd "$INS_DIR"

echo "[ $(date) ]"
echo -e "${CYAN}[Bastion]:${NC} Bastion BOT Installer"
echo -e "${CYAN}[Bastion]:${NC} Starting Installer..."
echo

echo -e "${CYAN}[Bastion]:${NC} Initializing System..."
if [ -d "Bastion-Old" ]; then
  rm -rf Bastion-Old &> /dev/null
fi
if [ -d "Bastion" ]; then
  mv -f Bastion Bastion-Old &> /dev/null
fi

echo -e "${CYAN}[Bastion]:${NC} Installing XCode Command Line Tools..."
xcode-select --install || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download & install XCode Command Line Tools.${NC} Check your internet connection and try running this installer again." && exit 1)
echo -e "${CYAN}[Bastion]:${NC} Done."
echo
echo -e "${CYAN}[Bastion]:${NC} Installing Homebrew..."
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download & install XCode Command Line Tools.${NC} Check your internet connection and try running this installer again." && exit 1)
echo -e "${CYAN}[Bastion]:${NC} Done."
echo
echo -e "${CYAN}[Bastion]:${NC} Updating your system, this may take a while."
brew update || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to update system.${NC} Check your internet connection and try running this installer again." && exit 1)
echo

echo -e "${CYAN}[Bastion]:${NC} Verifying Git installation..."
if hash git &>/dev/null
then
  echo -e "${CYAN}[Bastion]:${NC} Git already installed. Looks good."
else
  echo -e "${CYAN}[Bastion]:${NC} Git not installed." && echo -e "${CYAN}[Bastion]:${NC} Installing Git..."
  brew install git &>/dev/null
  echo -e "${CYAN}[Bastion]:${NC} Done."
fi
echo

echo -e "${CYAN}[Bastion]:${NC} Verifying Node installation..."
if hash node &>/dev/null
then
  echo -e "${CYAN}[Bastion]:${NC} Node already installed. Looks good."
else
  echo -e "${CYAN}[Bastion]:${NC} Node not installed." && echo -e "${CYAN}[Bastion]:${NC} Installing Node..."
  brew install node &>/dev/null
  echo -e "${CYAN}[Bastion]:${NC} Done."
fi
echo

echo -e "${CYAN}[Bastion]:${NC} Verifying ffmpeg installation..."
if hash ffmpeg &>/dev/null
then
  echo -e "${CYAN}[Bastion]:${NC} ffmpeg already installed. Looks good."
else
  echo -e "${CYAN}[Bastion]:${NC} ffmpeg not installed." && echo -e "${CYAN}[Bastion]:${NC} Installing ffmpeg..."
  brew install ffmpeg &>/dev/null
  echo -e "${CYAN}[Bastion]:${NC} Done."
fi
echo

echo -e "${CYAN}[Bastion]:${NC} Installing system files..."
echo
(cd "$INS_DIR" && git clone -b master -q --depth 1 https://github.com/snkrsnkampa/Bastion.git) || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download Bastion system files.${NC}" && exit 1)
(cd "$INS_DIR" && cd Bastion && npm install --production 1>/dev/null 2>install.log) || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download and install Bastion system dependencies.${NC} Check your internet connection. If you get a ${RED}KILLED${NC} Error, you need to increase the SWAP of your Computer/Server. Please see the F.A.Q or contact Bastion Support. Please send the install.log log file while asking for support." && exit 1)
echo -e "${CYAN}[Bastion]:${NC} System files successfully installed."
echo

echo -e "${CYAN}[Bastion]:${NC} Finalizing..."
(
  cd "$INS_DIR" && cd Bastion && cd settings
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
    echo -e "${CYAN}[Bastion]:${NC} Please enter your Google API Key"
    echo -en "${GREEN}[User]:${NC} "
    read -r gAPIkey
    echo -e "${CYAN}[Bastion]:${NC} Please enter your Tracker Network Key"
    echo -en "${GREEN}[User]:${NC} "
    read -r TRNApiKey
    echo -e "${CYAN}[Bastion]:${NC} Please enter your Cleverbot API Key"
    echo -en "${GREEN}[User]:${NC} "
    read -r chatAPIkey
  fi
  {
    echo "{"
    echo "  \"botId\": \"$botId\","
    echo "  \"token\": \"$token\","
    echo "  \"ownerId\": ["
    echo "    \"$ownerId\""
    echo "  ],"
    echo "  \"googleAPIkey\": \"$gAPIkey\","
    echo "  \"TRNApiKey\": \"$TRNApiKey\","
    echo "  \"cleverbotAPIkey\": \"$chatAPIkey\""
    echo "}"
  } > credentials.json
  echo
  echo -e "${CYAN}[Bastion]:${NC} Do you want to configure BOT now?"
  echo -en "${GREEN}[User]:${NC} "
  read -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo -e "${CYAN}[Bastion]:${NC} What should be the commands' prefix?"
    echo -en "${GREEN}[User]:${NC} "
    read -r prefix
    echo -e "${CYAN}[Bastion]:${NC} What should be the BOT's status?"
    echo -e "${CYAN}[Bastion]:${NC} [online / idle / dnd / invisible]"
    echo -en "${GREEN}[User]:${NC} "
    read -r status
    echo -e "${CYAN}[Bastion]:${NC} What should be the BOT's game?"
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
)
(
  cd "$INS_DIR" && cd Bastion && cd data
  echo "[]" > favouriteSongs.json
)
echo

echo -e "${CYAN}[Bastion]:${NC} System Initialized. O7"
echo -e "${CYAN}[Bastion]:${NC} Ready to boot up and start running."
echo
