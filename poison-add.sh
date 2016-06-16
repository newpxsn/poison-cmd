#!/bin/bash
# Script to add a user to *nix system
if [ $(id -u) -eq 0 ]; then
    read -p "Enter username : " username
    read -p "Enter domain : " domain
    read -s -p "Enter password : " password
    egrep "^$username" /etc/passwd >/dev/null
    if [ $? -eq 0 ]; then
        echo "$username exists!"
        exit 1
    else
        pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
        useradd -m -p $pass $username
        [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
        
         ## Create directory
        if [ ! -d /usr/share/nginx/domains/$domain ]
        then
            eval "mkdir /usr/share/nginx/domains/$domain"
            echo "User directory has been created!"
        fi

        ## Add to www-data
        eval "usermod -G www-data $username"

        ## Fix permissions
        eval "chown $username:www-data /usr/share/nginx/domains/$domain"
       
    fi
else
    echo "Only root may add a user to the system"
    exit 2
fi
