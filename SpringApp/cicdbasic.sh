#!/bin/bash

# 변수 설정
JAR_FILE="SpringApp-0.0.1-SNAPSHOT.jar"
DEPLOY_DIR="/home/username/step07cicd"

# 이전 JAR 파일 백업
if [ -f "$DEPLOY_DIR/$JAR_FILE" ]; then
  mv "$DEPLOY_DIR/$JAR_FILE" "$DEPLOY_DIR/$JAR_FILE.bak"
fi

# 새로운 JAR 파일 복사
# 이 스크립의 위치는 어디에 개발되어야 하나?
cp $JAR_FILE $DEPLOY_DIR/$JAR_FILE

# Spring Boot 애플리케이션 재시작
# 기존 8080 포트 사용 중인 프로세스 종료
if sudo lsof -i :8080 > /dev/null; then
  # 8080 포트가 사용 중일 경우 이전 프로세스를 종료
  sudo kill -9 $(sudo lsof -t -i:8080)
fi

# 백그라운드에서 새로 실행
# > $DEPLOY_DIR/app.log : 애플리케이션 로그를 app.log 파일에 저장하도록 구성
# 정상 데이터 출력이 아닌 에러 메세지도 app.log에 출력 
nohup java -jar $DEPLOY_DIR/$JAR_FILE > $DEPLOY_DIR/app.log 2>&1 &

echo "배포완료 및 실행됩니다."
