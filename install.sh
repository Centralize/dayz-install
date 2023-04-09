#!/bin/bash

# Function to check if the script is run as root
check_root() {
  if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Exiting..."
    exit 1
  fi
}

# Function to check Ubuntu distribution version
get_ubuntu_version() {
  lsb_release -r | awk '{print $2}'
}

# Function to install SteamCMD
install_steamcmd() {
  echo "Installing SteamCMD..."
  STEAMCMD_DIR="/opt/steamcmd"
  STEAMCMD_URL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
  mkdir -p "$STEAMCMD_DIR"
  curl -sSL "$STEAMCMD_URL" | tar -xzC "$STEAMCMD_DIR"
  # Add SteamCMD to PATH
  echo 'export PATH="/opt/steamcmd:$PATH"' >> /etc/profile.d/steamcmd.sh
  source /etc/profile.d/steamcmd.sh
}

# Function to install LinuxGSM
install_linuxgsm() {
  echo "Installing LinuxGSM..."
  curl -sSL https://linuxgsm.sh | sudo bash
}

# Parse command line parameters
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --steamcmd)
      INSTALL_STEAMCMD=true
      shift
      ;;
    --linuxgsm)
      INSTALL_LINUXGSM=true
      shift
      ;;
    --all)
      INSTALL_STEAMCMD=true
      INSTALL_LINUXGSM=true
      shift
      ;;
    *)
      echo "Invalid parameter: $1"
      echo "Usage: ./install.sh [--steamcmd] [--linuxgsm] [--all]"
      exit 1
      ;;
  esac
done

# If no parameters are provided, show help screen
if [ "$#" -eq 0 ]; then
  echo "Usage: ./install.sh [--steamcmd] [--linuxgsm] [--all]"
  exit 1
fi

# Check root privilege
check_root

# Install dependencies
apt update
UBUNTU_VERSION=$(get_ubuntu_version)

if [[ "$INSTALL_STEAMCMD" == "true" || "$INSTALL_LINUXGSM" == "true" || "$INSTALL_ALL" == "true" ]]; then
  if [[ "$UBUNTU_VERSION" == "20.04" || "$UBUNTU_VERSION" == "20.10" || "$UBUNTU_VERSION" == "21.04" || "$UBUNTU_VERSION" == "21.10" || "$UBUNTU_VERSION" == "22.04" ]]; then
    apt install -y curl lib32gcc-s1
  else
    apt install -y curl lib32gcc1
  fi
fi

# Install SteamCMD if selected
if [ "$INSTALL_STEAMCMD" == "true" ] || [ "$INSTALL_ALL" == "true" ]; then
  install_steamcmd
fi

# Install LinuxGSM if selected
if [ "$INSTALL_LINUXGSM" == "true" ] || [ "$INSTALL_ALL" == "true" ]; then
  install_linuxgsm
fi

# Print Ubuntu version and installation success message
if [ "$INSTALL_STEAMCMD" == "true" ] || [ "$INSTALL_LINUXGSM" == "true" ] || [ "$INSTALL_ALL" == "true" ]; then
  echo
