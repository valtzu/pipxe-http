FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y -o Acquire::Retries=50 \
            python3 \
            python3-pycryptodome \
            xxd \
            binutils \
            build-essential \
            g++ \
            gcc \
            gcc-aarch64-linux-gnu \
            gcc-x86-64-linux-gnu \
            git-core \
            iasl \
            make \
            perl \
            python-is-python3 \
            liblzma-dev \
            lzma-dev \
            uuid-dev \
            zip \
            wget
RUN wget https://ftp.gnu.org/gnu/mtools/mtools_4.0.38_amd64.deb
RUN dpkg -i mtools_4.0.38_amd64.deb
RUN ln -sf /bin/bash /bin/sh
