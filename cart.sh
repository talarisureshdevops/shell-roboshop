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

dnf module disable nodejs -y &>>$LOGS_FILE
validate $? "disabled nodejs old versions"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
validate $? "enable nodejs:20"

dnf install nodejs -y &>>$LOGS_FILE
validate $? "installing nodejs"


id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGS_FILE
validate $? "creating app directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOGS_FILE
validate $? "downloading cart code"

cd /app &>>$LOGS_FILE
validate $? "Moving to app directory"

rm -rf /app/* &>>$LOGS_FILE
validate $? "removing existing code"

unzip /tmp/cart.zip &>>$LOGS_FILE
validate $? "Unzip catalogue code"

npm install &>>$LOGS_FILE
validate $? "installing Dependencies"

cp $SCRIPT_DIR/cat.service /etc/systemd/system/cart.service &>>$LOGS_FILE
validate $? "Create systemctl service"

systemctl daemon-reload &>>$LOGS_FILE
validate $? "daemon-reload"

systemctl enable cart &>>$LOGS_FILE
validate $? "enable cat"

systemctl start cart &>>$LOGS_FILE
validate $? "start cart"

