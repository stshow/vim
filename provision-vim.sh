#!/bin/bash
## This is a script to quickly provision Vim config from hobo.house.
## Original post: https://hobo.house/2016/04/09/trick-out-your-vim-editor/
## Vim GTK is important for keyboard copy paste on Ubuntu / Debian distros.

#if [ -f /usr/bin/apt ]; then
#    sudo apt install git vim vim-gtk -y
#elif [ -f /usr/bin/dnf ]; then
#    sudo install git vim-enhanced
#else
#    echo "Looks like you aren't running Ubuntu/Debian/Fedora"
#fi

BACKUP_STATUS=False
BACKUPFILE=vim-backup-$(hostname -s)-$(date +%s%z).tar.gz
DIR=/tmp/vimbackup-$(date +%s)

sleep 2
backup(){
    if [ -d ~/.vim ] && [ -f ~/.vimrc ]; then
        mkdir ${DIR}
        mv ~/.vim ${DIR}/vim
        mv ~/.vimrc ${DIR}/vimrc
        cd ${DIR}
        tar cvzf /tmp/${BACKUPFILE} ${DIR}/* &> /tmp/vim-backup-$(date +%R%p).log
        echo -en '\nBacking up your current configs...\n\n'
        echo  "Check here: /tmp/${BACKUPFILE}"
        BACKUP_STATUS=True
    elif [ ! -d ~/.vim ] && [ -f ~/.vimrc ]; then
        mkdir ${DIR}
        mv ~/.vimrc ${DIR}/vimrc
        cd ${DIR}
        tar cvzf /tmp/${BACKUPFILE} ${DIR}/* &> /tmp/vim-backup-$(date +%R%p).log
        echo -en '\nBacking up your current configs...\n'
        BACKUP_STATUS=True
    else
	    echo -en '\nNothing to backup...'
	    echo -en '\nSleeping for 10 seconds...press CTRL+C to close\n\n'
	    sleep 10
    fi	 
}

provision(){
    if [ ! -d ${DIR} ]; then
	mkdir ${DIR}
    fi
    cd ~
    wget https://github.com/sadsfae/misc-dotfiles/raw/master/vimfiles.tar
    tar -xvf vimfiles.tar &> ${DIR}/vim-deploy-$(date +%s).log
    sed -i 's/set textwidth=80/set textwidth=0/g' ~/.vimrc
    echo -en '\nRun the following inside of VIM to finish:\n\n:PlugClean\n:PlugInstall\n:PlugUpdate\n'
    echo -en '\nSetting your default editor to VIM\n'
    git config --global core.editor /usr/bin/vim
    echo "export EDITOR=vim" >> ~/.bashrc
}

backup
provision

if [ $BACKUP_STATUS = "True" ]; then
    echo "Remember your backups are here: /tmp/${BACKUPFILE}"
else
    echo -en '\nNo backup taken.\n'
fi 
