#!/bin/bash
set -e
reset

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'

INS_DIR=/home/$USER

if [ "$(id -u)" = "0" ]; then
  echo -e "${CYAN}[Bastion]: ${ORANGE}[WARNING] Bastion Bot Installer doesn't require root permissions.${NC}"
  echo -e "${CYAN}[Bastion]: ${NC} You should run this installer without root permissions."

  echo -e "${CYAN}[Bastion]:${NC} Are you sure you want to install Bastion as root? Proceed if and only if you know what you are doing."
  echo -en "${GREEN}[User]:${NC} (y/N) "
  read -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    INS_DIR=/root
  else
    echo -e "${CYAN}[Bastion]:${NC} Run this installer again without root permission." && exit 0
  fi
fi

cd "$INS_DIR"

echo "[ $(date) ]"
echo -e "${CYAN}[Bastion]:${NC} Bastion BOT Installer"
echo -e "${CYAN}[Bastion]:${NC} Starting Installer..."
echo

echo -e "${CYAN}[Bastion]:${NC} Initializing System..."
if [ -d "Bastion-Old" ]; then
  sudo rm -rf Bastion-Old &> /dev/null
fi
if [ -d "Bastion" ]; then
  sudo mv -f Bastion Bastion-Old &> /dev/null
fi

echo -e "${CYAN}[Bastion]:${NC} Updating your system and installing some dependencies, this may take a while."
if hash apt-get &>/dev/null
then
  sudo apt-get update &>/dev/null || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to update system.${NC} Check your internet connection and try running this installer again." && exit 1)
  sudo apt-get install -y build-essential &>/dev/null || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install build-essential.${NC} Before running this installer, try installing build-essential by typing: sudo apt-get install build-essential" && exit 1)
  sudo apt-get install -y wget curl screen python &>/dev/null
elif hash yum &>/dev/null
then
  sudo yum update --exclude=kernel* &>/dev/null || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to update system.${NC} Check your internet connection and try running this installer again." && exit 1)
  sudo yum -y groupinstall "Development Tools" &>/dev/null || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install Development Tools.${NC} Before running this installer, try installing Development Tools by typing: sudo yum groupinstall \"Development Tools\"" && exit 1)
  sudo yum -y install wget curl screen python &>/dev/null
elif hash dnf &>/dev/null
then
  sudo dnf update &>/dev/null || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to update system.${NC} Check your internet connection and try running this installer again." && exit 1)
  sudo dnf -y groupinstall "Development Tools" &>/dev/null || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install Development Tools.${NC} Before running this installer, try installing Development Tools by typing: sudo dnf groupinstall \"Development Tools\"" && exit 1)
  sudo dnf -y install wget curl screen python &>/dev/null
else echo -e "${CYAN}[Bastion]: ${ORANGE}[WARNING] Your package manager is currently not supported (by this installer).${NC} Ask for help with manual installation in Bastion BOT Official Server (https://discord.gg/fzx8fkt)." && exit 1
fi
echo

echo -e "${CYAN}[Bastion]:${NC} Verifying Git installation..."
if hash git &>/dev/null
then
  echo -e "${CYAN}[Bastion]:${NC} Git already installed. Looks good."
else
  echo -e "${CYAN}[Bastion]:${NC} Git not installed." && echo -e "${CYAN}[Bastion]:${NC} Installing Git..."
  if hash apt-get &>/dev/null
  then sudo apt-get install -y git &>/dev/null || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install Git.${NC} Before running this installer, try installing git by typing: sudo apt-get install git" && exit 1)
  elif hash yum &>/dev/null
  then sudo yum -y install git &>/dev/null || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install Git.${NC} Before running this installer, try installing git by typing: sudo yum install git" && exit 1)
  elif hash dnf &>/dev/null
  then sudo dnf -y install git &>/dev/null || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install Git.${NC} Before running this installer, try installing git by typing: sudo dnf install git" && exit 1)
  else echo -e "${CYAN}[Bastion]: ${ORANGE}[WARNING] Your package manager is currently not supported (by this installer).${NC} Ask for help with manual installation in Bastion BOT Official Server (https://discord.gg/fzx8fkt)." && exit 1
  fi
  echo -e "${CYAN}[Bastion]:${NC} Done \o/"
fi
echo

echo -e "${CYAN}[Bastion]:${NC} Verifying Node installation..."
if hash node && [ "$(node --version | cut -d'v' -f 2 | cut -d'.' -f 1)" -ge 7 ]
then
  echo -e "${CYAN}[Bastion]:${NC} Node already installed. Looks good."
else
  echo -e "${CYAN}[Bastion]:${NC} Node not installed." && echo -e "${CYAN}[Bastion]:${NC} Installing Node..."
  if hash dpkg &>/dev/null && ( hash apt &>/dev/null || hash aptitude &>/dev/null )
  then
    (curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -) &>/dev/null || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download Node.${NC} Check your internet connection." && exit 1)
    sudo apt-get install -y nodejs &>/dev/null || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install Node.${NC} Before running this installer, try installing node by typing: sudo apt-get install nodejs" && exit 1)
  elif hash yum &>/dev/null || hash dnf &>/dev/null
  then
    (curl -sL https://rpm.nodesource.com/setup_8.x | sudo -E bash -) &>/dev/null || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download Node.${NC} Check your internet connection." && exit 1)
    sudo yum -y install nodejs &>/dev/null || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to install Node.${NC} Before running this installer, try installing node by typing: sudo yum install nodejs" && exit 1)
  else echo -e "${CYAN}[Bastion]: ${ORANGE}[WARNING] Your package manager is currently not supported (by this installer).${NC} Ask for help with manual installation in Bastion BOT Official Server (https://discord.gg/fzx8fkt)." && exit 1
  fi
  echo -e "${CYAN}[Bastion]:${NC} Done \o/"
fi
echo

echo -e "${CYAN}[Bastion]:${NC} Verifying ffmpeg installation..."
if hash ffmpeg &>/dev/null
then
  echo -e "${CYAN}[Bastion]:${NC} ffmpeg already installed. Looks good."
else
  echo -e "${CYAN}[Bastion]:${NC} ffmpeg not installed." && echo -e "${CYAN}[Bastion]:${NC} Installing ffmpeg..."
  sudo npm i -g ffmpeg-binaries &>/dev/null  || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download and install ffmpeg.${NC} Check your internet connection. If you get a ${RED}KILLED${NC} Error, you need to increase the SWAP of your Computer/Server. Please see the F.A.Q or contact Bastion Support." && exit 1)
fi
echo

echo -e "${CYAN}[Bastion]:${NC} Installing system files..."
echo
(cd "$INS_DIR" && git clone -b master -q --depth 1 https://github.com/TheBastionBot/Bastion.git) || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download Bastion system files.${NC}" && exit 1)
(cd "$INS_DIR" && cd Bastion && npm i --only=production --no-package-lock 1>/dev/null 2>install.log) || (echo -e "${CYAN}[Bastion]: ${RED}[ERROR] Unable to download and install Bastion system dependencies.${NC} Check your internet connection. If you get a ${RED}KILLED${NC} Error, you need to increase the SWAP of your Computer/Server. Please see the F.A.Q or contact Bastion Support. Please send the install.log log file while asking for support." && exit 1)
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
    echo -e "${CYAN}[Bastion]:${NC} Please enter your GitHub Personal Access Token"
    echo -en "${GREEN}[User]:${NC} "
    read -r githubAccessToken
    echo -e "${CYAN}[Bastion]:${NC} Please enter your Patreon Creator Access Token"
    echo -en "${GREEN}[User]:${NC} "
    read -r patreonCreatorAccessToken
    echo -e "${CYAN}[Bastion]:${NC} Please enter your Twitch API Client ID"
    echo -en "${GREEN}[User]:${NC} "
    read -r twitchClientID
    echo -e "${CYAN}[Bastion]:${NC} Please enter your Twitch API Client Secret"
    echo -en "${GREEN}[User]:${NC} "
    read -r twitchClientSecret
    echo -e "${CYAN}[Bastion]:${NC} Please enter your PUBG Tracker Network API Key"
    echo -en "${GREEN}[User]:${NC} "
    read -r PUBGAPIKey
    echo -e "${CYAN}[Bastion]:${NC} Please enter your Bungie API Key"
    echo -en "${GREEN}[User]:${NC} "
    read -r bungieAPIKey
    echo -e "${CYAN}[Bastion]:${NC} Please enter your Fortnite Tracker API Key"
    echo -en "${GREEN}[User]:${NC} "
    read -r fortniteAPIKey
    echo -e "${CYAN}[Bastion]:${NC} Please enter your Battlefield Tracker Network API Key"
    echo -en "${GREEN}[User]:${NC} "
    read -r battlefieldAPIKey
    echo -e "${CYAN}[Bastion]:${NC} Please enter your HiRez API DevID"
    echo -en "${GREEN}[User]:${NC} "
    read -r HiRezDevId
    echo -e "${CYAN}[Bastion]:${NC} Please enter your HiRez API AuthKey"
    echo -en "${GREEN}[User]:${NC} "
    read -r HiRezAuthKey
    echo -e "${CYAN}[Bastion]:${NC} Please enter your The Movie Database API Key"
    echo -en "${GREEN}[User]:${NC} "
    read -r theMovieDBApiKey
    echo -e "${CYAN}[Bastion]:${NC} Please enter your Musixmatch API Key"
    echo -en "${GREEN}[User]:${NC} "
    read -r musixmatchAPIKey
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
    echo "  \"webhooks\": {"
    echo "    \"bastionLog\": \"\""
    echo "  },"
    echo "  \"googleAPIkey\": \"$gAPIkey\","
    echo "  \"twitchClientID\": \"$twitchClientID\","
    echo "  \"twitchClientSecret\": \"$twitchClientSecret\","
    echo "  \"bungieAPIKey\": \"$bungieAPIKey\","
    echo "  \"PUBGAPIKey\": \"$PUBGAPIKey\","
    echo "  \"battlefieldAPIKey\": \"$battlefieldAPIKey\","
    echo "  \"fortniteAPIKey\": \"$fortniteAPIKey\","
    echo "  \"HiRezDevId\": \"$HiRezDevId\","
    echo "  \"HiRezAuthKey\": \"$HiRezAuthKey\","
    echo "  \"theMovieDBApiKey\": \"$theMovieDBApiKey\","
    echo "  \"musixmatchAPIKey\": \"$musixmatchAPIKey\","
    echo "  \"cleverbotAPIkey\": \"$chatAPIkey\","
    echo "  \"github\": {"
    echo "    \"accessToken\": \"$githubAccessToken\""
    echo "  },"
    echo "  \"patreon\": {"
    echo "    \"clientID\": \"\","
    echo "    \"clientSecret\": \"\","
    echo "    \"creatorAccessToken\": \"$patreonCreatorAccessToken\","
    echo "    \"creatorRefreshToken\": \"\""
    echo "  }"
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
    echo -e "${CYAN}[Bastion]:${NC} What should be the BOT's activity?"
    echo -e "${CYAN}[Bastion]:${NC} [Playing / Watching / Listening]"
    echo -en "${GREEN}[User]:${NC} "
    read -r activity
    echo -e "${CYAN}[Bastion]:${NC} What should be the BOT be $activity?"
    echo -en "${GREEN}[User]:${NC} "
    read -r game
  fi
  {
    echo "{"
    echo "  \"shardCount\": 1,"
    echo "  \"prefix\": \"$prefix\","
    echo "  \"status\": \"$status\","
    echo "  \"game\": {"
    echo "    \"type\": \"$activity\","
    echo "    \"name\": \"$game\""
    echo "  },"
    echo "  \"music\": {"
    echo "    \"status\": false,"
    echo "    \"passes\": 1"
    echo "  }"
    echo "}"
  } > config.json
)
echo -e "${CYAN}[Bastion]:${NC} Done."
echo

echo -e "${CYAN}[Bastion]:${NC} System Initialized. O7"
echo -e "${CYAN}[Bastion]:${NC} Ready to boot up and start running."
echo
