FROM ubuntu:16.04

MAINTAINER Brion Stone <bstone@zulily.com>


# to update APT index with openresty and prepare dirs:
# the --no-check-certificate is only due to the PaloAlto in Elliott. Remove at earliest possibile time.
RUN \
  apt-get update && \
  apt-get install -y wget && \
  wget -q --no-check-certificate -O - https://openresty.org/package/pubkey.gpg | apt-key add - && \
  echo "deb http://openresty.org/package/ubuntu xenial main" > /etc/apt/sources.list.d/openresty.list && \
  apt-get update  && \
  apt-get install openresty -y && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p /usr/local/openresty/nginx/conf/conf.d && \
  mkdir -p /usr/local/openresty/lualib/prometheus && \
  rm /usr/local/openresty/nginx/conf/nginx.conf

# add additional binaries into PATH for convenience
ENV PATH=$PATH:/usr/local/openresty/luajit/bin/:/usr/local/openresty/nginx/sbin/:/usr/local/openresty/bin/

WORKDIR /usr/src

ADD start.sh /usr/src/
ADD nginx/nginx.conf /usr/local/openresty/nginx/conf/
ADD nginx/prometheus.lua /usr/local/openresty/lualib/prometheus/
ADD nginx/openresty*.conf /usr/src/

ENTRYPOINT ./start.sh
