FROM alpine:3.17
ARG ARCHITECTURE=x86_64
ARG S6_OVERLAY_VERSION=3.1.3.0

RUN apk add --no-cache \
  openssh \
  git \
  stagit \
  git-daemon \
  nginx

# Key generation on the server
RUN ssh-keygen -A

# Install s6
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp/
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${ARCHITECTURE}.tar.xz /tmp/
RUN tar -xJpC / -f /tmp/s6-overlay-noarch.tar.xz && \
    tar -xJpC / -f /tmp/s6-overlay-${ARCHITECTURE}.tar.xz && \
    rm /tmp/s6-overlay-noarch.tar.xz && \
    rm /tmp/s6-overlay-${ARCHITECTURE}.tar.xz

# s6 config
COPY init/ /etc/s6-overlay/s6-init.d/
COPY services/ /etc/s6-overlay/s6-rc.d/
ENV PATH="${PATH}:/command"

# -D flag avoids password generation
# -s flag changes user's shell
RUN mkdir /keys \
  && adduser -D -s /usr/bin/git-shell git \
  && echo git:12345 | chpasswd \
  && mkdir /home/git/.ssh
RUN mkdir /repos
RUN mkdir /html

# sshd_config file is edited for enable access key and disable access password
COPY sshd_config /etc/ssh/sshd_config

# Stagit resources
COPY resources /resources

# Nginx config
RUN rm /etc/nginx/http.d/default.conf
COPY www.conf /etc/nginx/http.d/www.conf

COPY git-shell-commands /home/git/git-shell-commands

EXPOSE 22
EXPOSE 80
EXPOSE 9418

WORKDIR /repos

# Run s6
ENTRYPOINT /init

