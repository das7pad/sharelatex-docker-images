FROM buildpack-deps:stretch

# Install TexLive

# # Gather the install options.
ARG TEXLIVE_VERSION=2017
ARG TEXLIVE_MIRROR=http://ftp.math.utah.edu/pub/tex/
ARG TEXLIVE_REPOSITORY=${TEXLIVE_MIRROR}/historic/systems/texlive/${TEXLIVE_VERSION}/tlnet-final/
ARG TEXLIVE_SCHEME=basic

# # Extend the PATH to include the texlive executables.
# # We want to use tlmgr during the install, extend the path beforehand.
ENV PATH "${PATH}:/usr/local/texlive/${TEXLIVE_VERSION}/bin/x86_64-linux"

# # Run the installation process.
RUN set -ex \
&&  mkdir /install-tl-unx \
&&  curl -sSL \
      ${TEXLIVE_REPOSITORY}/install-tl-unx.tar.gz \
      | tar -xzC /install-tl-unx --strip-components=1 \
    \
&&  echo "tlpdbopt_autobackup 0" >> /install-tl-unx/profile \
&&  echo "tlpdbopt_install_docfiles 0" >> /install-tl-unx/profile \
&&  echo "tlpdbopt_install_srcfiles 0" >> /install-tl-unx/profile \
&&  echo "selected_scheme scheme-${TEXLIVE_SCHEME}" >> /install-tl-unx/profile \
    \
&&  TEXLIVE_INSTALL_ENV_NOCHECK=1 \
    TEXLIVE_INSTALL_NO_CONTEXT_CACHE=1 \
    TEXLIVE_INSTALL_NO_WELCOME=1 \
      /install-tl-unx/install-tl \
        --location ${TEXLIVE_REPOSITORY} \
        -profile /install-tl-unx/profile \
    \
&&  tlmgr install --repository ${TEXLIVE_REPOSITORY} \
      latexmk \
      texcount \
&&  rm -rf \
      $(find /usr/local/texlive/ -name "*.log") \
      /install-tl-unx

# Install dependencies
#  - ghostscript
#  - gnuplot
#  - pygments for minted
RUN apt-get update \
&&  apt-get install --yes --no-install-recommends \
      ghostscript \
      gnuplot-nox \
      python-pygments \
# patch minted: drop the install check for pygments
&&  sed -i -e 's/which\ \#1\ &&\ //' \
 /usr/local/texlive/${TEXLIVE_VERSION}/texmf-dist/tex/latex/minted/minted*.sty \
&&  rm -rf \
      /var/lib/apt/lists/*

COPY root /

# Add the runtime user for compiles.
RUN adduser \
      --group \
      --home /compile \
      --system \
      --uid 1000 \
      tex

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
  org.opencontainers.image.title="TexLive $TEXLIVE_VERSION $TEXLIVE_SCHEME" \
  org.opencontainers.image.description="TexLive \
with additional tools for the usage with the sharelatex/overleaf CLSI"
