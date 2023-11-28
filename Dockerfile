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



ENV JAVA_OPTS "-Xmx1g -Xms1g"

RUN mkdir -p /data

WORKDIR .

RUN apt-get update && apt-get install -y wget

# Make sure graphhopper.sh is executable
RUN chmod +x graphhopper.sh

# Enable connections from outside of the container
RUN sed -i '/^ *bind_host/s/^ */&# /p' config-example.yml

VOLUME [ "/data" ]

EXPOSE 8989 8990

HEALTHCHECK --interval=5s --timeout=3s CMD curl --fail http://localhost:8989/health || exit 1

ENTRYPOINT [ "./graphhopper.sh", "-c", "config-example.yml", "--url", "http://download.geofabrik.de/africa/zambia-latest.osm.pbf" ]




# FROM amazoncorretto:11 AS builder

# WORKDIR /app

# COPY m2 /root/m2
# RUN mv /root/m2 /root/.m2

# COPY tzupdater.jar .
# COPY tzdata-latest.tar.gz .
# RUN java -jar tzupdater.jar -f -v -u -l file:./tzdata-latest.tar.gz

# COPY mvnw .
# COPY .mvn .mvn
# COPY pom.xml .
# RUN ./mvnw dependency:resolve-plugins dependency:resolve dependency:go-offline

# COPY src src
# RUN ./mvnw install -DskipTests
# RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

# ADD https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip .
# RUN yum install -y unzip
# RUN unzip newrelic-java.zip


# FROM amazoncorretto:11

# VOLUME /tmp

# ARG DEPENDENCY=/app/target/dependency
# COPY --from=builder ${DEPENDENCY}/BOOT-INF/lib /app/lib
# COPY --from=builder ${DEPENDENCY}/META-INF /app/META-INF
# COPY --from=builder ${DEPENDENCY}/BOOT-INF/classes /app
# COPY --from=builder /app/newrelic/newrelic.jar /app/newrelic/newrelic.jar

# ENV NEW_RELIC_APP_NAME="location_healing_service"

# ENTRYPOINT ["java", "-noverify", "-javaagent:/app/newrelic/newrelic.jar", "-cp", "app:app/lib/*", "io.graphhopper.location_healing_service"]
