#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOG_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){ 
    if [ $1 -ne 0 ]
  then
     echo -e "$2 ... $R FAILURE $N "
     exit 1
  else
     echo -e "$2...$G success $N"
  fi
}

CHECK_ROOT(){
  if [ $USERID -ne 0 ]
  then
    echo "ERROR:: you must have sudo access to execute the script"  
    exit 1 #other than 0
  fi

}   
 
echo "script started excuting at $TIMESTAMP " &>>$LOG_FILE_NAME 

CHECK_ROOT

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "disableing old nodjs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "ENABLING nodejs"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? " installing nodejs"

useradd expense &>>$LOG_FILE_NAME
VALIDATE $? "user name adding"

mkdir /app &>>$LOG_FILE_NAME
VALIDATE $? "creat app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? " creating zuip file"

cd /app &>>$LOG_FILE_NAME
VALIDATE $? "chainge poguisan"

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzip file"

cd /app &>>$LOG_FILE_NAME
VALIDATE $? "cp"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "installing npm"

cp /home/ec2-user/expense-shell/backend.servece /etc/systemd/system/backend.service &>>$LOG_FILE_NAME
VALIDATE $? " editing config"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "reloding demon"

systemctl start backend &>>$LOG_FILE_NAME
VALIDATE $? "starting backend"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? " enabling backend"

dnf install mysql -y &>>$LOG_FILE_NAME 
VALIDATE $ " installing mysql"

mysql -h mysql.prem.online -uroot -pExpenseApp@1 < /app/schema/backend.sql 
VALIDATE $? "setting root password"

systemctl restart backend 
VALIDATE $? " resetinng backend "
