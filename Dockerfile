FROM pitop/onnxruntime-builder-buster:latest

RUN [ "cross-build-start" ]

# Prepare onnxruntime Repo
WORKDIR /

RUN git clone \
  --depth 1 \
  --single-branch \
  --branch $(curl --silent "https://api.github.com/repos/Microsoft/onnxruntime/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') \
  --recursive \
  "https://github.com/Microsoft/onnxruntime" \
  onnxruntime

# Build ORT including the shared lib and python bindings
WORKDIR /onnxruntime
RUN ./build.sh \
    --use_openmp \
    --config MinSizeRel \
    # 32-bit ARM - currently only supported via cross-compiling; not compatible with NuGet
    --arm \
    --update --build --build_shared_lib --build_wheel \
    --parallel

RUN [ "cross-build-end" ]
