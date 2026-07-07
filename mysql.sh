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

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "install mysql"


systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "enabling MYSQL"

systemctl start mysqld  &>>$LOG_FILE_NAME
VALIDATE $? "start server"

# mysql -h mysql.premdas.online -u root -pExpenseApp@1 -e 'show databases;'

# if [ $? -ne 0 ]
# then 
#  echo "MYSQL root passward not setup" &>>$LOG_FILE_NAM
#  mysql_secure_installation --set-root-pass ExpenseApp@1 
#  VALIDATE $? "setting root password "
# else 
#   echo -e "MYSQL root password allredy setup ....$Y SKPPING $N"
# fi  

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "setting root password"