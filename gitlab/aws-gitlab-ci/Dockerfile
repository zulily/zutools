FROM <REPLACE_WITH_REPO>:/alpine:3.6_<REPLACE_WITH_MONTH>

MAINTAINER Brion Stone <bstone@zulily.com>

RUN apk add --no-cache --update curl python python-dev py-pip git\
    && pip install awscli --ignore-installed six

# Install Docker
ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.13.1
ENV DOCKER_SHA256 97892375e756fd29a304bd8cd9ffb256c2e7c8fd759e12a55a6336e15100ad75
RUN set -x \
    && apk add --no-cache openssh-client \
    && curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION.tgz" -o docker.tgz \
    && echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
    && tar -xzvf docker.tgz \
    && mv docker/* /usr/local/bin/ \
    && rmdir docker \
    && rm docker.tgz \
    && docker -v

# Install kubernetes helpers
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && mv kubectl /usr/local/bin \
    && chmod +x /usr/local/bin/kubectl \
    && mkdir /app
COPY cmd/*.sh /app/

# Install Container Scanner client
COPY klar /usr/local/bin/

# Add AWS ECR helper
COPY ensure_ecr_repo.sh /usr/local/bin

ENV PATH $PATH:/usr/local/bin
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["sh"]
