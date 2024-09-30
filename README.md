# 💫 MySQL 데이터 백업 및 복구 자동화 전략

“ 데이터 손실 방지 및 신속한 복구를 위한 자동화 시스템 구축 "

날짜: 2024년 9월 27일


<br> 

## 📌 개요

본 프로젝트는 **Docker와 Crontab을 활용**하여 **MySQL 데이터베이스의 자동화된 백업 시스템을 구축**하는 것을 목표로 하였습니다. **데이터 손실 방지를 위해 정기적으로 데이터 백업을 수행**하고, 필요 시 **수동으로 복구할 수 있는 효율적인 프로세스**를 설정하였습니다.  

<br> 

## 🐢 주제 선택 이유?

현대 기업에서는 데이터의 안정성과 가용성이 비즈니스 성공의 핵심 요소로 자리 잡고 있습니다. **데이터 유출이나 손실은 운영 중단과 재정적 손실을 초래**할 수 있으며, **고객 신뢰도에도 부정적인 영향**을 미칩니다. 특히 금융, 의료, 물류 산업 등에서는 데이터의 무결성이 법적 요구사항이기도 합니다.  

이러한 배경 속에서, 자동화된 백업과 복구 시스템은 데이터 보호와 신속한 대응을 가능하게 하여, 기업의 IT 운영을 더욱 안정적으로 만들어줄 것입니다.


<br> 


## 🎖️ 주요 기능

1. **자동화된 백업 프로세스 구축**: Crontab을 통해 정해진 시간마다 MySQL 데이터베이스의 백업을 자동으로 수행하여 데이터 손실을 예방하고, 시스템 운영의 안정성을 향상

2. **신속한 복구 시스템 구현**: 데이터 복구 프로세스를 수동으로 설정하여 장애 발생 시 빠른 데이터 복구가 가능하도록 하여 비즈니스 연속성을 유지한다.
   
3. **효율적인 데이터 관리**: Docker Compose를 활용하여 MySQL 컨테이너를 구성하고, 서비스 간의 의존성을 간편하게 관리함으로써 데이터베이스 운영의 효율성을 극대화한다.



<br> 

## 📊 프로젝트 과정

### 📤 데이터 내보내기

<br>

1. 두 개의 MySQL 서비스를 띄우기 위해 docker-compose.yml 파일을 작성한다.

**docker-compose.yml**

```yaml
services:
  db:
    container_name: mysqldb
    image: mysql:latest
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: fisa
      MYSQL_USER: user01
      MYSQL_PASSWORD: user01
    networks:
      - spring-mysql-net
    healthcheck:
      test: ['CMD-SHELL', 'mysqladmin ping -h 127.0.0.1 -u root --password=$$MYSQL_ROOT_PASSWORD']
      interval: 10s
      timeout: 2s
      retries: 100
      
  db2:
      container_name: mysqldb2
      image: mysql:latest
      ports:
        - "3307:3306"  # 두 번째 MySQL 컨테이너는 3307 포트를 사용
      environment:
        MYSQL_ROOT_PASSWORD: root
        MYSQL_DATABASE: fisa2
        MYSQL_USER: user02
        MYSQL_PASSWORD: user02
      networks:
        - spring-mysql-net
      healthcheck:
        test: ['CMD-SHELL', 'mysqladmin ping -h 127.0.0.1 -u root --password=$$MYSQL_ROOT_PASSWORD']
        interval: 10s
        timeout: 2s
        retries: 100

networks:
  spring-mysql-net:
    driver: bridge  # 네트워크 드라이버 정의

```

2. 새로운 컨테이너에 대한 포트포워딩을 한다.
    
    **3307:3306**
   
    ![image](https://github.com/user-attachments/assets/7004d183-a2f8-4c1b-ad01-e89929490122)


    

2. mysql 을 docker-compose로  실행시킨다.
    
    ```yaml
    docker-compose up -d
    ```
    
   


3. 첫번째 mysqldb 의 컨테이너에 접속하여 데이터를 넣는다.
    
    ```yaml
    docker ps
    
    docker exec -it 6eabbe5d245e /bin/bash
    
    mysql -u root -p
    
    use fisa;
    
    CREATE TABLE employees (
        ->     id INT AUTO_INCREMENT PRIMARY KEY,
        ->     name VARCHAR(50),
        ->     age INT,
        ->     position VARCHAR(50)
        -> );
        
     INSERT INTO employees (name, age, position)
        -> VALUES ('John Doe', 30, 'Software Engineer'),
        ->        ('Jane Smith', 25, 'Designer'),
        ->        ('Sam Brown', 28, 'Project Manager');
        
     select * from employees;
    ```
 ![image 1](https://github.com/user-attachments/assets/564d8015-358b-4f26-8550-dfc128489748)
    
4. mysql bash 에서 나와서 mysql 컨테이너 bash에서 데이터를 내보낸다.
    
    ```yaml
    # mysqldump -uroot -p [Database-Name] > /tmp/[File-Name].sql
    
    mysqldump -uroot -p fisa > /tmp/dumpTest.sql
    
    ```

  
    
5. 해당 경로에 생성되었는지 확인한다.
    
    ```yaml
    ls -al /tmp
    ```
  ![image 2](https://github.com/user-attachments/assets/fd72c7c2-4f93-44ea-91c4-53a2612e23ce)

<br>
    
6. 생성된 sql 덤프문을 docker container 밖으로 복사한다.
    
    ```yaml
    docker cp 6eabbe5d245e:/tmp/dumpTest.sql ~/step06Compose/GetDump
    ```
    

 ![image](https://github.com/user-attachments/assets/127c3ba5-4253-4ccf-bda7-155dae791e72)

<br>

### 📩 데이터 받아오기

1. 새로운 mysql 컨테이너에 데이터를 받아오기 위해 PC의 export 된 SQL File을 Docker안으로 복사한다.
    
    ```yaml
    docker cp ~/step06Compose/GetDump/dumpTest.sql 8785ede23ae5:/tmp
    ```
    
2. docker mysql 에 /bin/bash  접속을 하고 기존 컨테이너에서 덤프한 데이터를 import 한다.
    
    ```yaml
    docker exec -it 8785ede23ae5 /bin/bash
    
    bash-5.1# mysql -u root -p
    
    mysql -u root -p fisa2 < /tmp/dumpTest.sql
    ```
    
3. 제대로 데이터가 받아와졌는지 확인한다.
    
    ```yaml
    mysql -u root -p
    
    use fisa2;
    
    select * from employees;
    ```

<br>

### ✍️ 백업 자동화를 위한 bash 스크립트 작성

1. 백업을 위한 스크립트를 작성한다.
    
    **backup.sh**
    
    ```yaml
    #!/bin/bash
    
    # 백업할 데이터베이스 정보
    DB_NAME="fisa"
    DB_USER="root"
    DB_PASSWORD="root"
    BACKUP_DIR="/tmp/backup"  # 백업 파일이 저장될 경로
    
    # 백업 디렉토리 생성 (존재하지 않을 경우)
    mkdir -p $BACKUP_DIR
    
    # 현재 날짜를 포맷팅
    DATE=$(date +"%Y%m%d%H%M")
    
    # 백업 파일 이름 설정
    BACKUP_FILE="$BACKUP_DIR/$DB_NAME-$DATE.sql"
    
    # MySQL 덤프 수행 (Docker를 사용하여)
    docker exec mysqldb /usr/bin/mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_FILE
    
    # 백업 성공 여부 확인
    if [ $? -eq 0 ]; then
        echo "백업 성공: $BACKUP_FILE"
    else
        echo "백업 실패"
    fi
    
    ```
    
    도커로 mysql 을 실행하고 있기 때문에 덤프 수행 메시지가 `docker exec mysqldb /usr/bin/mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_FILE` 로 작성해야 한다.


  <br>
  
2. 백업 디렉토리를 생성한다.
    
    ```yaml
    mkdir -p /tmp/backup
    ```

   <br>

### ✍️ 장애 발생 시 복구을 위한 bash 스크립트 작성

1. 복구을 위한 스크립트를 작성한다.
    
    **restore.sh**
    
    ```yaml
    #!/bin/bash
    
    # 복구할 데이터베이스 정보
    DB_NAME="fisa2"  # 복구할 데이터베이스 이름
    DB_USER="root"
    DB_PASSWORD="root"
    BACKUP_DIR="/tmp/backup"  # 백업 파일이 저장된 디렉토리
    
    # 가장 최근 백업 파일 찾기
    BACKUP_FILE=$(ls -t $BACKUP_DIR/*.sql | head -n 1)
    
    # 최근 백업 파일이 존재하는지 확인
    if [ -z "$BACKUP_FILE" ]; then
        echo "복구할 백업 파일이 없습니다."
        exit 1
    fi
    
    # MySQL에 데이터베이스 복원 (Docker를 사용하여)
    docker exec -i mysqldb2 /usr/bin/mysql -u $DB_USER -p$DB_PASSWORD $DB_NAME < "$BACKUP_FILE"
    
    # 복구 성공 여부 확인
    if [ $? -eq 0 ]; then
        echo "복구 성공: $BACKUP_FILE"
    else
        echo "복구 실패"
    fi
    
    ```
    
    - 복구를 할 새로운 컨테이너 이름을 지정해야 한다.
    
    - 가장 최근에 백업된 sql 문을 찾아서 복구하도록 설정했다.
    
<br>

2. 스크립트에 대한 실행 권한을 부여합니다.

```yaml
chmod +x backup.sh restore.sh
```

<br>

### 🕞 crontab 설정

1. mysql 덤프 자동화를 위해 crontab 설정을 해줍니다.

```yaml
57 15 * * * /home/username/backup.sh
```

<br>

2. 3시 57분에 `backup.sh` 스크립트를 실행하도록 crontab을 설정했다.

   <br>

**백업 성공**

![image 3](https://github.com/user-attachments/assets/504305eb-6a72-48a3-ab32-0312c5a62cee)


**복구 성공**

![image 4](https://github.com/user-attachments/assets/cdd0b2ce-59ff-4a5a-a62b-060045b3cb1b)


![image 5](https://github.com/user-attachments/assets/bbcae1e2-fe6a-4e41-940e-65a40601ec0d)


### 🏆 실험

기존 테이블에 데이터를 추가하고, 새로운 테이블을 만들어도 백업과 복구가 되는지 실험해봤다.

- mysql1에 데이터를 추가했고, 새로운 테이블을 만들었다.
  
<br>

**데이터 추가**

![image 6](https://github.com/user-attachments/assets/a189112d-858e-4a86-8a69-0fba0599f663)


**테이블 추가**

![image 7](https://github.com/user-attachments/assets/2ffb2da8-c43d-415f-930d-7ab603f5da09)


설정한 시간에 백업이 되었고, 가장 최근에 백업된 파일을 찾아서 복구되는지 확인한다.

<br>

**결과**
<br>
crontab에서 설정한 시간에 백업이 된다.

![image 8](https://github.com/user-attachments/assets/48656bfe-1923-4031-a71f-75d04105d9ff)


![image 9](https://github.com/user-attachments/assets/5b389149-cac9-448d-80ee-87577d95e409)


모두 반영이 되었다.

![image 10](https://github.com/user-attachments/assets/116b66d5-7989-4fd8-b896-d230e92df09a)

![image 11](https://github.com/user-attachments/assets/b25a0bf2-e545-41d0-8c2f-9daa29f5741b)


## 🧐 결론
이 프로젝트를 통해 Docker와 cron을 활용한 MySQL 데이터의 자동 백업 시스템을 성공적으로 구축하였습니다. 

- **정기적인 데이터 백업**: cron을 통해 자동으로 데이터 백업이 이루어지며, 설정한 시간에 백업 파일이 생성됩니다.
- **간편한 데이터 복구**: 새로운 MySQL 컨테이너에 기존 데이터베이스를 손쉽게 복원할 수 있는 시스템이 구축되었습니다.
- **데이터 관리 용이**: 백업 파일은 호스트 머신의 특정 디렉토리에 저장되어 관리가 용이합니다.

그러나 모니터링 및 알림 기능, 백업 주기 조정 기능, 복구 절차의 자동화 부족 등 개선할 점이 발견되었습니다. 향후에는 이러한 기능들을 추가하여 시스템의 효율성을 높이고 사용자 경험을 개선할 수 있는 방향으로 나아가야 할 것입니다.

<br>

## 🤔 아쉬웠던 점
- **모니터링 및 알림 기능 부족**: 백업 및 복구 작업의 성공 여부를 확인하는 모니터링 시스템이 없기 때문에, 백업 실패 시 적시에 알림을 받을 수 없습니다.
- **백업 주기 조정 기능 부재**: 현재 설정된 주기 외에 사용자가 필요에 따라 백업 주기를 조정할 수 있는 기능이 없습니다.
- **복구 절차의 자동화 부족**: 현재 복구 과정은 수동으로 수행해야 하므로, 사용자가 원하는 시점에 자동으로 복구할 수 있는 옵션을 추가할 필요가 있습니다.

<br>
