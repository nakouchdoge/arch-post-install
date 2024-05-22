#!/bin/bash

DIR="$(dirname "$0")"

. "$DIR"/functions/base.sh

function pacmanUpdate {
	if ask_yes_no "${purple}:: Update & upgrade system?: ${cr}"; then
		sudo pacman -Syu
		echo "${green}System updated.${cr}"
	else
		skipping
	fi
}

function installDocker {
	if ask_yes_no "${purple}:: Install docker? ${cr}"; then
		echo "${purple}Installing docker engine${cr}"
		sudo pacman -S docker docker-compose
		echo "${green}Docker successfully installed.${cr}"
		sudo usermod -aG docker $USER
		echo "${green}$USER added to group 'docker'${cr}"
	else
		skipping
	fi
}

function installPackages {
	if ask_yes_no "${purple}:: Install packages? ${cr}"; then
		if ask_yes_no "${purple}:: Install default packages? (neovim htop ncdu qemu-guest-agent git wget gcc make fzf ufw bat openssh-server)? ${cr}"; then
			sudo pacman -S neovim htop ncdu qemu-guest-agent git wget gcc make fzf ufw bat openssh-server
			echo "${green}Default packages successfully installed.${cr}"
			if ask_yes_no "${purple}:: Install more packages? ${cr}"; then
				read -p "${purple}Type the packages you would like to install (separated by a single space): ${cr}" packages_to_install
				sudo pacman -S $packages_to_install
				success
			else
				:
			fi
		else
			read -p "${purple}Type the packages you would like to install (separated by a single space): ${cr}" packages_to_install
			sudo pacman -S $packages_to_install
			success
		fi
	else
		skipping
	fi
}

function detectPackagesInstalled {
	detectOpenSsh
	detectDocker
	detectNeoVim
}	

function detectOpenSsh {
	if [ -f "/usr/sbin/sshd" ]; then 
		if ask_yes_no "${purple}:: OpenSSH installation detected, start now? ${cr}"; then
			sudo systemctl start ssh.service
			success
		else
			skipping
		fi
	else
		:
	fi
}
#
# Docker Detection
#
function detectDocker {
	if [ -f "/usr/bin/docker" ]; then 
		if ask_yes_no "${purple}:: Docker installation detected, enable now? ${cr}"; then
			sudo systemctl enable --now docker.service
			success
		else
			skipping
		fi
	else
		:
	fi
}
#
# NeoVIM Detection
#
function echoNeoVimAliases {
	echo "alias v='nvim'" >> /home/$USER/.bash_aliases
	echo "alias vi='nvim'" >> /home/$USER/.bash_aliases
	echo "alias vim='nvim'" >> /home/$USER/.bash_aliases
	echo "${green}~/.bash_aliases file modified.${cr}"
	if [ -f "/home/$USER/.bashrc" ] && grep -qF "source /home/$USER/.bash_aliases" "/home/$USER/.bashrc"; then
		echo "${green}~/.bashrc points to ~/.bash_aliases already, ~/.bashrc has not been modified.${cr}"
	else
		echo "source /home/$USER/.bash_aliases" >> /home/$USER/.bashrc
		echo "${green}~/.bashrc now points to ~/.bash_aliases, ~/.bashrc has been modified.${cr}"
	fi
}

function detectNeoVim {
	if [ -f "/usr/bin/nvim" ]; then
		if [ -f "/home/$USER/.bash_aliases" ] && grep -qF "source /home/$USER/.bash_aliases" "/home/$USER/.bashrc" && grep -qF "alias v='nvim'" "/home/$USER/.bash_aliases" && grep -qF "alias vi='nvim'" "/home/$USER/.bash_aliases" && grep -qF "alias vim='nvim'" "/home/$USER/.bash_aliases"; then
			:
		else
			if ask_yes_no "${purple}:: NeoVIM installation detected, do you want 'v', 'vi', and 'vim' commands to be aliased to the 'nvim' command? ${cr}"; then
				if [ -f "/home/$USER/.bash_aliases" ]; then
					echoNeoVimAliases
				else
					touch /home/$USER/.bash_aliases
					echoNeoVimAliases
				fi
			else
				skipping
			fi
		fi
	else
		:
	fi
}
#
