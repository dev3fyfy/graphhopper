# Use an official Maven image as a parent image
FROM maven:3.8.4-openjdk-17-slim

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Build the project
RUN mvn clean install

# Specify the command to run on container start
CMD ["java", "-jar", "graphhopper.jar"]

RUN chmod 777 ./reader-gtfs/target/graphhopper-reader-gtfs-9.0-SNAPSHOT.jar


ENV JAVA_OPTS "-Xmx1g -Xms1g"

RUN mkdir -p /data

WORKDIR .

RUN apt-get update && apt-get install -y wget

# Make sure graphhopper.sh is executable
RUN chmod +x graphhopper.sh

# Enable connections from outside of the container
RUN sed -i '/^ *bind_host/s/^ */&# /p' config-example.yml
RUN chmod 777 ./reader-gtfs/target/graphhopper-reader-gtfs-9.0-SNAPSHOT.jar

VOLUME [ "/data" ]

EXPOSE 8989 8990

HEALTHCHECK --interval=5s --timeout=3s CMD curl --fail http://localhost:8989/health || exit 1

ENTRYPOINT [ "./graphhopper.sh", "-c", "config-example.yml", "--url", "http://download.geofabrik.de/africa/zambia-latest.osm.pbf" ]
RUN chmod 777 ./reader-gtfs/target/graphhopper-reader-gtfs-9.0-SNAPSHOT.jar




