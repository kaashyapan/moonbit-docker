FROM ubuntu:26.04

RUN apt update \
    && apt install -y curl sudo unzip ca-certificates 

WORKDIR /home/ubuntu

USER ubuntu

RUN curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash 

ENV MOONBIT_NEW_NATIVE=1

RUN curl -fsSL https://bun.sh/install | bash

RUN export PATH=$PATH:/home/ubuntu/.bun:/home/ubuntu/.moon

USER root

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

USER ubuntu

CMD ["/bin/bash"]
