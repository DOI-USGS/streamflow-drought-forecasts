ARG ARTIFACTORY_HOSTNAME
FROM ${ARTIFACTORY_HOSTNAME}/docker-official-mirror/rocker/r2u:noble

COPY DOIRootCA2.crt /usr/local/share/ca-certificates

RUN update-ca-certificates

# Use bash with pipefail so a failure in a piped command (e.g. the NodeSource
# key download below) aborts the build instead of being masked by the pipe.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install Node.js 24.x (LTS) from NodeSource instead of Ubuntu's apt `npm`
# (which ships Node 18). mapshaper >=0.7.61 requires node >=20.11, so Node 18
# emits EBADENGINE warnings; Node 20 satisfies the floor but is now EOL, so we
# target the current Node 24 LTS (also matches the website's Node version). The
# `nodistro` repo codename is release-agnostic. We add the signing key and repo
# manually rather than piping the NodeSource setup script through a shell.
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
       | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" \
       > /etc/apt/sources.list.d/nodesource.list \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
      nodejs \
      r-cran-arrow \
      r-cran-crew \
      r-cran-data.table \
      r-cran-dataretrieval \
      r-cran-geofacet \
      r-cran-lubridate \
      r-cran-paws \
      r-cran-sf \
      r-cran-tarchetypes \
      r-cran-targets \
      r-cran-tidyverse \
      r-cran-tigris \
      r-cran-xfun \
      r-cran-zoo \
      vim \
    && rm -rf /var/lib/apt/lists/*

# Pin mapshaper for reproducible builds. 0.7.61 is the current release and is
# the version validated against this pipeline's geojson output.
RUN npm install -g mapshaper@0.7.61

COPY . /app

WORKDIR /app
CMD ["/app/entrypoint.sh"]
