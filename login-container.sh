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

container_id=$(docker ps --quiet --filter label=$label_prefix.user=$user)
if [ -z "$container_id" ]; then
    docker run \
        --volume /home/$user/workspace:/home/$user/workspace \
        --workdir /home/$user \
        --label $label_prefix.user=$user \
        --restart always \
        --name ${user}_container \
        --user $uid:$gid \
        --interactive \
        --tty \
        --detach \
        --init \
        $user bash
    container_id=$(docker ps --quiet --filter label=$label_prefix.user=$user)
    container_ipaddr=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container_id)
    
    # Custom firewall rules etc. can be setup here for the new container
    
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
