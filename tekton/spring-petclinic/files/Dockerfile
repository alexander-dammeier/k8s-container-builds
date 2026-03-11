# Stage 1: Build the Java application
FROM maven:3.9-eclipse-temurin-17-alpine AS builder
WORKDIR /app

# Configure maven to use a local directory for caching within the container
ENV MAVEN_OPTS='-Dmaven.repo.local=/app/.m2'

# We removed the mandatory COPY .m2 because we don't use a shared PVC anymore
# and we want to allow skipping tests (which would have populated .m2).

COPY .mvn .mvn
COPY mvnw pom.xml ./
RUN chmod +x mvnw
COPY src src
RUN ./mvnw package -DskipTests -Dcheckstyle.skip

# Stage 2: Create a minimal production image
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
