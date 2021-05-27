# Adapted from https://github.com/microsoft/onnxruntime/blob/master/dockerfiles/Dockerfile.arm32v7
FROM balenalib/raspberrypi3-python:3.7-buster

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

# Install wheel2deb and dependencies
RUN install_packages \
    python3-apt \
    apt-file \
    dpkg-dev \
    fakeroot \
    build-essential \
    devscripts \
    debhelper \
    && python3 -m pip install wheel2deb

# Install wheel2deb dpkg-shlibdeps requirements
RUN install_packages \
    libc6 \
    libgcc-6-dev \
    libgomp1 \
    libstdc++6

# Prepare file look-up
RUN sudo apt-file update

# Add piwheels support (pre-compiled binary Python packages for RPi)
COPY files/pip.conf /etc

# Carefully install the latest version of pip
WORKDIR /pip
RUN wget https://bootstrap.pypa.io/get-pip.py \
    && python3 get-pip.py \
    && pip3 install --upgrade setuptools \
    && pip3 install --upgrade wheel \
    && pip3 install numpy==1.16.2 \
    && pip3 install flake8

# Build the latest cmake
WORKDIR /
RUN wget https://github.com/Kitware/CMake/releases/download/v3.18.3/cmake-3.18.3.tar.gz \
    && tar zxf cmake-3.18.3.tar.gz \
    && rm cmake-3.18.3.tar.gz \
    && cd /cmake-3.18.3 \
    && ./configure --system-curl \
    && make -j$(nproc) \
    && sudo make install \
    && cd / \
    && rm -rf /cmake-3.18.3
