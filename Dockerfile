FROM alpine:latest
ENV SAMBA_VERSION=4.15.5-r0
RUN apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add samba=${SAMBA_VERSION} shadow tini tzdata
COPY start.sh /
ENTRYPOINT ["/start.sh"]
