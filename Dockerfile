ARG VARIANT=stable-slim
FROM debian:${VARIANT}

# Will not prompt for questions
ARG DEBIAN_FRONTEND=noninteractive

ARG USERNAME=node
ENV USERNAME=$USERNAME
ARG USER_UID=1000
ARG USER_GID=1000

RUN apt-get update \
    && apt-get install -y sudo wget curl software-properties-common git vim

RUN curl -sL https://deb.nodesource.com/setup_20.x | sudo bash -
RUN apt-get install -y nodejs

RUN useradd -m $USERNAME && echo "$USERNAME:$USERNAME" | chpasswd && adduser $USERNAME sudo
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

USER $USERNAME
WORKDIR /home/"${USERNAME}"
ENV HOME /home/"${USERNAME}"

ARG THEME=https://github.com/denysdovhan/spaceship-prompt
RUN mkdir ~/.npm-global
RUN npm config set prefix '~/.npm-global'

RUN npm install --global yarn

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
    -t $THEME \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="false"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="false"' \
    -p git \
    -p ssh-agent \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-history-substring-search \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -p 'history-substring-search' \
    -a 'bindkey "\$terminfo[kcuu1]" history-substring-search-up' \
    -a 'bindkey "\$terminfo[kcud1]" history-substring-search-down'

RUN echo "export PATH=~/.npm-global/bin:$PATH" >> ~/.zshrc
RUN echo "export PATH=~/.npm-global/bin:$PATH" >> ~/.bashrc

ARG DIRECTORY=/workspace
ENV DIRECTORY=$DIRECTORY

RUN sudo mkdir -p ${DIRECTORY}
WORKDIR ${DIRECTORY}
RUN sudo chown -R ${USERNAME} ${DIRECTORY}
