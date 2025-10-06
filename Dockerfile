# Base image with Python
FROM python:3.11-slim

# Build dependencies for Arduino and Pico SDK
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    bash \
    git \
    cmake \
    wget \
    curl \
    uuid-dev \
    libusb-1.0-0-dev \
    gcc-arm-none-eabi \
    pkg-config \
    libudev-dev \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create a non‑root user
ARG USERNAME=builder
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} --create-home ${USERNAME} \
    && usermod -aG dialout ${USERNAME} \
    && mkdir -p /home/${USERNAME}/.codex \
    && chown -R ${USER_UID}:${USER_GID} /home/${USERNAME}/.codex
COPY --chown=${USER_UID}:${USER_GID} config.toml /home/${USERNAME}/.codex/config.toml

# Install Arduino CLI – install from the official script, but change directory
# to /usr/local before invoking it so the CLI is placed in /usr/local/bin.
RUN cd /usr/local \
    && wget -qO- https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh \
    && chmod +x /usr/local/bin/arduino-cli

# Set up Raspberry Pi Pico SDK (minimal components)
ENV PICO_SDK_ARCHIVE_URL=https://github.com/raspberrypi/pico-sdk/archive/refs/heads/master.tar.gz
ENV PICO_SDK_PATH=/opt/pico-sdk
RUN mkdir -p ${PICO_SDK_PATH} \
    && wget -qO- ${PICO_SDK_ARCHIVE_URL} | tar -xz -C ${PICO_SDK_PATH} --strip-components=1

# Install OpenAI Python SDK
RUN pip install --no-cache-dir openai

# Install NodeJS 22.x and the OpenAI Codex CLI
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g @openai/codex

# Install Docker CE CLI (client only)
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(uname -m) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(cat /etc/os-release | grep VERSION_CODENAME | cut -d= -f2) stable" | tee /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y docker-cli \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +s /usr/bin/docker

# Switch to the non‑root user
USER ${USERNAME}
RUN mkdir -p /home/${USERNAME}/workspace
ENV HOME=/home/${USERNAME}
ENV DOCKER_SOCKET=/var/run/docker.sock
ENV PICO_SDK_PATH=${PICO_SDK_PATH}
ENV ARDUINO_DATA_DIR=${HOME}/.arduino15
ENV ARDUINO_CACHE_DIR=${HOME}/.arduino15/cache
ENV ARDUINO_CLI_CONFIG_FILE=${HOME}/.arduino15/arduino-cli.yaml
ENV CODEX_CONFIG_FILE=${HOME}/.codex/config.toml
ENV WORKSPACE=${HOME}/workspace
WORKDIR ${WORKSPACE}

# Default command to keep container alive for debugging
CMD ["codex"]
