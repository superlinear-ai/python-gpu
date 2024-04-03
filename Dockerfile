# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.8
FROM python:$PYTHON_VERSION-slim

# Install wget.
RUN apt-get update && \
    apt-get install --yes wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Micromamba.
ARG TARGETARCH
RUN MICROMAMBA_ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "aarch64" || echo "64") && \
    wget --quiet "https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-linux-$MICROMAMBA_ARCH" --output-document /usr/local/bin/micromamba && \
    chmod +x /usr/local/bin/micromamba

# Install CUDA and cuDNN.
ARG CUDA_VERSION=11.8
ARG CUDNN_VERSION=8.9
RUN micromamba create --prefix /opt/cuda/ --channel conda-forge --yes cudatoolkit="$CUDA_VERSION" cudnn="$CUDNN_VERSION" && \
    micromamba clean --all --force-pkgs-dirs --yes
ENV LD_LIBRARY_PATH=/opt/cuda/lib:$LD_LIBRARY_PATH
