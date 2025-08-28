FROM ghcr.io/baosystems/postgis:15-3.5@sha256:5f77ef2056fa60575eba092e2fb099ace190cd3ebf9591b46dad6b173b2e7e02 AS roadsign-preseed

COPY *.sql /docker-entrypoint-initdb.d

RUN grep -v 'exec "$@"' /usr/local/bin/docker-entrypoint.sh > /docker-entrypoint.sh && chmod 755 /docker-entrypoint.sh

ENV POSTGRES_HOST_AUTH_METHOD trust
ENV POSTGRES_DB roadsign
ENV POSTGRES_USER admin

RUN /docker-entrypoint.sh postgres

FROM ghcr.io/baosystems/postgis:15-3.5@sha256:5f77ef2056fa60575eba092e2fb099ace190cd3ebf9591b46dad6b173b2e7e02
COPY --from=roadsign-preseed /var/lib/postgresql/data /var/lib/postgresql/data



