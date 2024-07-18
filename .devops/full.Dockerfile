ARG UBUNTU_VERSION=22.04
ARG CUDA_VERSION=11.7.1
ARG BASE_CUDA_DEV_CONTAINER=nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION}

FROM ${BASE_CUDA_DEV_CONTAINER} as build

ARG CUDA_DOCKER_ARCH=all

RUN apt-get update && \
    apt-get install -y build-essential python3 python3-pip git libcurl4-openssl-dev libgomp1

COPY requirements.txt requirements.txt
COPY requirements requirements

RUN pip install --upgrade pip setuptools wheel \
    && pip install -r requirements.txt

WORKDIR /app

COPY . .

ENV CUDA_DOCKER_ARCH=${CUDA_DOCKER_ARCH}
ENV GGML_CUDA=1
ENV LLAMA_CURL=1

RUN make -j$(nproc) llama-server

FROM ${BASE_CUDA_DEV_CONTAINER}

RUN apt-get update && \
    apt-get install -y libcurl4-openssl-dev libgomp1

COPY --from=build /app/llama-server /app/llama-server

ENTRYPOINT ["/app/llama-server"]
