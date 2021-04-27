FROM pitop/onnxruntime-builder:latest

RUN [ "cross-build-start" ]

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
    --build_wheel

RUN [ "cross-build-end" ]
