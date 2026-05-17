ARG POSTGRES_VERSION=16
FROM postgres:${POSTGRES_VERSION}

ENV POSTGRES_DB=railway
# Subdirectory avoids initdb failure when the volume mount creates lost+found at the mount root
ENV PGDATA=/var/lib/postgresql/data/pgdata

EXPOSE 5432

COPY docker-entrypoint-custom.sh /usr/local/bin/
RUN sed -i 's/\r$//' /usr/local/bin/docker-entrypoint-custom.sh && \
    chmod +x /usr/local/bin/docker-entrypoint-custom.sh

ENTRYPOINT ["docker-entrypoint-custom.sh"]
CMD ["postgres"]
