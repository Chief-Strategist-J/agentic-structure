# Multi-stage Dockerfile for Kotlin service
FROM gradle:8.5-jdk21 AS builder
WORKDIR /app
COPY build.gradle.kts settings.gradle.kts ./
COPY . .
RUN gradle bootJar --no-daemon

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /app/build/libs/*.jar app.jar
USER 10001:10001
ENTRYPOINT ["java", "-jar", "app.jar"]
