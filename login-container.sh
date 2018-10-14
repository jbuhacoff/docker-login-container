#!/bin/bash

if [ -n "$SUDO_COMMAND" ]; then
        user=$SUDO_USER
        uid=$SUDO_UID
        gid=$SUDO_GID
else
        user=$(whoami)
        uid=$(id --user)
        gid=$(id --group)
fi

label_prefix=local
container_name=
image=ubuntu:18.04

while [ $# -gt 0 ]
do
    case $1 in
        --)
            shift;
            break;
            ;;
        --image)
            image=$2
            shift; shift;
            ;;
        --name)
            container_name=$2
            shift; shift;
            ;;
        *)
            echo "Invalid arguments" >&2
            exit 1
            ;;
    esac
done

if [ -n "$container_name" ]; then
    # find the named container 
    container_id=$(docker ps --quiet --filter name=$container_name)
    label=$label_prefix.name=$container_name
else
    # find a default container for this user by name
    container_id=$(docker ps --quiet --filter label=$label_prefix.user=$user)
    label=$label_prefix.user=$user
    container_name=${user}_container
fi

if [ -z "$container_id" ]; then
    docker run \
        --volume /home/$user/workspace:/home/$user/workspace \
        --workdir /home/$user \
        --label $label \
        --restart always \
        --name $container_name \
        --user $uid:$gid \
        --interactive \
        --tty \
        --detach \
        --init \
        $image bash
    container_id=$(docker ps --quiet --filter label=$label)
    container_ipaddr=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container_id)
    
    # Custom firewall rules etc. can be setup here for the new container
    
fi

if [ -z "$container_id" ]; then
    echo "Failed to start container" >&2
    exit 1
fi

# login with no parameters should enter an interactive shell
if [ $# -eq 0 ]; then
        docker exec -it $container_id /bin/bash
else
        # rsync --server requires an interactive shell and no tty
        if [[ "$@" =~ "rsync --server "* ]]; then
                docker exec -i $container_id "$@"
        else
                docker exec -t $container_id "$@"
        fi
fi
