FROM ubuntu:18.04
RUN groupadd --gid $gid $username
RUN useradd --create-home --uid $uid --gid $gid --shell /bin/bash $username
RUN apt-get update
RUN apt-get install -y sudo
COPY sudoers_container_root /etc/sudoers.d/$username
RUN apt-get install -y curl rsync vim
CMD ["/bin/bash"]
