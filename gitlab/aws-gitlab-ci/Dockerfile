FROM <REPLACE_WITH_REPO>:/alpine:3.9

LABEL maintainer="bstone@zulily.com"

RUN apk add --no-cache --update curl python python-dev py-pip git\
    && pip install awscli --ignore-installed six

# Install Docker
ENV DOCKER_BUCKET download.docker.com
ENV DOCKER_VERSION 18.09.0
ENV DOCKER_SHA256 08795696e852328d66753963249f4396af2295a7fe2847b839f7102e25e47cb9
RUN set -x \
    && apk add --no-cache openssh-client \
    && curl -fSL "https://${DOCKER_BUCKET}/linux/static/stable/x86_64/docker-$DOCKER_VERSION.tgz" -o docker.tgz \
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
