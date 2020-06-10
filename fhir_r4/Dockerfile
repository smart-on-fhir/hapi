FROM openjdk:11

ARG DATA=./databases/empty
ARG CLI_OPTS=-Xmx2048m

RUN mkdir /app
RUN mkdir /data
RUN echo "cd /data && CLI_OPTS='${CLI_OPTS}' /app/hapi-fhir-cli run-server --allow-external-refs --disable-referential-integrity -v r4 -p \${PORT:-8080}" > /app/cmd

# speed up repeated builds if already downloaded to local filesystem
# COPY ./hapi-fhir-4.2.0-cli/* /app/
# or
ADD https://github.com/jamesagnew/hapi-fhir/releases/download/v4.2.0/hapi-fhir-4.2.0-cli.tar.bz2 /tmp/hapi-cli/
RUN tar xvjf /tmp/hapi-cli/hapi-fhir-4.2.0-cli.tar.bz2 -C /app/
RUN rm -rf /tmp/hapi-cli

COPY $DATA /data

EXPOSE 8080

CMD bash /app/cmd
