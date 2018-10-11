#!/bin/bash

# creates a linux user with public key ssh access (run this on the remote host)

# e.g. "jonathan" 
username=$1

# TODO: check if the username already exists

useradd --create-home $username 

(
    cd /home/$username
    mkdir .ssh
    chmod 700 .ssh
    touch .ssh/authorized_keys
    chmod 600 .ssh/authorized_keys
    chown -R $username:$username .ssh
)

# grant user access to start the login container
cat template.sudoers_host_user.txt | sed -e 's/$username/'$username'/' > /etc/sudoers.d/$username
