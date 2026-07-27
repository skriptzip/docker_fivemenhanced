FROM alpine:3.20

ARG FIVEM_NUM=0
ARG FIVEM_URL=https://downloads.cfx-services.net/prod/Linux/cfx-server_linux_x64.tar.xz
ARG FIVEM_SHA256=0

RUN apk add --no-cache bash curl xz

RUN addgroup -S fivem && adduser -S -G fivem -h /server fivem

WORKDIR /server

RUN curl -fsSL --retry 3 --retry-delay 2 "$FIVEM_URL" -o cfx-server.tar.xz \
    && echo "$FIVEM_SHA256  cfx-server.tar.xz" | sha256sum -c - \
    && tar -xf cfx-server.tar.xz \
    && rm cfx-server.tar.xz \
    && chmod +x run.sh \
    && chown -R fivem:fivem /server

COPY --chown=fivem:fivem server.cfg .

RUN mkdir -p /server/resources /server/data \
    && chown -R fivem:fivem /server/resources /server/data

LABEL org.opencontainers.image.title="FiveM Server (GTA Enhanced)" \
      org.opencontainers.image.description="FiveM dedicated server for GTA Enhanced" \
      org.opencontainers.image.version="${FIVEM_NUM}" \
      org.opencontainers.image.source="https://github.com/OWNER/docker_fivemenhanced"

USER fivem

EXPOSE 30120/tcp
EXPOSE 30120/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD pgrep -x run.sh > /dev/null || exit 1

CMD ["./run.sh", "+exec", "server.cfg"]
