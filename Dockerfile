ARG ARTIFACTORY_HOSTNAME
FROM ${ARTIFACTORY_HOSTNAME}/docker-official-mirror/rocker/r2u:noble

COPY DOIRootCA2.crt /usr/local/share/ca-certificates

RUN update-ca-certificates

RUN apt-get update && apt-get install -y \
      curl \
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
    && rm -rf /var/lib/apt/lists/*

# install the AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  aws/install && \
  rm -rf aws awscliv2.zip

# install jq for parsing CLI responses
curl "https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-linux-arm64" -o /usr/local/bin/jq

RUN npm install -g mapshaper

COPY . /app

WORKDIR /app
CMD ["/app/entrypoint.sh"]
