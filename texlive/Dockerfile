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
RUN apt-get update \
&&  apt-get install --yes --no-install-recommends \
      ghostscript \
      gnuplot-nox \
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
