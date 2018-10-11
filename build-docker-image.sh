#!/bin/bash

# builds a docker image for the user

# e.g. "jonathan" 
username=$1

# TODO: check that user exists

uid=$(id --user $username)
gid=$(id --group $username)

tmpdir=$(mktemp -d)
cat template.sudoers_container_root.txt | sed -e 's/$username/'$username'/' > $tmpdir/sudoers_container_root
cat template.Dockerfile | sed -e 's/$username/'$username'/' -e 's/$uid/'$uid'/' -e 's/$gid/'$gid'/' > $tmpdir/Dockerfile

(
    cd $tmpdir
    
    docker build $DOCKER_BUILD_OPTS -f Dockerfile -t $username .
    
    # NOTE: we don't need to upload this image to docker registry, we can just rebuild it on any node that needs a user container 
)

rm -rf $tmpdir
