# syntax=docker/dockerfile:1
ARG DEBIAN_FRONTEND=noninteractive
ARG PYTHON_VERSION=3.8
FROM python:$PYTHON_VERSION-slim AS base

ARG CUDA=11.8
ARG NV_CUDA_CUDART_VERSION=11.8.89-1
ARG NV_CUDA_COMPAT_PACKAGE=cuda-compat-11-8
# CUDDN
ARG CUDNN_VERSION=8.6.0.163-1+cuda11.8
# TensorRT
ARG LIBINVER_VERSION=8.4.3-1+cuda11.6

# NVIDIA: https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.8.0/ubuntu2204/base/Dockerfile
# specify the version of the CUDA Toolkit to use and the which driver versions are compatible for each brand of GPU.

ENV NVARCH x86_64
ENV CUDA $CUDA
ENV CUDNN_VERSION $CUDNN_VERSION
ENV NV_CUDA_CUDART_VERSION $NV_CUDA_CUDART_VERSION
ENV NV_CUDA_COMPAT_PACKAGE $NV_CUDA_COMPAT_PACKAGE
ENV LIBINVER_VERSION $LIBINVER_VERSION
ENV NVIDIA_REQUIRE_CUDA "cuda>=$CUDA brand=tesla,driver>=450,driver<451 brand=tesla,driver>=470,driver<471 brand=unknown,driver>=470,driver<471 brand=nvidia,driver>=470,driver<471 brand=nvidiartx,driver>=470,driver<471 brand=geforce,driver>=470,driver<471 brand=geforcertx,driver>=470,driver<471 brand=quadro,driver>=470,driver<471 brand=quadrortx,driver>=470,driver<471 brand=titan,driver>=470,driver<471 brand=titanrtx,driver>=470,driver<471 brand=tesla,driver>=510,driver<511 brand=unknown,driver>=510,driver<511 brand=nvidia,driver>=510,driver<511 brand=nvidiartx,driver>=510,driver<511 brand=geforce,driver>=510,driver<511 brand=geforcertx,driver>=510,driver<511 brand=quadro,driver>=510,driver<511 brand=quadrortx,driver>=510,driver<511 brand=titan,driver>=510,driver<511 brand=titanrtx,driver>=510,driver<511 brand=tesla,driver>=515,driver<516 brand=unknown,driver>=515,driver<516 brand=nvidia,driver>=515,driver<516 brand=nvidiartx,driver>=515,driver<516 brand=geforce,driver>=515,driver<516 brand=geforcertx,driver>=515,driver<516 brand=quadro,driver>=515,driver<516 brand=quadrortx,driver>=515,driver<516 brand=titan,driver>=515,driver<516 brand=titanrtx,driver>=515,driver<516"

#  Updates the package index and installs the necessarys packages to add the CUDA repository, including `gnupg2`, `curl`, and `ca-certificates`. 
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSLO https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/${NVARCH}/cuda-keyring_1.0-1_all.deb && \
    dpkg -i cuda-keyring_1.0-1_all.deb && \
    apt-get purge --autoremove -y curl \
    && rm -rf /var/lib/apt/lists/*

# Install CUDA Toolkit, cuDNN SDK, optionally TensorRT
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-cudart-${CUDA%.*}-${CUDA#*.}=${NV_CUDA_CUDART_VERSION} \
        ${NV_CUDA_COMPAT_PACKAGE} \
        cuda-command-line-tools-${CUDA%.*}-${CUDA#*.} \
        libcublas-dev-${CUDA%.*}-${CUDA#*.} \
        cuda-nvcc-${CUDA%.*}-${CUDA#*.} \
        libcublas-${CUDA%.*}-${CUDA#*.} \
        cuda-cupti-${CUDA%.*}-${CUDA#*.} \
        cuda-nvrtc-${CUDA%.*}-${CUDA#*.} \
        cuda-nvprune-${CUDA%.*}-${CUDA#*.} \
        cuda-libraries-${CUDA%.*}-${CUDA#*.} \
        libcufft-${CUDA%.*}-${CUDA#*.} \
        libcurand-${CUDA%.*}-${CUDA#*.} \
        libcusolver-${CUDA%.*}-${CUDA#*.} \
        libcusparse-${CUDA%.*}-${CUDA#*.} \
        libtool \
        libcudnn8=${CUDNN_VERSION}\
        libnvinfer8=${LIBINVER_VERSION} \
        libnvinfer-plugin8=${LIBINVER_VERSION} \
        build-essential \
        pkg-config \
        software-properties-common \
        unzip && \       
    find /usr/local/cuda-${CUDA}/lib64/ -type f -name 'lib*_static.a' -not -name 'libcudart_static.a' -delete \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# # Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf \
    && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

# Sets environment variables that are required by the `nvidia-container-runtime` to expose all the NVIDIA devices and enable compute and utility capabilities 
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

# Adds the NVIDIA binary paths to the system's `PATH` environment variable.
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64