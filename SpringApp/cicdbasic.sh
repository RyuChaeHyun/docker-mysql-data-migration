#!/bin/bash

# 변수 설정
JAR_FILE="/var/jenkins_home/appjar/SpringApp-0.0.1-SNAPSHOT.jar"
DEPLOY_DIR="/var/jenkins_home/deploy"

# 배포 디렉토리 생성
mkdir -p $DEPLOY_DIR

# 새로운 JAR 파일 복사
cp $JAR_FILE $DEPLOY_DIR/

# Spring Boot 애플리케이션 재시작
# 기존 8080 포트 사용 중인 프로세스 종료 (lsof 대신 다른 방법 사용)
PID=$(netstat -tlnp | grep :8080 | awk '{print $7}' | cut -d'/' -f1)
if [ ! -z "$PID" ]; then
    kill $PID
fi

# 백그라운드에서 새로 실행
nohup java -jar $DEPLOY_DIR/$(basename $JAR_FILE) > $DEPLOY_DIR/app.log 2>&1 &

echo "배포완료 및 실행됩니다."
