FROM ghcr.io/baosystems/postgis:15-3.5-alpine AS roadsign-preseed

COPY *.sql /docker-entrypoint-initdb.d

RUN grep -v 'exec "$@"' /usr/local/bin/docker-entrypoint.sh > /docker-entrypoint.sh && chmod 755 /docker-entrypoint.sh

ENV POSTGRES_HOST_AUTH_METHOD trust
ENV POSTGRES_DB roadsign
ENV POSTGRES_USER admin

RUN /docker-entrypoint.sh postgres

FROM ghcr.io/baosystems/postgis:15-3.5-alpine
COPY --from=roadsign-preseed /var/lib/postgresql/data /var/lib/postgresql/data



