[![Open in Docker Hub](https://img.shields.io/static/v1?label=Docker%20Hub&message=Open&color=blue&logo=dockerhub)](https://hub.docker.com/r/radixai/python-gpu)

# Python GPU

A minimal CUDA and cuDNN install on top of the official `python:3.x-slim` base image.

## 🎁 Features

- ✅ Starts from the official `python:3.x-slim` base image
- 🐍 Adds a single `micromamba` executable to install CUDA and cuDNN
- 🧬 Matrix build for Python {3.8, 3.9, 3.10, 3.11}, CUDA {11.8}, and cuDNN {8.9}
- 📦 Multi-platform build for `linux/amd64` and `linux/arm64`
- 🐭 Image size is only 1.8GB

## ✨ Using

A matrix of tags are available that follow the format `radixai/python-gpu:$PYTHON_VERSION-cuda$CUDA_VERSION`, see the [Docker Hub repository](https://hub.docker.com/r/radixai/python-gpu/tags) for a full list.

### Running the image

```sh
docker run -it --rm radixai/python-gpu:3.11-cuda11.8 /bin/bash
```

### Extending the image

```Dockerfile
FROM radixai/python-gpu:3.11-cuda11.8

...
```
