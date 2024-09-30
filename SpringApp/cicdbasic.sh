#!/bin/bash

JAR_FILE=$1  # 첫 번째 인자로 전달된 JAR 파일 경로
DEPLOY_DIR="/home/username/step07cicd"  # 실제 배포할 디렉토리
PORT=8889  # 사용할 포트 번호

# 배포 디렉토리 생성
mkdir -p $DEPLOY_DIR

# 이전 JAR 파일 백업
if [ -f "$DEPLOY_DIR/$(basename $JAR_FILE)" ]; then
  mv "$DEPLOY_DIR/$(basename $JAR_FILE)" "$DEPLOY_DIR/$(basename $JAR_FILE).bak"
fi

# 새로운 JAR 파일 복사
cp $JAR_FILE $DEPLOY_DIR/

# Spring Boot 애플리케이션 재시작
# 기존 포트 사용 중인 프로세스 종료
if lsof -i :$PORT > /dev/null; then
  kill $(lsof -t -i:$PORT)
fi

# 백그라운드에서 새로 실행
nohup java -jar $DEPLOY_DIR/$(basename $JAR_FILE) --server.port=$PORT > $DEPLOY_DIR/app.log 2>&1 &

echo "배포완료 및 실행됩니다. 포트: $PORT"
