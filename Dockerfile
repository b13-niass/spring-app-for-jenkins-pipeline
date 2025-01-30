FROM maven:3.8.8-sapmachine-17 AS builder
WORKDIR /builder

COPY pom.xml .
COPY src ./src

RUN mvn clean package

RUN java -Djarmode=layertools -jar target/*.jar extract

FROM bellsoft/liberica-openjre-debian:17-cds
WORKDIR /application

COPY --from=builder /builder/dependencies/ ./
COPY --from=builder /builder/spring-boot-loader/ ./
COPY --from=builder /builder/snapshot-dependencies/ ./
COPY --from=builder /builder/application/ ./

EXPOSE 8080

ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]