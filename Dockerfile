FROM ubuntu:26.04

RUN apt update \
    && apt install -y curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/ubuntu

USER ubuntu

RUN curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash 

CMD ["/bin/bash"]
