FROM node:12.16.1

WORKDIR /lint-runner
COPY root/lint-runner/package*.json /lint-runner/
RUN npm ci

COPY root /

# reset the entrypoint of the base image
# this must be the last step: https://github.com/moby/moby/issues/37273
ENTRYPOINT []
CMD ["bash"]

ARG DATE
ARG RELEASE
ARG COMMIT
LABEL \
  org.opencontainers.image.created="$DATE" \
  org.opencontainers.image.authors="Jakob Ackermann <das7pad@outlook.com>" \
  org.opencontainers.image.url="https://github.com/das7pad/sharelatex-docker-images" \
  org.opencontainers.image.documentation="" \
  org.opencontainers.image.source="https://github.com/das7pad/sharelatex-docker-images" \
  org.opencontainers.image.version="$RELEASE" \
  org.opencontainers.image.revision="$COMMIT" \
  org.opencontainers.image.vendor="Jakob Ackermann" \
  org.opencontainers.image.licenses="AGPL-3.0" \
  org.opencontainers.image.ref.name="$RELEASE" \
  org.opencontainers.image.title="Lint-Runner" \
  org.opencontainers.image.description="packaged eslint and prettier"
