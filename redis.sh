#!/bin/bash/
USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"

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

dnf module disable redis -y &>>$LOGS_FILE
validate $? "disabled older versions"

dnf module enable redis:7 -y &>>$LOGS_FILE
validate $? "enabled the redis:7"

dnf install redis -y  &>>$LOGS_FILE
validate $? "installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf &>>$LOGS_FILE

VALIDATE $? "Allowing remote connections"

systemctl enable redis &>>$LOGS_FILE
validate $? "enable redis"

systemctl start redis  &>>$LOGS_FILE
validate $? "start redis"


