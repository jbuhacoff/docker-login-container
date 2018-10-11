# docker-login-container

Docker makes it easy to create and manage containers. This project describes a
way that you can use Docker to provide a customized login container for a user.

## Install the login-container script

As root:

    install -m 755 login-container.sh /usr/bin

## Create the Linux user

As root:

    bash create-linux-user.sh <username>

Other steps:

* disable password-based login for the user
* create a workspace directory for the user
* add the user's ssh public key with the login-container command as shown below 

The workspace directory will be mounted to the user's login container so they 
have a place to store data that should be kept even if the container is rebuilt.

    # create a workspace directory for user
    mkdir -p /home/$username/workspace
    chown $username:$username workspace

If you have a file with the user's SSH public key, you can read it into a
variable and then add it to the user's authorized_keys file as shown here:

    ssh_public_key=$(cat /path/to/ssh_publick_key)
    echo 'command="sudo /usr/local/bin/login-container.sh $SSH_ORIGINAL_COMMAND",no-port-forwarding' $ssh_public_key >> /home/$username/.ssh/authorized_keys


## Build the user image

The `template.Dockerfile` provides minimal instructions for an Ubuntu login 
container. You can adapt it with your own Dockerfile to build any image that 
you need for this.

As root:

    bash build-docker-image.sh <username>

## 