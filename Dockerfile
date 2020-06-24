FROM hapiproject/hapi:base as build-hapi

ARG HAPI_FHIR_URL=https://github.com/jamesagnew/hapi-fhir/
ARG HAPI_FHIR_BRANCH=master
ARG HAPI_FHIR_STARTER_URL=https://github.com/hapifhir/hapi-fhir-jpaserver-starter/
ARG HAPI_FHIR_STARTER_BRANCH=master

# Build HAPI
RUN git clone --branch ${HAPI_FHIR_BRANCH} ${HAPI_FHIR_URL}
WORKDIR /tmp/hapi-fhir/
RUN /tmp/apache-maven-3.6.2/bin/mvn dependency:resolve
RUN /tmp/apache-maven-3.6.2/bin/mvn install -DskipTests

# Build HAPI_FHIR_STARTER
WORKDIR /tmp
RUN git clone --branch ${HAPI_FHIR_STARTER_BRANCH} ${HAPI_FHIR_STARTER_URL}
COPY ./tmpl-banner.html /tmp/hapi-fhir-jpaserver-starter/src/main/webapp/WEB-INF/templates/tmpl-banner.html
COPY ./smart-logo.svg   /tmp/hapi-fhir-jpaserver-starter/src/main/webapp/img/smart-logo.svg
WORKDIR /tmp/hapi-fhir-jpaserver-starter
RUN /tmp/apache-maven-3.6.2/bin/mvn clean install -DskipTests

FROM tomcat:9-jre11

RUN mkdir -p /data/hapi/lucenefiles && chmod 775 /data/hapi/lucenefiles
COPY --from=build-hapi /tmp/hapi-fhir-jpaserver-starter/target/*.war /usr/local/tomcat/webapps/

RUN apt-get update && apt-get install gettext-base -y

ARG DATABASE=empty
ARG IP=127.0.0.1
ARG FHIR_VERSION=R4
ARG JAVA_OPTS=-Dhapi.properties=/config/hapi.properties

ENV JAVA_OPTS=$JAVA_OPTS
ENV IP=$IP
ENV FHIR_VERSION=$FHIR_VERSION
ENV DATABASE=$DATABASE

COPY ./databases/${DATABASE}/ /usr/local/tomcat/target/database/

RUN mkdir /config
COPY ./hapi.properties  /tmp/hapi.properties.tpl

EXPOSE 8080

CMD envsubst < /tmp/hapi.properties.tpl > /config/hapi.properties && catalina.sh run
