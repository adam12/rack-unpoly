FROM ruby:3

RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    sudo \
    vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

RUN echo 'app ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/app && \
  chmod 440 /etc/sudoers.d/app

RUN useradd -ms /bin/bash app
USER app
WORKDIR /usr/src/app
