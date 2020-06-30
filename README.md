# HAPI Fhir Server

This is a collection of Docker images containing a HAPI FHIR server configured to work with different FHIR versions and different pre-inserted data sets. The images are available on Docker Hub and can be used directly from there. These images can be used to run a HAPI server locally or as part of complex set ups like the [SMART Dev Sandbox](https://github.com/smart-on-fhir/smart-dev-sandbox).


## For Users

To run a HAPI server use the following command:
```sh
docker run -it -p {PORT}:8080 smartonfhir/hapi-5:{TAG}
```
Replace the `{PORT}` with the port that you want the server to accessible at and `{TAG}` with the image that you want to use.
The available tags are:
- `r2-empty`   - DSTU2 FHIR server with an empty database
- `r2-smart`   - STU3 FHIR server with 65 generated patients
- `r2-synthea` - STU3 FHIR server with 1461 Synthea-generated patients
- `r2-full`    - STU3 FHIR server with `r2-smart` and `r2-synthea` data combined
- `r3-empty`   - STU3 FHIR server with an empty database
- `r3-smart`   - STU3 FHIR server with 67 generated patients
- `r3-pro`     - STU3 FHIR server with some questionnaires and responses from 100 de-identified patients
- `r3-synthea` - STU3 FHIR server with 1461 Synthea patients
- `r3-full`    - STU3 FHIR server with `r3-smart`, `r3-pro` and `r3-synthea` data combined
- `r4-empty`   - R4 FHIR server with an empty database
- `r4-synthea` - R4 FHIR server with 629 Synthea patients
- `r5-empty`   - R5 FHIR server with an empty database

### Persisting data
The HAPI images are perfect for experimenting in development but if you want to
modify the data or insert new patients, those changes will not be preserved after
the container is shut down. To preserve the database across restarts, a Docker
volume can be used. Example:
```sh
# Run this once to create a named volume
docker volume create db

# Then mount the database to it while starting the image
docker run -it -p 8080:8080 -v db:/usr/local/tomcat/target/database smartonfhir/hapi-5:r3-full
```

### Configuration
Every image comes with a standard HAPI configuration file in which only the
desired FHIR version is modified. In some cases, users may need to change
other setting as well. For example, if you want to use SSL you would have
to set up a domain, generate a certificate and use a proxy server like NginX
or Apache that will pass requests to the upstream HAPI server. To make that
work, you would have to "tell" HAPI what its base URL is so that it generates
proper links in FHIR responses. To do so, you get a copy of the configuration
file (`hapi.properties`) included in this repo for convenience. Then make
sure you set `fhir_version` (replace `$FHIR_VERSION`) to what you need
(`DSTU2`, `DSTU3`, `R4` or `R5`) and set `server_address` to the desired value.
Once your config file is ready, put it in a folder and bind-mount it to `/config`:

```sh
docker run -it -p 8080:8080 -v /path/to/config-folder/:/config smartonfhir/hapi-5:r3-full
```

## For Maintainers and Contributors


To (re-)build an image you need to run `docker build` and provide a tag, fhir version and data directory.
Examples:
```sh
# DSTU2
sudo docker build -t smartonfhir/hapi-5:r2-empty   --build-arg FHIR_VERSION=DSTU2 --squash .
sudo docker build -t smartonfhir/hapi-5:r2-smart   --build-arg FHIR_VERSION=DSTU2 --squash --build-arg DATABASE=r2-smart   .
sudo docker build -t smartonfhir/hapi-5:r2-synthea --build-arg FHIR_VERSION=DSTU2 --squash --build-arg DATABASE=r2-synthea .
sudo docker build -t smartonfhir/hapi-5:r2-full    --build-arg FHIR_VERSION=DSTU2 --squash --build-arg DATABASE=r2-full    .

# DSTU3
sudo docker build -t smartonfhir/hapi-5:r3-empty   --build-arg FHIR_VERSION=DSTU3 --squash .
sudo docker build -t smartonfhir/hapi-5:r3-smart   --build-arg FHIR_VERSION=DSTU3 --squash --build-arg DATABASE=r3-smart   .
sudo docker build -t smartonfhir/hapi-5:r3-pro     --build-arg FHIR_VERSION=DSTU3 --squash --build-arg DATABASE=r3-pro     .
sudo docker build -t smartonfhir/hapi-5:r3-synthea --build-arg FHIR_VERSION=DSTU3 --squash --build-arg DATABASE=r3-synthea .
sudo docker build -t smartonfhir/hapi-5:r3-full    --build-arg FHIR_VERSION=DSTU3 --squash --build-arg DATABASE=r3-full    .

# R4
sudo docker build -t smartonfhir/hapi-5:r4-empty   --build-arg FHIR_VERSION=R4 --squash .
sudo docker build -t smartonfhir/hapi-5:r4-synthea --build-arg FHIR_VERSION=R4 --squash --build-arg DATABASE=r4-synthea .

#R5
sudo docker build -t smartonfhir/hapi-5:r5-empty   --build-arg FHIR_VERSION=R5 --squash .
```

NOTE:
1. We use `--squash` to reduce the image size. To make that work, Docker needs to be started with experimental features enabled
(`dockerd --experimental=true`).
2. Some of the build examples above may not work properly. They assume that there is a database for every image. Unfortunately those databases are files that exceed the GitHub file size limit and cannot be pushed to the repository. See `.gitignore` for the list of the excluded databases. This means that those databases have to be created locally before the image can be rebuilt. To do so we have to make the following:
    1. Start with an empty image for the desired FHIR version and use a volume to mount its database to the host FS:
        ```sh
        docker volume create db
        docker run -it -p 8080:8080 -v db:/usr/local/tomcat/target/database smartonfhir/hapi-5:r3-empty
        ```
    2. Insert the desired data using the FHIR API and stop the container. The data is located at https://github.com/smart-on-fhir/generated-sample-data. You can use https://github.com/smart-on-fhir/tag-uploader to insert the data. Note that the DSTU-2/SMART patients are in XML so you should use https://github.com/smart-on-fhir/xml-bundle-uploader to upload those. Also, some of these patients are not compatible with HAPI v5. To exclude them you can rename the files to have extension other than `.xml` and then upload the whole folder. The files to exclude are `patient-2169591.fhir-bundle.xml` and `patient-99912345.fhir-bundle.xml`.
    3. Find where the result database is:
        ```sh
        # inspect the volume to find our database location
        docker volume inspect db

        # This would look like:
        # [
        #     {
        #         "CreatedAt": "2020-06-23T16:41:42-04:00",
        #         "Driver": "local",
        #         "Labels": {},
        #         "Mountpoint": "/var/lib/docker/volumes/db/_data",
        #         "Name": "db",
        #         "Options": {},
        #         "Scope": "local"
        #     }
        # ]
        ```
    4. Using the `Mountpoint` property above copy the result database to the project:
        ```sh
        sudo cp /var/lib/docker/volumes/db/_data/h2.mv.db ./databases/{tag}/h2.mv.db
        ```
    5. Build the image as shown above

To run an image you should do `docker run -it -p {PORT}:8080 smartonfhir/hapi-5:{TAG}` replacing the {PORT} and {TAG} with whatever you need. Examples:
```sh
docker run -it -p 8080:8080 smartonfhir/hapi-5:r2-empty
docker run -it -p 8080:8080 smartonfhir/hapi-5:r2-smart
docker run -it -p 8080:8080 smartonfhir/hapi-5:r2-synthea
docker run -it -p 8080:8080 smartonfhir/hapi-5:r2-full

docker run -it -p 8080:8080 smartonfhir/hapi-5:r3-empty
docker run -it -p 8080:8080 smartonfhir/hapi-5:r3-smart
docker run -it -p 8080:8080 smartonfhir/hapi-5:r3-pro
docker run -it -p 8080:8080 smartonfhir/hapi-5:r3-synthea
docker run -it -p 8080:8080 smartonfhir/hapi-5:r3-full

docker run -it -p 8080:8080 smartonfhir/hapi-5:r4-empty
docker run -it -p 8080:8080 smartonfhir/hapi-5:r4-synthea

docker run -it -p 8080:8080 smartonfhir/hapi-5:r5-empty
```

To update an image use `docker push smartonfhir/{TAG}`. Examples:
```sh
docker push smartonfhir/hapi-5:r2-empty
docker push smartonfhir/hapi-5:r2-smart
docker push smartonfhir/hapi-5:r2-synthea
docker push smartonfhir/hapi-5:r2-full

docker push smartonfhir/hapi-5:r3-empty
docker push smartonfhir/hapi-5:r3-smart
docker push smartonfhir/hapi-5:r3-pro
docker push smartonfhir/hapi-5:r3-synthea
docker push smartonfhir/hapi-5:r3-full

docker push smartonfhir/hapi-5:r4-empty
docker push smartonfhir/hapi-5:r4-synthea

docker push smartonfhir/hapi-5:r5-empty
```


