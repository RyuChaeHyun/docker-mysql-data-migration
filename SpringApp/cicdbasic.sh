#!/bin/bash

# 변수 설정
JAR_FILE="/var/jenkins_home/appjar/SpringApp-0.0.1-SNAPSHOT.jar"
DEPLOY_DIR="/home/username/step07cicd"

# 배포 디렉토리 생성
mkdir -p $DEPLOY_DIR

# 새로운 JAR 파일 복사
cp $JAR_FILE $DEPLOY_DIR/

# Spring Boot 애플리케이션 재시작
# 기존 8080 포트 사용 중인 프로세스 종료
if lsof -i :8080 > /dev/null; then
    kill $(lsof -t -i:8080)
fi

# 백그라운드에서 새로 실행
nohup java -jar $DEPLOY_DIR/$(basename $JAR_FILE) > $DEPLOY_DIR/app.log 2>&1 &

echo "배포완료 및 실행됩니다."
