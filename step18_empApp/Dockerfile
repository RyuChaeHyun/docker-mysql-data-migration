# 1. 빌드 단계
FROM openjdk:17-slim
WORKDIR /app
COPY step03_probono-0.0.1-SNAPSHOT.jar app.jar

# 2. 실행 단계
FROM openjdk:17-slim
WORKDIR /app
COPY --from=0 /app/app.jar app.jar

# JVM 최적화 옵션 추가
ENTRYPOINT ["java", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]