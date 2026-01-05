ARG ARTIFACTORY_HOSTNAME
FROM ${ARTIFACTORY_HOSTNAME}/docker-official-mirror/rocker/r2u:noble

COPY DOIRootCA2.crt /usr/local/share/ca-certificates

RUN update-ca-certificates

RUN apt-get update && apt-get install -y \
      npm \
      r-cran-arrow \
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

RUN npm install -g mapshaper

COPY . /app

WORKDIR /app
CMD ["/app/entrypoint.sh"]
