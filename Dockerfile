# Use the official OpenJDK image as the base image
FROM openjdk:17-jdk-slim as build

# Set the working directory in the container
WORKDIR /app

# Copy the Maven wrapper and pom.xml
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Download Maven dependencies (this is cached unless pom.xml changes)
RUN ./mvnw dependency:go-offline -B

# Copy the rest of the application code
COPY src ./src

# Build the application
RUN ./mvnw clean package -DskipTests

# Use a smaller OpenJDK runtime image for the final image
FROM openjdk:17-jre-slim

# Set the working directory for the final image
WORKDIR /app

# Copy the JAR file from the build stage into the runtime image
COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar app.jar

# Expose the application port
EXPOSE 8086

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
