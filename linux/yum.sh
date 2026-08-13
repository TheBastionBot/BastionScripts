#!/bin/bash
#
# MIT License
# Copyright (c) 2018-2026 TRACTION
#
# This is just a little script that can be downloaded from the internet to
# install Bastion on a linux based operating system with the yum package
# manager. It installs Bastion and all the required dependencies and packages.

# Exit immediately if a pipeline, which may consist of a single simple command,
# a list, or a compound command returns a non-zero status
set -e
# Reinitialize the terminal, if attached to one
if [ -t 2 ]; then reset || true; fi

# Set local variables for coloring output
NC='\033[0m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'

# Set local variables for use in script
BASTION_DIR="$HOME/Bastion"
BASTION_REPO="https://github.com/TheBastionBot/Bastion.git"
NODE_MIN="22.19.0"

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

# Function to install any given package(s) from the package manager
# Params:
#   $@ The list of package names
function install::package() {
  if ! hash $@ &>/dev/null; then
    sudo yum -y -q install $@ || \
      print::error "Unable to download and install $@."
  fi
}

# Function to install any given package group from the package manager
# Params:
#   $@ The list of package group name
function install::package_group() {
  sudo yum -y -q groupinstall "$@" || \
    print::error "Unable to download and install $@."
}

# Function to install system packages required by Bastion
# List of packages:
#   1. curl
#   2. wget
#   3. screen
#   4. python3
#   5. git
#   6. unzip
#   7. Development Tools
function install::packages() {
  print::bastion "Installing required system packages..."

  install::package "curl"
  install::package "wget"
  install::package "screen"
  install::package "python3"
  install::package "git"
  install::package "unzip"
  install::package_group "Development Tools"

  print::done
}

# Function to install Node.js or check if the right version is installed
function install::nodejs() {
  print::bastion "Installing Node.js..."

  # fnm's installer picks one of these, depending on the machine
  export PATH="$HOME/.fnm:${XDG_DATA_HOME:-$HOME/.local/share}/fnm:$PATH"

  # Install fnm, if it's not already installed
  if ! hash fnm &>/dev/null; then
    curl -fsSL https://fnm.vercel.app/install | bash || \
      print::warning "fnm was not installed cleanly. If Node.js is missing from new terminals, hook fnm into your shell profile yourself."
    hash fnm &>/dev/null || print::error "Unable to download and install fnm."
  fi

  FNM_ENV="$(fnm env --shell bash)" || \
    print::error "Unable to set up the fnm environment."
  eval "$FNM_ENV"

  fnm install --lts || print::error "Unable to download and install Node.js."
  fnm use lts-latest || print::error "Unable to switch to the installed Node.js version."
  fnm default lts-latest || print::error "Unable to set the default Node.js version."

  NODE_VERSION="$(node --version 2>/dev/null | tr -d 'v')"
  if [ -z "$NODE_VERSION" ]; then
    print::error "Node.js was not installed correctly."
  fi
  if [ "$(printf '%s\n%s\n' "$NODE_MIN" "$NODE_VERSION" | sort -V | head -1)" != "$NODE_MIN" ]; then
    print::error "Bastion needs Node.js $NODE_MIN or later, but found v$NODE_VERSION."
  fi

  print::done
}

# Function to relocate previous installation of Bastion and clone the latest
# stable version from GitHub
function install::bastion() {
  print::bastion "Installing Bastion..."

  cd "$HOME"

  if [ -d "Bastion" ]; then
    if [ -d "Bastion-Old" ]; then
      rm -rf Bastion-Old || \
        print::error "Unable to remove the previous backup at $HOME/Bastion-Old."
    fi
    mv -f Bastion Bastion-Old || \
      print::error "Unable to back up your existing installation at $HOME/Bastion."
  fi

  git clone -b main -q --depth 1 "$BASTION_REPO" || \
    print::error "Unable to download Bastion system files."

  print::done
}

# Function to install all the dependencies of Bastion
function bastion::dependencies() {
  print::bastion "Installing Bastion dependencies..."

  install::package "ffmpeg"

  cd "$BASTION_DIR"
  npm install --no-package-lock 1>/dev/null || \
    print::error "Unable to download and install node modules."

  npm run build || \
    print::error "Unable to build Bastion system files."

  print::done
}

# Function to generate the configuration & credentials file of Bastion
function bastion::configure() {
  print::bastion "Finalizing..."

  cp "$BASTION_DIR/settings.example.yaml" "$BASTION_DIR/settings.yaml"

  print::done
}

# Function to print that Bastion was successfully installed
function bastion::ready {
  print::bastion "Ready to boot up and start running."
  echo
  print::bastion "Node.js is managed by fnm, so open a new terminal first."
  echo
  print::bastion "Join Bastion HQ: https://discord.gg/fzx8fkt"
  echo
}

function main() {
  print::date

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
