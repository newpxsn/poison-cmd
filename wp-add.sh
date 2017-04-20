#!/bin/bash
# Script to add a user to *nix system
if [ $(id -u) -eq 0 ]; then
    read -p "Enter username : " username
    read -s -p "Enter password : " password
    read -p "Enter domain : " domain
    read -p "Install WordPress? (Y/n) : " wordpress


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

        if [[ $wordpress =~ ^([yY][eE][sS]|[yY])$ ]]
        then
            echo "Creating the database ..."
                read -s -p "Enter MySQL root password : " mysqlroot
                read -p "Enter database name : " dbname
                read -s -p "Enter new database password : " mysqlpass

            echo "Installing WordPress..."
            eval "wget http://wordpress.org/latest.tar.gz"
            eval "tar xfz latest.tar.gz"
            eval "mv wordpress/* /usr/share/nginx/domains/$domain/"
            eval "rm -r wordpress"


            ##Create database
            mysql -uroot -p$mysqlroot -e "create database ${dbname}; CREATE USER '$username'@'localhost' identified by $mysqlpass; grant all privileges on $dbname.* to $username@localhost; flush privileges;"
            
            ##Yep

        fi


    esac

        ## Add to www-data
        eval "usermod -G www-data $username"

        ## Fix permissions
        eval "chown $username:www-data /usr/share/nginx/domains/$domain"
       
    fi
else
    echo "Only root may add a user to the system"
    exit 2
fi

##
# Give specific SFTP access to user.
#
# /etc/ssh/sshd_config
##

#Match User $1
#    ChrootDirectory /usr/share/nginx/public/domains/$3
#    PasswordAuthentication yes
#    X11Forwarding no
#    AllowTcpForwarding no
#    ForceCommand internal-sftp
