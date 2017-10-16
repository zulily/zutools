# Based on https://github.com/grugnog/google-cloud-auto-snapshot
FROM ubuntu:14.04

# Install cloudsdk and curl clients.
RUN \
  apt-get update && \
  apt-get install -y curl && \
  echo "deb http://packages.cloud.google.com/apt cloud-sdk-$(lsb_release -c -s) main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list && \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
  apt-get update && \
  apt-get install -y google-cloud-sdk && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /opt && mkdir /opt
ADD google-cloud-auto-snapshot.sh /opt/google-cloud-auto-snapshot.sh
ADD entrypoint.sh /opt/entrypoint.sh
RUN chmod u+x /opt/google-cloud-auto-snapshot.sh /opt/entrypoint.sh
ENTRYPOINT /opt/entrypoint.sh
