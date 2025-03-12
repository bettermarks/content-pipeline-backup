FROM debian:bookworm-slim

RUN apt update \
    && apt install -y wget gnupg pigz pbzip2 xz-utils lrzip brotli zstd postgresql-common \
    && /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y \
    && apt install -y postgresql-client-16 \
    && wget https://dl.minio.io/client/mc/release/linux-amd64/mc -O /sbin/mc \
    && chmod +x /sbin/mc \
    && apt remove -y wget \
    && apt autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh .
ENTRYPOINT ["/entrypoint.sh"]
