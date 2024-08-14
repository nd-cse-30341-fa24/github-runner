FROM ubuntu:24.04

ENV GITHUB_PAT ""
ENV GITHUB_TOKEN ""
ENV GITHUB_OWNER ""
ENV GITHUB_REPOSITORY ""
ENV RUNNER_WORKDIR "_work"
ENV RUNNER_LABELS ""
ENV DEBIAN_FRONTEND "noninteractive"

RUN apt-get update \
    && apt-get install -y \
        curl \
        sudo \
        git \
        jq \
        iputils-ping \
        build-essential \
        python3 \
        python3-tornado \
        python3-requests \
        python3-yaml \
        python3-tqdm \
        gawk \
        bc \
        zip \
        unzip \
        netcat-openbsd \
        valgrind \
        strace \
        iproute2 \
        libssl-dev \
        wamerican \
        mypy \
        nmap \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m github \
    && usermod -aG sudo github \
    && echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/github

RUN GITHUB_RUNNER_VERSION=$(curl --silent "https://api.github.com/repos/actions/runner/releases/latest" | jq -r '.tag_name[1:]') \
    && curl -Ls https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz | tar xz \
    && ./bin/installdependencies.sh

COPY entrypoint.sh runsvc.sh ./
RUN chmod 755 ./entrypoint.sh ./runsvc.sh

USER github
ENTRYPOINT ["/home/github/entrypoint.sh"]
