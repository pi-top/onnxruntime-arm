# Adapted from https://github.com/microsoft/onnxruntime/blob/master/dockerfiles/Dockerfile.arm32v7
FROM balenalib/raspberrypi3-python:3.7-stretch-build

# Add piwheels support (pre-compiled binary Python packages for RPi)
COPY files/pip.conf /etc

# Enforces cross-compilation through Qemu.
RUN [ "cross-build-start" ]

RUN install_packages \
    sudo \
    build-essential \
    curl \
    libcurl4-openssl-dev \
    libssl-dev \
    wget \
    python3 \
    python3-dev \
    git \
    tar \
    libatlas-base-dev

# Carefully install the latest version of pip
WORKDIR /pip
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python3 get-pip.py
RUN pip3 install --upgrade setuptools
RUN pip3 install --upgrade wheel
RUN pip3 install numpy==1.16.2
RUN pip3 install flake8

# Build the latest cmake
WORKDIR /
RUN wget https://github.com/Kitware/CMake/releases/download/v3.18.3/cmake-3.18.3.tar.gz
RUN tar zxf cmake-3.18.3.tar.gz && rm cmake-3.18.3.tar.gz

WORKDIR /cmake-3.18.3
RUN ./configure --system-curl
RUN make -j$(nproc)
RUN sudo make install

RUN rm -rf /cmake-3.18.3
