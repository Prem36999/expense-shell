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

dnf install nginx -y &>>$LOG_FILE_NAME
VALIDATE $? "installing nginx" &>>$LOG_FILE_NAME

systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "ennableing nginx server"

systemctl start nginx &>>$LOG_FILE_NAME
VALIDATE $? "starting nginx server"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
VALIDATE $? "removing old versen"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2. &>>$LOG_FILE_NAME
VALIDATE $? "donwloding new code"

cd /usr/share/nginx/html &>>$LOG_FILE_NAME
VALIDATE $? " chaing pozision"


unzip /tmp/frontend.zip
VALIDATE $? "unzipping"

cp home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE_NAME
VALIDATE $? "editing congig"

systemctl restart nginx 
VALIDATE $? " restarting nginx"