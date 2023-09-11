# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.8
FROM python:$PYTHON_VERSION-slim-bullseye

# Install wget.
RUN apt-get update && \
    apt-get install --yes wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda.
RUN CONDA_ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "aarch64" || echo "x86_64") && \
    wget --quiet "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$CONDA_ARCH.sh" --output-document ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh
ENV PATH=/opt/conda/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/conda/lib:$LD_LIBRARY_PATH

# Install CUDA and cuDNN.
ARG CUDA_VERSION=11.8
ARG CUDNN_VERSION=8.8
RUN conda install --name base --yes conda-libmamba-solver && \
    conda config --set solver libmamba && \
    conda install --name base --channel conda-forge --yes cudatoolkit="$CUDA_VERSION" cudnn="$CUDNN_VERSION" && \
    conda clean --all --force-pkgs-dirs --yes
