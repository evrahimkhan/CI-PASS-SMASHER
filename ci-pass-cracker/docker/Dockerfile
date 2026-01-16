FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install prerequisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    wget \
    unzip \
    python3 \
    python3-pip \
    git \
    ca-certificates \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install John the Ripper from source to get latest version and all utilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    john \
    libimage-exiftool-perl \
    rar \
    unrar \
    p7zip-full \
    && rm -rf /var/lib/apt/lists/*

# Get additional extraction tools that might not be in the base package
WORKDIR /opt
RUN git clone https://github.com/openwall/john.git && \
    cd john/src && \
    ./configure && \
    make -s clean && \
    make -sj4 && \
    cd ../run && \
    # Copy all the john utilities to the standard location
    cp *2john* /usr/local/bin/ 2>/dev/null || true

# Create working directory
WORKDIR /app

# Copy entrypoint script
COPY ci-pass-cracker/docker/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]