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

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Copying mongo repo"

dnf install mongodb-org -y
validate $? "Installing mongodb-server"

systemctl enable mongod
validate $? "enable mongodb"

systemctl start mongod
validate $? "start mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "allowing remote connections"

systemctl restart mongod
validate $? "Restarted mongodb"





