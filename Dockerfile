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

FROM rust:slim AS sol-builder
ARG TARGETARCH
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get install -y -q --no-install-recommends \
    build-essential \
    pkg-config \
    libudev-dev \
    llvm \
    libclang-dev \
    protobuf-compiler \
    curl \
    git \
    gnupg2 \
    python3 \
    && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV USER=solana
RUN useradd --create-home -s /bin/bash ${USER} && \
    usermod -a -G sudo ${USER} && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    chown -R ${USER}:${USER} /home/${USER}

WORKDIR /build
RUN chown -R ${USER}:${USER} /build

ENV PATH=${PATH}:/home/solana/.cargo/bin
RUN echo ${PATH} && cargo --version

ARG SOLANA_VERSION=2.0.21

RUN curl -sSL https://github.com/anza-xyz/agave/archive/refs/tags/v2.0.21.tar.gz | tar -zxvf - && \
    cd agave-${SOLANA_VERSION} && \
    ./scripts/cargo-install-all.sh /home/solana/.local/share/solana/install/releases/${SOLANA_VERSION} && \
    for file in /home/solana/.local/share/solana/install/releases/${SOLANA_VERSION}/bin/*; do strip ${file}; done

FROM debian:stable-slim

RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get install -y -q --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    ed \
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

WORKDIR /home/solana

ARG SOLANA_VERSION=2.0.21
COPY --chown=${USER}:${USER} --from=go-builder /go/bin/yamlfmt /go/bin/yamlfmt
COPY --chown=${USER}:${USER} --from=sol-builder /usr/local/cargo /usr/local/cargo
COPY --chown=${USER}:${USER} --from=sol-builder /usr/local/rustup /usr/local/rustup
COPY --chown=${USER}:${USER} --from=sol-builder /home/solana/.local/share/solana/install/releases/${SOLANA_VERSION} /home/solana/.local/share/solana/install/releases/${SOLANA_VERSION}
ENV PATH=${PATH}:/usr/local/cargo/bin:/go/bin:/home/solana/.local/share/solana/install/releases/${SOLANA_VERSION}/bin

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
