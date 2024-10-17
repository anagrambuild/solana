#!/usr/bin/env bash

VERSION=$(git rev-parse HEAD | cut -c 1-8)

PROJECT=anagrambuild/$(basename ${PWD})

# cross platform okay:
# --platform=amd64 or arm64
DOCKER_BUILDKIT=1 docker build --progress plain . -t ${PROJECT}:${VERSION} \
                  --build-arg VERSION=${VERSION} && \
    docker tag ${PROJECT}:${VERSION} ${PROJECT}:latest && \
    docker tag ${PROJECT}:${VERSION} ghcr.io/${PROJECT}:latest
