# Stage 1: Build yamlfmt
FROM golang:1 AS go-builder
# defined from build kit
# DOCKER_BUILDKIT=1 docker build . -t ...
ARG TARGETARCH

# Install yamlfmt
WORKDIR /yamlfmt
RUN go install github.com/google/yamlfmt/cmd/yamlfmt@latest && \
    strip $(which yamlfmt) && \
    yamlfmt --version

FROM rust:1-slim AS builder
ARG TARGETARCH
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get install -y -q --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    clang \
    curl \
    git \
    gnupg2 \
    libclang-dev \
    libssl-dev \
    libudev-dev \
    linux-headers-${TARGETARCH} \
    llvm \
    openssl \
    pkg-config \
    protobuf-compiler \
    python3 \
    && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV USER=solana
RUN useradd --create-home -s /bin/bash ${USER} && \
    usermod -a -G sudo ${USER} && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    chown -R ${USER}:${USER} /home/${USER}

USER solana

WORKDIR /build
RUN chown -R ${USER}:${USER} /build

ENV PATH=${PATH}:/home/solana/.cargo/bin
RUN echo ${PATH} && cargo --version

# Solana
ARG SOLANA_VERSION=1.18.22
RUN git clone --depth 1 --branch v${SOLANA_VERSION} https://github.com/solana-labs/solana.git && \
    cd solana && ./scripts/cargo-install-all.sh /home/solana/.local/share/solana/install/releases/${SOLANA_VERSION}
RUN for file in /home/solana/.local/share/solana/install/releases/${SOLANA_VERSION}/bin/*; do strip ${file}; done
ENV PATH=$/build/bin:$PATH

FROM debian:stable-slim

RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get install -y -q --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    libssl-dev \
    openssl \
    pkg-config \
    procps \
    protobuf-compiler \
    python3 \
    python3-pip \
    ripgrep \
    sudo \
    && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV USER=solana
RUN useradd --create-home -s /bin/bash ${USER} && \
    usermod -a -G sudo ${USER} && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    chown -R ${USER}:${USER} /home/${USER}

ARG SOLANA_VERSION=1.18.22
COPY --chown=${USER}:${USER} --from=go-builder /go/bin/yamlfmt /go/bin/yamlfmt
COPY --chown=${USER}:${USER} --from=builder /usr/local/cargo /usr/local/cargo
COPY --chown=${USER}:${USER} --from=builder /usr/local/rustup /usr/local/rustup
COPY --chown=${USER}:${USER} --from=builder /home/solana/.local/share/solana/install/releases/${SOLANA_VERSION} /home/solana/.local/share/solana/install/releases/${SOLANA_VERSION}
ENV PATH=${PATH}:/usr/local/cargo/bin:/go/bin:/home/solana/.local/share/solana/install/releases/${SOLANA_VERSION}/bin
WORKDIR /home/solana

USER solana
ENV CARGO_HOME=/usr/local/cargo
ENV RUSTUP_HOME=/usr/local/rustup
RUN rustup default stable

LABEL \
    org.opencontainers.image.title="solana" \
    org.opencontainers.image.description="Solana Development Container for Visual Studio Code" \
    org.opencontainers.image.url="https://github.com/anagrambuild/solana" \
    org.opencontainers.image.source="https://github.com/anagrambuild/solana.git" \
    org.opencontainers.image.vendor="anagram.xyz" \
    org.opencontainers.image.version=${SOLANA_VERSION} \
    org.opencontainers.image.created=$(date --rfc-3339=seconds) \
    org.opencontainers.image.licenses="GNU-Affero" \
    org.opencontainers.image.authors="Anagram Build <build@anagram.xyz>"
