#!/usr/bin/env bash

BLACK='\033[30m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
RESET='\033[0m'
BOLD='\033[1m'

install_package() {
	command -v $1 >/dev/null 2>&1 && return 0 || printf "${BOLD}${CYAN}Installing $1...\n${RESET}"
	if command -v apt-get >/dev/null 2>&1; then
		sudo apt-get install -y $1 2>/dev/null
	elif command -v yum >/dev/null 2>&1; then
		sudo yum install -y $1 2>/dev/null
	elif command -v dnf >/dev/null 2>&1; then
		sudo dnf install -y $1 2>/dev/null
	elif command -v pacman >/dev/null 2>&1; then
		sudo pacman -Sy --noconfirm $1 2>/dev/null
	elif command -v zypper >/dev/null 2>&1; then
		sudo zypper install -y $1 2>/dev/null
	elif command -v brew >/dev/null 2>&1; then
		brew install $1 2>/dev/null
	else
		printf "${BOLD}${RED}Please install $1 manually.\n${RESET}" >&2
		return 1
	fi
	command -v $1 >/dev/null 2>&1
	return $?
}

manual_install() {
	PACKAGE_FILE="$1"
	if [[ -f /etc/os-release ]]; then
  		source /etc/os-release
  		DISTRO_ID=$ID

  		case "$DISTRO_ID" in
    		ubuntu|debian)
      			sudo dpkg -i "$PACKAGE_FILE";;
		    fedora|centos|rhel)
				sudo rpm -i "$PACKAGE_FILE";;
			arch)
				sudo pacman -U "$PACKAGE_FILE";;
			*)
				printf "${BOLD}${RED}Unsupported distribution: $DISTRO_ID\n${RESET}" >&2
				printf "${BOLD}${YELLOW}Please install manually.\n${RESET}"
				exit 1
				;;
		esac
	else
  		printf "${BOLD}${RED}Unknown OS. Cannot determine package manager.\n${RESET}" >&2
		exit 1
	fi
	[ $? -ne 0 ] && printf "${BOLD}${RED}Confirm system binary!!!\n${RESET}" >&2 && return 1
	return 0
}

get_python() {
	# Getting python
	if ! command -v python >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1;then
		printf "${RED}${BOLD}Python not installed\n${RESET}"
		printf "${BOLD}${YELLOW}Do you want to install python${RESET} [Y/n] "
		read -s -n 1 choice
		echo "$choice"
		if [ "$choice" = "Y" ] || [ "$choice" = "y" ];then
			install_package python3
			install_package python3-venv
			install_package python3-pip
			command -v python3 >/dev/null 2>&1
			[ $? -ne 0 ] && printf "${BOLD}${RED}Python not installed!!!\n${RESET}" >&2 && return 1
		else
			printf "${BOLD}${YELLOW}Cancelled!!!\n${RESET}"
			exit 0
		fi
	fi

	# Setting environment
	printf "${BOLD}${BLUE}Setting up environment...\n${RESET}"
	[ ! -e "./.App-env" ] && python3 -m venv .App-env || printf "${BOLD}${BLUE}Environment detected.\n${RESET}"
	source ./.App-env/bin/activate
	
	[ ! -e "./requirements.txt" ] && printf "${BOLD}${RED}Missing dependencies, get the 'requirements.txt' file on the current directory.\n${RESET}" >&2 && exit 1

	if pip3 show flask >/dev/null 2>&1; then
		# Check if all packages are installed
		for package in $(cat ./requirements.txt); do
			if pip3 show $package >/dev/null 2>&1; then
				printf "${BOLD}${BLUE}$package is installed\n${RESET}"
			else
				printf "${BOLD}${BLUE}Installing $package...\n${RESET}"
				pip3 install $package
			fi
		done
	else
		printf "${BOLD}${BLUE}Installing packages...\n${RESET}"
		pip3 install -r requirements.txt
	fi
	return 0
}

get_cloudflared() {
	URL="https://github.com/cloudflare/cloudflared/releases/download/2026.1.1/"
	if ! command -v cloudflared >/dev/null 2>&1; then
		install_package cloudflared
		[ $? -eq 0 ] && return 0 || printf "${BOLD}${YELLOW}Package unavailable, installing manually...\n${RESET}" 
		install_package wget
		install_package curl
		binaries=($(curl -s "https://github.com/cloudflare/cloudflared/releases/tag/2026.1.1" | grep -oE "cloudflared-(linux|fips|arm|amd)[0-9a-z\._-]{1,}" | sort | uniq))
		[ -z "$binaries" ] && printf "${BOLD}${RED}Error fetching available binaries!!!\n${RESET}" >&2 && return 1

		printf  "\n${BOLD}${YELLOW}Select your system binary...\n${RESET}"
		select binary in ${binaries[@]};do
			[ -z "$binary" ] && continue
			printf "\n${BOLD}${YELLOW}Downloading $binary...\n${RESET}"
			wget "$URL$binary"
			[ $? -ne 0 ] && printf "${BOLD}${RED}Error downloading cloudflared!!!\n${RESET}" >&2 && return 1
			manual_install $binary
			[ $? -ne 0 ] && return 1
			break
		done
	else
		printf "\n${BOLD}${YELLOW}Cloudflared detected.\n${RESET}"
	fi
	return 0
}

main() {
	get_python
	[ $? -ne 0 ] && printf "${BOLD}${RED}Operation unsuccessful!!!\n${RESET}" >&2 && exit 1

	get_cloudflared
	[ $? -ne 0 ] && printf "${BOLD}${RED}Operation unsuccessful!!!\n${RESET}" >&2 && exit 1

	printf "${BOLD}${GREEN}Configuration completed\n${RESET}"
	return 0
}

main
