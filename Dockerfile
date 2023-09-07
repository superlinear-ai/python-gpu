# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.8
ARG CUDA_VERSION=11.8
ARG CUDNN_VERSION=8.9.4.25
ARG TENSORRT_VERSION=8.6.1.6
FROM python:$PYTHON_VERSION-slim AS base

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

# Install cuDNN and TensorRT.
RUN wget --quiet https://developer.download.nvidia.com/compute/cuda/repos/debian11/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    rm cuda-keyring_1.1-1_all.deb && \
    apt-get update && \
    apt-get install --yes \
        libcudnn8=$CUDNN_VERSION-1+cuda$CUDA_VERSION \
        libnvinfer-lean8=$TENSORRT_VERSION-1+cuda$CUDA_VERSION && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

