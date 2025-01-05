### Solana Development Container for Docker and VS Code

![Solana](https://docs.solanalabs.com/img/logo-horizontal.svg)

[LICENSE](LICENSE)

This development container for Visual Studio Code is a pre-configured and isolated environment that allows you to develop, build, and test your software projects using consistent tools and settings.   This development container can be used in Docker to create a standardized and reproducible environment for your development workflow. This is useful when working on projects that require specific versions of programming languages, libraries, tools, and other dependencies. By using this development container, you can ensure that all members of your development team work with the same development environment, reducing issues related to differences in configurations and dependencies.

### Example Dockerfile:

```
FROM anagrambuild/solana:latest
ARG SOLANA_VERSION=2.0.21
ENV USER=solana
ENV PATH=${PATH}:/usr/local/cargo/bin:/go/bin:/home/solana/.local/share/solana/install/releases/${SOLANA_VERSION}/bin
WORKDIR /home/solana
USER solana
```

### Architecture support
* linux/amd64 
* linux/arm64

#### Precompiled binaries

Precompiled binaries are provided for amd64 architecture.  Arm64 is supported by building locally using the `build.sh` script

Also available from [GitHub GHCR](https://github.com/anagrambuild/solana/pkgs/container/solana)


### Key benefits

Benefits of using development containers in Visual Studio Code include:

1. **Consistency**: Development containers ensure that everyone on the team is using the same environment, reducing "works on my machine" issues.

2. **Isolation**: Containers provide isolation from the host system, preventing conflicts between different software versions.

3. **Reproducibility**: Containers can be versioned, making it easy to replicate the exact development environment in different stages of the project.

4. **Portability**: Development containers can be shared and run on different machines, making it easier to onboard new team members or work across multiple devices.

5. **Dependency Management**: Containers encapsulate dependencies, eliminating the need to install and manage them directly on the host system.

To use this development container in Visual Studio Code, specify the `Dockerfile` as defined below and reopen in the Remote Containers module.


