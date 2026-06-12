FROM debian:sid

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    sudo \
    curl ca-certificates \
    git unzip \
    locales \
    && sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# install moonbit and bun and move the binaries to a persistent location that is not HOME

RUN mkdir /moonbin
RUN curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash 
RUN curl -fsSL https://bun.sh/install | bash
RUN mv /root/.bun /moonbin && mv /root/.moon /moonbin

ARG DEV_USER=moondev
ENV DEV_USER=${DEV_USER}
ENV DEV_PASSWORD=changeme
 
RUN getent group 1000 || groupadd -g 1000 ${DEV_USER} && \
    getent passwd 1000 || useradd -m -s /bin/bash -u 1000 -g 1000 ${DEV_USER} && \
    usermod -aG sudo ${DEV_USER} && \
    echo "${DEV_USER}:${DEV_PASSWORD}" | chpasswd && \
    echo "${DEV_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir -p /run/sshd && ssh-keygen -A

RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
 
RUN chown -R 1000:1000 /moonbin 
ENV PATH=/moonbin/.bun/bin:/moonbin/.moon/bin:$PATH

# Make environment variables available when loggin in via ssh and for other shells

RUN echo "MOONBIT_NEW_NATIVE=1" >> /etc/environment && \
    echo "MOON_HOME=/home/${DEV_USER}/.moon" >> /etc/environment && \
    echo "BUN_INSTALL_CACHE_DIR=/home/${DEV_USER}/.bun" >> /etc/environment && \
    echo "LANG=en_US.UTF-8" >> /etc/environment && \
    echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "PATH=${PATH}" >> /etc/environment

RUN cat > /usr/local/bin/node << 'EOF'
#!/bin/bash
exec bun "$@"
EOF

RUN cat > /usr/local/bin/npm << 'EOF'
#!/bin/bash
if [[ "$1" == "install" || "$1" == "i" ]]; then
    exec bun install "${@:2}"
else
    exec bun "$@"
fi
EOF

RUN cat > /usr/local/bin/npx << 'EOF'
#!/bin/bash
exec bunx "$@"
EOF

# Make them executable
RUN chmod +x /usr/local/bin/node \
    /usr/local/bin/npm \
    /usr/local/bin/npx

EXPOSE 22

USER ${DEV_USER}
WORKDIR /home/${DEV_USER}

# Make environment variables available when running/attaching a container

ENV MOONBIT_NEW_NATIVE=1
ENV MOON_HOME=/home/${DEV_USER}/.moon
ENV BUN_INSTALL_CACHE_DIR=/home/${DEV_USER}/.bun
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

CMD ["/bin/bash", "-c", "echo ${DEV_USER}:${DEV_PASSWORD} | sudo chpasswd > /dev/null 2>&1 && sudo /usr/sbin/sshd > /dev/null 2>&1 && exec /bin/bash"]
