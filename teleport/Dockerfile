FROM alpine AS build
# renovate: datasource=github-releases depName=fluxcd/flux2
ENV VERSION=17.2.1
ENV CHECKSUM=126e0b26cce97fd827c42f57274ad77478068554423d71f38949935f8e8af646

ADD https://cdn.teleport.dev/teleport-v${VERSION}-linux-amd64-bin.tar.gz /tmp
RUN DOWNLOAD_FILE="/tmp/teleport-v${VERSION}-linux-amd64-bin.tar.gz" && \
    DOWNLOAD_CHECKSUM=$(sha256sum "${DOWNLOAD_FILE}" | awk '{print $1}') && \
    if [[ ${DOWNLOAD_CHECKSUM} != ${CHECKSUM} ]]; then \
      echo "Checksum does not match"; \
      exit 1; \
    fi && \
    tar xzf "${DOWNLOAD_FILE}" --strip=1 -C / && \
    rm "${DOWNLOAD_FILE}"

FROM scratch
COPY --from=build teleport tctl tsh tbot /
COPY teleport.service /
COPY run.sh /
COPY ./assets /assets
