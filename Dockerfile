FROM java:8

ARG DATA=./databases/empty
ARG FHIR=dstu3
ARG CLI_OPTS=-Xmx900m

RUN mkdir /app
RUN mkdir /data
RUN echo "cd /data && CLI_OPTS='${CLI_OPTS}' /app/hapi-fhir-cli run-server --allow-external-refs --disable-referential-integrity -f ${FHIR} -p \${PORT:-8080}" > /app/cmd

# COPY ./hapi-fhir-3.2.0-cli/* /app/
ADD https://github.com/jamesagnew/hapi-fhir/releases/download/v3.2.0/hapi-fhir-3.2.0-cli.tar.bz2 /tmp/hapi-cli/
RUN tar xvjf /tmp/hapi-cli/hapi-fhir-3.2.0-cli.tar.bz2 -C /app/
RUN rm -rf /tmp/hapi-cli
COPY $DATA /data

EXPOSE 8080

CMD bash /app/cmd
