FROM ubuntu:noble

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8

# Install dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    git \
    wget \
    software-properties-common \
    apt-transport-https \
    wireguard \
    gnupg \
    shellcheck \
    pipx \
    xorriso \
    && rm -rf /var/lib/apt/lists/*

# Install ansible and its dependencies
RUN pipx ensurepath \
    && pipx install --include-deps ansible \
    && pipx inject ansible ansible-lint yamllint

# Install Hadolint
# https://github.com/hadolint/hadolint

# Install Hadolint
ENV HADOLINT_VERSION=v2.12.0
RUN wget -q https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-x86_64 \
    && wget -q https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-x86_64.sha256 \
    # Verify file
    && sha256sum -c /hadolint-Linux-x86_64.sha256 \
    && rm /hadolint-Linux-x86_64.sha256 \
    # Make executable
    && chmod +x /hadolint-Linux-x86_64 \
    # Add to PATH
    && mv /hadolint-Linux-x86_64 /usr/local/bin \
    && ln -s /usr/local/bin/hadolint-Linux-x86_64 /usr/local/bin/hadolint \
    # Verify installation
    && hadolint --version

# Install Terraform
# https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
# Install HashiCorp's GPG key
RUN wget -q -O- https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor\
    | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null \
    # Verify the GPG key's fingerprint
    && gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint \
    # Add the official HashiCorp repository to your system
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" \
    | tee /etc/apt/sources.list.d/hashicorp.list \
    # Update apt to download the package information from the HashiCorp repository
    && apt-get update \
    # Install Terraform from the new repository
    && apt-get install terraform packer -y --no-install-recommends \
    # Clean up
    && rm -rf /var/lib/apt/lists/*

# Install Powershell
RUN source /etc/os-release \
    && wget -q "https://packages.microsoft.com/config/ubuntu/${VERSION_ID}/packages-microsoft-prod.deb" \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    &&  apt-get install -y --no-install-recommends powershell \
    && rm -rf /var/lib/apt/lists/*
