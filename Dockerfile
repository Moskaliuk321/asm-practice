FROM ubuntu:22.04
RUN apt-get update && apt-get install -y nasm gcc make && rm -rf /var/lib/apt/lists/*
WORKDIR /asm
CMD ["/bin/bash"]
