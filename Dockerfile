FROM debian:bookworm-slim

RUN apt update \
    && apt install -y postgresql-common wget \
    && /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y \
    && apt install -y postgresql-client-17 \
    && wget https://dl.minio.io/client/mc/release/linux-amd64/mc -O /sbin/mc \
    && chmod +x /sbin/mc \
    && apt remove -y wget \
    && apt autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh .
ENTRYPOINT ["/entrypoint.sh"]
