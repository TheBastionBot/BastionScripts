#!/bin/bash
#
# Copyright 2018 The Bastion Bot Project.
# Licensed under the GNU General Public License, Version 3.0
# <https://www.gnu.org/licenses/gpl.txt>.
#
# This is just a little script that can be downloaded from the internet to
# install Bastion macOS with the Homebrew package manager. It installs Bastion
# and all the required dependencies and packages.

# Exit immediately if a pipeline, which may consist of a single simple command,
# a list, or a compound command returns a non-zero status
set -e
# Reinitialize the terminal
reset

# Set local variables for coloring output
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'

# Set local variables for use in script
BASTION_DIR="$HOME/Bastion"
BASTION_SETTINGS_DIR="$BASTION_DIR/settings"
BASTION_REPO="https://github.com/TheBastionBot/Bastion.git"

# Function to print message from Bastion
# Params:
#   $@ The message string
function print::bastion() {
  echo -e "${CYAN}[Bastion]: ${NC}$@${NC}"
}

# Function to print warning (to STDERR)
# Params:
#   $@ The warning string
function print::warning() {
  echo -e "${ORANGE}[WARNING]: $@${NC}" >&2
}

# Function to print error (to STDERR) & link to Bastion HQ and exit the script
# Params:
#   $@ The error string
function print::error() {
  echo
  echo -e "${RED}[ERROR]: $@${NC}" >&2
  echo
  echo "Join Bastion HQ and ask for help!"
  echo -e "${CYAN}https://discord.gg/fzx8fkt${NC}"
  echo "And our amazing support staff will help you out."
  echo
  exit 1
}

# Function to print 'Done' after a step is complete
function print::done() {
  print::bastion "Done."
  echo
}

# Function to print the current date & time
function print::date() {
  echo "[ $(date) ]"
  echo
}

# Function to print a user prompt before taking input from the user
# Params:
#   $@ The hint string for the input
function prompt::user() {
  echo
  print::bastion $@
  echo -en "${GREEN}[$USER]: ${NC}"
}

# Function to check if the script was run with superuser permission, warn the
# user about it and ask them if they like to proceed
function check_sudo() {
  if [ "$(id -u)" -eq "0" -a -n "$SUDO_USER" -a "$SUDO_USER" != "root" ]; then
    print::warning "The installer doesn't require superuser permission."
    echo

    print::bastion "Are you sure you want to install Bastion with superuser permission?"
    print::bastion "Proceed if and only if you know what you are doing."

    prompt::user "[Yes/NO]"
    read -n 1 -r
    echo -e "\n"
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      INS_DIR=/root
    else
      print::bastion  "Run this installer again without superuser permission."
      exit 1
    fi
  fi
}

# Function to install any given package(s) from the package manager
# Params:
#   $@ The list of package names
function install::package() {
  if ! hash $@ &>/dev/null; then
    brew install $@ || \
      print::error "Unable to download and install $@."
  fi
}

# Function to install system packages required by Bastion
# List of packages:
#   1. XCode Command Line Tools
#   2. Homebrew
#   3. screen
#   4. python
#   5. git
function install::packages() {
  print::bastion "Installing required system packages..."

  sudo xcode-select --install || \
    print::warning "Unable to download & install XCode Command Line Tools. Maybe it's already installed?"

  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" || \
    print::error "Unable to download & install Homebrew."

  brew update -qq || print::error "Unable to update Homebrew."

  install::package "screen"
  install::package "python"
  install::package "git"

  print::done
}

# Function to install Node.js or check if the right version is installed
function install::nodejs() {
  print::bastion "Installing Node.js..."

  if ! hash node &>/dev/null; then
    brew install "node@10" || \
      print::error "Unable to download and install Node.js."
  fi

  if [ "$(node --version | cut -d'v' -f 2 | cut -d'.' -f 1)" -ne 10 ]; then
    print::error "Please upgrade Node.js LTS before running the installer again."
  fi

  print::done
}

# Function to relocate previous installation of Bastion and clone the latest
# stable version from GitHub
function install::bastion() {
  print::bastion "Installing Bastion..."

  cd "$HOME"

  if [ -d "Bastion" ]; then
    if [ -d "Bastion-Old" ]; then sudo rm -rf Bastion-Old; fi
    sudo mv -f Bastion Bastion-Old
  fi

  git clone -b stable -q --depth 1 "$BASTION_REPO" || \
    print::error "Unable to download Bastion system files."

  print::done
}

# Function to install all the dependencies of Bastion
function bastion::dependencies() {
  print::bastion "Installing Bastion dependencies..."

  install::package "ffmpeg"

  sudo npm install --global yarn 1>/dev/null || \
    print::error "Unable to download and install Yarn."

  cd "$BASTION_DIR"
  yarn install --production --no-lockfile 1>/dev/null || \
    print::error "Unable to download and install node modules."

  print::done
}

# Function to generate the configuration & credentials file of Bastion
function bastion::configure() {
  print::bastion "Finalizing..."

  cp "$BASTION_SETTINGS_DIR/configurations.example.yaml" "$BASTION_SETTINGS_DIR/configurations.yaml"
  cp "$BASTION_SETTINGS_DIR/credentials.example.yaml" "$BASTION_SETTINGS_DIR/credentials.yaml"

  print::done
}

# Function to print that Bastion was successfully installed
function bastion::ready {
  print::bastion "Ready to boot up and start running."
  echo
  print::bastion "Join Bastion HQ: https://discord.gg/fzx8fkt"
  echo
}

function main() {
  print::date

  # Check if user is running the script using `sudo`.
  check_sudo

  # Install required system packages
  install::packages

  # Install Node.js
  install::nodejs

  # Clone Bastion from GitHub
  install::bastion

  # Install Bastion dependencies
  bastion::dependencies
  # Configure Bastion settings
  bastion::configure

  # Successfully installed
  bastion::ready

  echo
}


main

exit 0

# EOF
