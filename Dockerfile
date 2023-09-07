# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.8
ARG CUDA_VERSION=11.8
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
RUN conda install --channel nvidia --yes cuda="$CUDA_VERSION"
