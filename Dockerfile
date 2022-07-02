#syntax=docker/dockerfile:1

FROM mcr.microsoft.com/vscode/devcontainers/base:0-ubuntu-22.04
ARG TARGETPLATFORM

ENV DOTNET_ROOT=/opt/dotnet
ENV DOTNET_CLI_TELEMETRY_OPTOUT=0
ENV POWERSHELL_ROOT=/opt/powershell
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="${VIRTUAL_ENV}/bin:${DOTNET_ROOT}:${POWERSHELL_ROOT}:${PATH}"

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install --no-install-recommends \
        ca-certificates curl gnupg lsb-release build-essential \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get -y install --no-install-recommends \
        git-lfs sqlite3 \
        fontconfig dnsutils iputils-ping file \
        python3-venv python3-pip python3-dev \
        docker-ce-cli docker-compose-plugin \
        pandoc texlive \
    && groupadd docker \
    && mkdir -p ${DOTNET_ROOT} \
    && if [ $TARGETPLATFORM = "linux/arm64" ]; then \
        curl -o /tmp/dotnet-sdk.tar.gz -L https://download.visualstudio.microsoft.com/download/pr/7c62b503-4ede-4ff2-bc38-50f250a86d89/3b5e9db04cbe0169e852cb050a0dffce/dotnet-sdk-6.0.300-linux-arm64.tar.gz; \
    elif [ $TARGETPLATFORM = "linux/amd64" ]; then \
        curl -o /tmp/dotnet-sdk.tar.gz -L https://download.visualstudio.microsoft.com/download/pr/dc930bff-ef3d-4f6f-8799-6eb60390f5b4/1efee2a8ea0180c94aff8f15eb3af981/dotnet-sdk-6.0.300-linux-x64.tar.gz; \
    fi \ 
    && tar xf /tmp/dotnet-sdk.tar.gz -C ${DOTNET_ROOT} \
    && dotnet tool install --tool-path ${POWERSHELL_ROOT} PowerShell --version 7.2.4 \
    && python3 -m venv ${VIRTUAL_ENV} \
    && pip install azure-cli \
    && az config set extension.use_dynamic_install=yes_without_prompt && az extension add --name azure-devops \
    && curl -o /tmp/firacode.zip -L https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip \
    && unzip -j /tmp/firacode.zip "*.ttf" -x "*Windows*" -d /usr/local/share/fonts \
    && fc-cache -f \
    && rm -rf /usr/share/doc/* && rm -rf /usr/share/info/* && rm -rf /usr/share/man/?? && rm -rf /usr/share/man/??_* \
    && rm -rf /usr/share/locale/* && rm -rf /usr/share/lintian/* \
    && apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
