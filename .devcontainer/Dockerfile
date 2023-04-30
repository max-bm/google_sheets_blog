FROM eu.gcr.io/cts-public-images-1/cts-standard:latest

# Software versions
ARG KUBECTL_VERSION=v1.15.10
ARG POWERLINE_VERSION=1.21.0

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=vscode

# Install helpful tooling
RUN curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg 2>/dev/null \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && apt-get update -y \
  && apt-get -y install --no-install-recommends \
  bash-completion \
  docker-ce-cli \
  gnupg-agent \
  ipcalc \
  keychain \
  python3-google-auth \
  software-properties-common \
  vim \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* \
  #
  # Install Docker Compose
  && curl -sSL "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

# Install Google Python SDK
RUN pip3 install --upgrade google-api-python-client

# get tfenv instead of terraform for ease of module switching
RUN git clone https://github.com/tfutils/tfenv.git /home/$USERNAME/.tfenv && \
  chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.tfenv

# install Powerline GO
RUN curl -Lo powerline-go https://github.com/justjanne/powerline-go/releases/download/v${POWERLINE_VERSION}/powerline-go-linux-$(dpkg --print-architecture) && \
  chmod +x powerline-go && \
  mv powerline-go /usr/local/bin

# Install Kubectl tools
RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/$(dpkg --print-architecture)/kubectl && \
  chmod +x kubectl && \
  mv kubectl /usr/local/bin

# Set the default shell to bash instead of sh
ENV SHELL /bin/bash

USER vscode

# Copy any devcontainer bashrc setup and activate it
ADD .bashrc_devcontainer /home/$USERNAME/.bashrc_devcontainer
RUN echo "source ~/.bashrc_devcontainer" >> /home/$USERNAME/.bashrc
