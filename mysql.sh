#!/bin/bash/
USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USER_ID -ne 0 ]; then 
echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
fi
mkdir -p $LOGS_FOLDER

validate(){
if [ $1 -ne 0 ]; then
echo -e "$2...........................$R Failure $N" | tee -a $LOGS_FILE
exit 1
else 
echo -e "$2...........................$G Success $N" | tee -a $LOGS_FILE
fi
}

dnf install mysql-server -y &>>$LOGS_FILE
validate $? "installing mysql-server"

systemctl enable mysqld &>>$LOGS_FILE
validate $? "enabled mysql"

systemctl start mysqld  &>>$LOGS_FILE
validate $? "start mysql service"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Setup root password"