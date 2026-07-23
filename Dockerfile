FROM alpine:3.20

RUN apk add --no-cache bash

RUN addgroup -S fivem && adduser -S -G fivem -h /server fivem

WORKDIR /server

COPY cfx-server_linux_x64.tar.xz .
RUN tar -xf cfx-server_linux_x64.tar.xz \
    && rm cfx-server_linux_x64.tar.xz \
    && chmod +x run.sh \
    && chown -R fivem:fivem /server

COPY --chown=fivem:fivem server.cfg .

RUN mkdir -p /server/resources /server/data \
    && chown -R fivem:fivem /server/resources /server/data

USER fivem

EXPOSE 30120/tcp
EXPOSE 30120/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD pgrep -x run.sh > /dev/null || exit 1

CMD ["./run.sh", "+exec", "server.cfg"]
