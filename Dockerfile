# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.8
FROM python:$PYTHON_VERSION-slim AS base

ARG CUDA_VERSION=11.8
ARG CUDNN_VERSION=8.9.4.25
ARG TENSORRT_VERSION=8.6.1.6

# Install wget.
RUN apt-get update && \
    apt-get install --yes wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda.
RUN CONDA_ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "aarch64" || echo "x86_64") && \
    wget --quiet "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$CONDA_ARCH.sh" --output-document ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda
ENV PATH=/opt/conda/bin:$PATH

# Install CUDA.
RUN conda install --channel nvidia --yes cuda-runtime="$CUDA_VERSION"

# Cuda version compatible with tensorRT version
RUN if [ "$CUDA_VERSION" = "12.2" ]; then \
        CUDA_TENSORRT_VESION=12.0; \
    else \
        CUDA_TENSORRT_VESION=$CUDA_VERSION; \
    fi

# Install cuDNN and TensorRT.
RUN wget --quiet https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    rm cuda-keyring_1.1-1_all.deb && \
    apt-get update && \
    apt-get install --yes \
        libcudnn8=$CUDNN_VERSION-1+cuda$CUDA_VERSION \
        libnvinfer-lean8=$TENSORRT_VERSION-1+cuda$CUDA_TENSORRT_VESION && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

