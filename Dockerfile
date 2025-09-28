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
    && rm -rf /var/lib/apt/lists/*

# Install Arduino CLI – install from the official script, but change directory
# to /usr/local before invoking it so the CLI is placed in /usr/local/bin.
RUN cd /usr/local && \
    wget -qO- https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh \
    && chmod +x /usr/local/bin/arduino-cli

# Set up Raspberry Pi Pico SDK (minimal components)
ENV PICO_SDK_ARCHIVE_URL=https://github.com/raspberrypi/pico-sdk/archive/refs/heads/master.tar.gz
ENV PICO_SDK_PATH=/opt/pico-sdk
RUN mkdir -p ${PICO_SDK_PATH} && \
    wget -qO- ${PICO_SDK_ARCHIVE_URL} | tar -xz -C ${PICO_SDK_PATH} --strip-components=1

# Install OpenAI Python SDK
RUN pip install --no-cache-dir openai

# Install NodeJS 20.x and the OpenAI Codex CLI
RUN apt-get update && apt-get install -y --no-install-recommends curl gnupg ca-certificates && \
    rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*
RUN npm install -g @openai/codex

# Install Docker CE CLI (client only)
RUN apt-get update \
    && apt-get install -y ca-certificates curl gnupg \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo "deb [arch=$(uname -m) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(cat /etc/os-release | grep VERSION_CODENAME | cut -d= -f2) stable" | tee /etc/apt/sources.list.d/docker.list
RUN apt-get update \
    && apt-get install -y docker-cli \
    && rm -rf /var/lib/apt/lists/*

# Create a non‑root user and switch to it
ARG USERNAME=builder
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} --create-home ${USERNAME}

# Switch to the non‑root user
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Default command to keep container alive for debugging
CMD ["bash"]
