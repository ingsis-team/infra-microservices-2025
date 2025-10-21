FROM gradle:7.6.1-jdk17
COPY ../../home/gradle/src /home/gradle/src
WORKDIR /home/gradle/src

RUN gradle build
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
