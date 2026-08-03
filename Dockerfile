FROM alpine:3.20

ARG FIVEM_NUM=107
ARG FIVEM_URL=https://downloads.cfx-services.net/prod/019fc7df-a2ad-76aa-866a-92f4c228ef7b/cfx-server_linux_x64.tar.xz
ARG FIVEM_SHA256=5ab15fccf4fb475845485b1fafb7f9134374d9aa234b3462c5980f333be4c2d1

RUN apk add --no-cache bash curl xz

RUN addgroup -S fivem && adduser -S -G fivem -h /server fivem

WORKDIR /server

RUN curl -fsSL --retry 3 --retry-delay 2 "$FIVEM_URL" -o cfx-server.tar.xz \
    && if [ -n "$FIVEM_SHA256" ]; then echo "$FIVEM_SHA256  cfx-server.tar.xz" | sha256sum -c -; fi \
    && tar -xf cfx-server.tar.xz \
    && rm cfx-server.tar.xz \
    && chmod +x run.sh \
    && chown -R fivem:fivem /server

COPY --chown=fivem:fivem fivem-data/server.cfg.template /opt/cfx-server-data/
COPY --chown=fivem:fivem config/entrypoint /usr/bin/entrypoint
RUN chmod +x /usr/bin/entrypoint \
    && sed -i 's/\r$//' /usr/bin/entrypoint

RUN mkdir -p /fivem-data \
    && ln -s /fivem-data/resources /server/resources \
    && ln -s /fivem-data/data /server/data \
    && chown -R fivem:fivem /fivem-data

LABEL org.opencontainers.image.title="FiveM Server (GTA Enhanced)" \
      org.opencontainers.image.description="FiveM dedicated server for GTA Enhanced" \
      org.opencontainers.image.version="${FIVEM_NUM}" \
      org.opencontainers.image.source="https://github.com/skriptzip/docker_fivemenhanced"

USER fivem

EXPOSE 30120/tcp
EXPOSE 30120/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD pgrep -x FXServer > /dev/null || exit 1

ENTRYPOINT ["/usr/bin/entrypoint"]
