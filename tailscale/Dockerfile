FROM alpine AS build
RUN apk add --no-cache zip

# renovate: datasource=github-releases depName=tailscale/tailscale
ENV VERSION=1.80.0
ENV CHECKSUM=083b1fccbc7c34a6e284ada8b28cb6e832669b9f86cfe1efc31cb2530cff016b

ADD https://pkgs.tailscale.com/stable/tailscale_${VERSION}_amd64.tgz /tmp
RUN DOWNLOAD_FILE="/tmp/tailscale_${VERSION}_amd64.tgz" && \
    DOWNLOAD_CHECKSUM=$(sha256sum "${DOWNLOAD_FILE}" | awk '{print $1}') && \
    if [[ ${DOWNLOAD_CHECKSUM} != ${CHECKSUM} ]]; then \
      echo "Checksum does not match"; \
      exit 1; \
    fi && \
    tar xzf "${DOWNLOAD_FILE}" --strip=1 -C / && \
    rm "${DOWNLOAD_FILE}"

FROM scratch
COPY --from=build tailscale tailscaled /usr/local/sbin/
COPY ./assets/tailscaled.* /usr/local/lib/systemd/system/
COPY ./assets/release /usr/lib/extension-release.d/extension-release.tailscale
