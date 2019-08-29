FROM ubuntu:18.04

LABEL maintainer="bstone@zulily.com"


# to update APT index with openresty and prepare dirs:
RUN \
  apt-get update && \
  apt-get install -y wget gnupg && \
  wget -q -O - https://openresty.org/package/pubkey.gpg | apt-key add - && \
  # for installing the add-apt-repository command
  # (you can remove this package and its dependencies later):
  apt-get -y install software-properties-common && \
  # add the official APT repository:
  add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" && \
  apt-get update  && \
  apt-get install openresty -y && \
  # install prometheus library to generate nginx metrics.
  opm get knyar/nginx-lua-prometheus && \
  apt remove -y software-properties-common && \
  apt autoremove -y && \
  rm ~/.curlrc && \
  rm -rf /var/lib/apt/lists/* 

# add additional binaries into PATH for convenience
ENV PATH=$PATH:/usr/local/openresty/luajit/bin/:/usr/local/openresty/nginx/sbin/:/usr/local/openresty/bin/

WORKDIR /usr/src

ADD start.sh /usr/src/
ADD nginx/nginx.conf /usr/local/openresty/nginx/conf/
ADD nginx/prometheus.lua /usr/local/openresty/lualib/prometheus/
ADD nginx/openresty*.conf /usr/src/

ENTRYPOINT ./start.sh
