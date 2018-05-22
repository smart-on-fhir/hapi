FROM java:8

ARG DATA=./databases/empty
ARG FHIR=dstu3

# ENV FHIR=${FHIR}
# ENV DATA ${DATA}

RUN mkdir /app
RUN mkdir /data
RUN echo "cd /data && /app/hapi-fhir-cli run-server --allow-external-refs --disable-referential-integrity -f ${FHIR}" > /app/cmd

ADD https://github.com/jamesagnew/hapi-fhir/releases/download/v3.2.0/hapi-fhir-3.2.0-cli.tar.bz2 /tmp/hapi-fhir-3.2.0-cli/
RUN mkdir /app && tar xvjf /tmp/hapi-fhir-3.2.0-cli/hapi-fhir-3.2.0-cli.tar.bz2 -C /app/
RUN rm -rf /tmp/hapi-fhir-3.2.0-cli
# COPY ./hapi-fhir-3.2.0-cli /app
COPY $DATA /data

EXPOSE 8080
# WORKDIR /data
CMD bash /app/cmd


# CMD cd /data && /app/hapi-fhir-cli run-server --allow-external-refs --disable-referential-integrity --fhirversion $FHIR
