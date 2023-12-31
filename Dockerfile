FROM ubuntu:22.04

MAINTAINER toconnor <toconnor@my.fit.edu>
LABEL contributor="chake <chake2019@my.fit.edu>"

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
ENV LANG en_US.UTF-8

# apt-get installs
RUN apt-get update -y -qq
RUN apt-get install -y -qq \
    g++ \
    gcc \
    gcc-multilib \
    gdb \
    gdb-multiarch \
    git \
    locales \
    make \
    man \
    nano \
    nasm \
    pkg-config \
    tmux \
    wget \
    python3-pip \
    ruby-dev 

RUN pip3 install --upgrade pip

RUN python3 -m pip install --no-cache-dir \
    autopep8 \
    capstone \
    colorama \
    cython \
    keystone-engine \
    pefile \
    pwntools \
    qiling \
    r2pipe \
    ropgadget \
    ropper \
    sudo \
    unicorn \
    z3-solver 

# install angr after dependencies met
RUN pip3 install angr angrop

# install angrop from source -- fixes "rop" import error 
RUN cd /opt/ && git clone https://github.com/angr/angrop && \
    cd angrop && pip3 install .

# install pwninit for patching bins for ctfs     
RUN wget -O /bin/pwninit https://github.com/io12/pwninit/releases/download/3.3.0/pwninit && \
    chmod +x /bin/pwninit 

# install pwndbg
RUN cd /opt/ && git clone https://github.com/pwndbg/pwndbg && \
  cd pwndbg && \
  ./setup.sh

# install one_gadget
RUN gem install one_gadget seccomp-tools && rm -rf /var/lib/gems/2.*/cache/*

# install radare
RUN wget https://github.com/radareorg/radare2/releases/download/5.8.8/radare2_5.8.8_amd64.deb && \
    dpkg -i radare2_5.8.8_amd64.deb && rm radare2_5.8.8_amd64.deb

# install zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.2/zsh-in-docker.sh)" -- \
    -t crunch

# install stuff for patching binaries with libc
RUN apt-get update -qq -y && apt-get install -qq -y patchelf elfutils

WORKDIR /
 
# enable core dumping
RUN ulimit -c unlimited

RUN echo "flag{fake-flag}" > /flag.txt

# copy over libc.so.6 and ld-2.27
COPY libc/libc.so.6 /opt/libc.so.6 
COPY libc/ld-2.27.so /opt/ld-2.27.so

COPY exploit.py /exploit.py

CMD ["python3", "exploit.py"]

