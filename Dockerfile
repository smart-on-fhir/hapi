FROM java:8

ARG DATA=./databases/empty
ARG FHIR=dstu3

RUN mkdir /app
RUN mkdir /data
RUN echo "cd /data && CLI_OPTS='-Xmx1024m' /app/hapi-fhir-cli run-server --allow-external-refs --disable-referential-integrity -f ${FHIR}" > /app/cmd

ADD https://github.com/jamesagnew/hapi-fhir/releases/download/v3.2.0/hapi-fhir-3.2.0-cli.tar.bz2 /tmp/hapi-fhir-3.2.0-cli/
RUN tar xvjf /tmp/hapi-fhir-3.2.0-cli/hapi-fhir-3.2.0-cli.tar.bz2 -C /app/
RUN rm -rf /tmp/hapi-fhir-3.2.0-cli
COPY $DATA /data

EXPOSE 8080

CMD bash /app/cmd
