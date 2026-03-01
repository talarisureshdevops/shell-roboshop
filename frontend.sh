#!/bin/bash/

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
MONGODB_HOST="mongodb.laddudevops86.fun"

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

dnf module list nginx
validate $? "module list nginx"

dnf module disable nginx -y
validate $? "disable old nginx version"

dnf module enable nginx:1.24 -y
validate $? "enable nginx latest version"

dnf install nginx -y
validate $? "installing nginx "

systemctl enable nginx 
systemctl start nginx 
validate $? "start nginx "

rm -rf /usr/share/nginx/html/* 

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip  &>>$LOGS_FILE
validate $? "download the frontend code"


cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOGS_FILE
VALIDATE $? "Downloaded and unzipped frontend"

rm -rf /etc/nginx/nginx.conf  &>>$LOGS_FILE

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copied our nginx conf file"

systemctl restart nginx
VALIDATE $? "Restarted Nginx"
