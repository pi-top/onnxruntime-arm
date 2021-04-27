# Adapted from https://github.com/microsoft/onnxruntime/blob/master/dockerfiles/Dockerfile.arm32v7
FROM balenalib/rpi-raspbian:buster

ARG ONNXRUNTIME_REPO_ID="Microsoft/onnxruntime"

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
    libatlas-base-dev \
    mono-complete

# Carefully install the latest version of pip 
WORKDIR /pip
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python3 get-pip.py
RUN pip3 install --upgrade setuptools
RUN pip3 install --upgrade wheel
RUN pip3 install numpy
RUN pip3 install flake8

# Build the latest cmake
WORKDIR /code
RUN wget https://github.com/Kitware/CMake/releases/download/v3.18.3/cmake-3.18.3.tar.gz
RUN tar zxf cmake-3.18.3.tar.gz 

WORKDIR /code/cmake-3.18.3
RUN ./configure --system-curl
RUN make -j$(nproc)
RUN sudo make install

# Prepare onnxruntime Repo
WORKDIR /code
RUN git clone \
  --depth 1 \
  --single-branch \
  --branch $(curl --silent "https://api.github.com/repos/${ONNXRUNTIME_REPO_ID}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') \
  --recursive \
  "https://github.com/${ONNXRUNTIME_REPO_ID}" \
  onnxruntime

# Build ORT including the shared lib and python bindings
WORKDIR /code/onnxruntime
RUN ./build.sh \
    --use_openmp \
    --config MinSizeRel \
    # 32-bit ARM - currently only supported via cross-compiling; not compatible with NuGet
    --arm \
    --update \
    --parallel \
    --build --build_shared_lib --build_wheel

RUN [ "cross-build-end" ]
