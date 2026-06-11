# moonbit

It doesn't seem to play well with muslc. So only providing one image based on debian for use as devcontainer.

A container to develop moonbit programs. Can be used as dev container.

Bind 22 to a port on the host and directly ssh into the container with password.
Set the ssh port and password at runtime.

docker run --rm -it \
   -e DEV_PASSWORD=newpass \
   -v $HOME/ubuntu:/home/moondev \
   -p 1022:22 \ 
   sundernarayanaswamy/moonbit-lang:0.1.20260608

  
Connect via ssh

ssh moondev@205.147.200.117 -p 1022

Check the tags against the moonbit versions. Latest is v0.10.0.
