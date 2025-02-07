FROM alpine AS build
RUN apk add --no-cache zip

# renovate: datasource=github-releases depName=hashicorp/consul
ENV VERSION=1.20.2
ENV CHECKSUM=1bf7ddf332f02e6e36082b0fdf6c3e8ce12a391e7ec7dafd3237bb12766a7fd5

ADD https://releases.hashicorp.com/consul/${VERSION}/consul_${VERSION}_linux_amd64.zip /tmp
RUN DOWNLOAD_FILE="/tmp/consul_${VERSION}_linux_amd64.zip" && \
    DOWNLOAD_CHECKSUM=$(sha256sum "${DOWNLOAD_FILE}" | awk '{print $1}') && \
    if [[ ${DOWNLOAD_CHECKSUM} != ${CHECKSUM} ]]; then \
      echo "Checksum does not match"; \
      exit 1; \
    fi && \
    unzip "${DOWNLOAD_FILE}" -d / && \
    rm "${DOWNLOAD_FILE}"

FROM scratch
COPY --from=build consul /
COPY consul.service /
COPY run.sh /
