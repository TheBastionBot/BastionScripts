# Copyright 2018 The Bastion Bot Project.
# Licensed under the GNU General Public License, Version 3.0
# <https://www.gnu.org/licenses/gpl.txt>.
#
# This is just a little script that can be downloaded from the internet to
# install Bastion on Windows operating systems with the chocolatey package
# manager. It installs Bastion and all the required dependencies and packages.

# Function to test if the script is running with administrative privileges
function Administrator-Test {
    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $CurrentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# Check whether the installer has administrative privileges.
# If not, run it as administrator.
if ((Administrator-Test) -eq $False) {
    # Not running with elevated perms, so let's run it as administrator.
    PowerShell -NoProfile -ExecutionPolicy Unrestricted -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -NoExit -ExecutionPolicy Unrestricted -File "$MyInvocation.MyCommand.Definition"' -Verb RunAs}";
    # We need to exit it otherwise the rest of the script will keep on running.
    Exit 0
}

# Set local variables for use in script
$BASTION_DIR="$HOME/Bastion"
$BASTION_SETTINGS_DIR="$BASTION_DIR/settings"
$BASTION_REPO="https://github.com/TheBastionBot/Bastion.git"

# Function to print message from Bastion
# Params:
#   $1 The message string
Function Print::Bastion($1) {
  $NC = $host.ui.RawUI.ForegroundColor
  $host.ui.RawUI.ForegroundColor = "Cyan"

  Write-Host "[Bastion]: " -NoNewline

  $host.ui.RawUI.ForegroundColor = $NC

  Write-Host "$1"
}

# Function to print warning
# Params:
#   $1 The warning string
Function Print::Warning($1) {
  $NC = $host.ui.RawUI.ForegroundColor
  $host.ui.RawUI.ForegroundColor = "DarkYellow"

  Write-Host "[WARNING]: " -NoNewline

  $host.ui.RawUI.ForegroundColor = $NC

  Write-Host "$1"
}

# Function to print error & link to Bastion HQ and exit the script
# Params:
#   $1 The error string
Function Print::Error($1) {
  $NC = $host.ui.RawUI.ForegroundColor
  $host.ui.RawUI.ForegroundColor = "Red"

  Write-Host "[ERROR]: " -NoNewline

  $host.ui.RawUI.ForegroundColor = $NC

  Write-Host "$1"

  Write-Host
  Write-Host "Join Bastion HQ and ask for help!"

  $host.ui.RawUI.ForegroundColor = "Cyan"

  Write-Host "https://discord.gg/fzx8fkt"

  $host.ui.RawUI.ForegroundColor = $NC

  Write-Host "And our amazing support staff will help you out."
  Write-Host

  Exit 1
}

# Function to print 'Done' after a step is complete
Function Print::Done() {
  Print::Bastion "Done."
  Write-Host
}

# Function to print the current date & time
Function Print::Date() {
  Write-Host "[ $(Get-Date -Format F) ]"
  Write-Host
}

# Function to print a user prompt before taking input from the user
# Params:
#   $1 The hint string for the input
Function Print::User($1) {
  Write-Host
  Print::Bastion "$1"

  $NC = $host.ui.RawUI.ForegroundColor
  $host.ui.RawUI.ForegroundColor = "Green"

  Write-Host "[$env:UserName]: " -NoNewline

  $host.ui.RawUI.ForegroundColor = $NC
}

# Function to install any given package(s) from the package manager
# Params:
#   $1 The list of package names
Function Install::Package($1) {
  choco install $1 -y
  If (-Not ($?)) {
    Print::Error "Unable to download and install $1."
  }
  refreshenv
}

# Function to install system packages required by Bastion
# List of packages:
#   1. Chocolatey
#   2. NodeJS
#   3. Git
#   4. Visual Studio Build Tools
#   5. Python 2.x
Function Install::Packages() {
  Print::Bastion "Installing required system packages..."

  Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  If (-Not ($?)) {
    Print::Error "Unable to download and install Chocolatey."
  }

  # Install Node.js
  Install::NodeJS

  Install::Package "git"

  npm i -g windows-build-tools

  Install::Package "python2"

  Print::Done
}

# Function to install Node.js
# TODO: Check if the right version is installed
Function Install::NodeJS() {
  Print::Bastion "Installing Node.js..."

  Install::Package "nodejs-lts"

  npm config set msvs_version 2017
  npm config set python python2.7

  Print::Done
}

# Function to relocate previous installation of Bastion and clone the latest
# stable version from GitHub
Function Install::Bastion() {
  Print::Bastion "Installing Bastion..."

  cd "$ENV:UserProfile"

  If (Test-Path "Bastion") {
    If (Test-Path "Bastion-Old") {
      Remove-Item .\Bastion-Old -Force -Recurse
    }
    Move-Item -Path .\Bastion -Destination .\Bastion-Old -Force
  }

  git clone -b stable -q --depth 1 "$BASTION_REPO"
  If (-Not ($?)) {
    Print::Error "Unable to download Bastion system files."
  }

  Print::Done
}

# Function to install all the dependencies of Bastion
Function Bastion::Dependencies() {
  Print::Bastion "Installing Bastion dependencies..."

  Install::Package "ffmpeg"

  npm install --global yarn
  If (-Not ($?)) {
    Print::error "Unable to download and install Yarn."
  }

  cd "$BASTION_DIR"
  yarn install --production --no-lockfile
  If (-Not ($?)) {
    Print::Error "Unable to download and install node modules."
  }

  Print::Done
}

# Function to generate the configuration & credentials file of Bastion
Function Bastion::Configure() {
  Print::Bastion "Finalizing..."

  Copy-Item "$BASTION_SETTINGS_DIR\configurations.example.yaml" "$BASTION_SETTINGS_DIR\configurations.yaml"
  Copy-Item "$BASTION_SETTINGS_DIR\credentials.example.yaml" "$BASTION_SETTINGS_DIR\credentials.yaml"

  Print::Done
}

# Function to print that Bastion was successfully installed
Function Bastion::Ready {
  Print::Bastion "Ready to boot up and start running."
  Write-Host
  Print::Bastion "Join Bastion HQ: https://discord.gg/fzx8fkt"
  Write-Host
}

Function Main() {
  Print::Date

  # Install required system packages
  Install::Packages

  # Clone Bastion from GitHub
  Install::Bastion

  # Install Bastion dependencies
  Bastion::Dependencies
  # Configure Bastion settings
  Bastion::Configure

  # Successfully installed
  Bastion::Ready

  Write-Host
}


Main

Exit 0

# EOF
