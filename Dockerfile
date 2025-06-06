FROM maven:3.8.5-openjdk-17 AS build

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

FROM openjdk:17-jdk-slim

RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/* \

WORKDIR /app
COPY --from=build /app/target/hangman-game-redis-1.0.jar app.jar
CMD ["java", "-jar", "app.jar"]
