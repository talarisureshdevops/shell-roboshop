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

dnf install python3 gcc python3-devel -y
validate $? "installing python"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app 
validate $? "Create the directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip
validate $? "Download the payment code"


cd /app &>>$LOGS_FILE
validate $? "Moving to app directory"

rm -rf /app/* &>>$LOGS_FILE
validate $? "removing existing code"

unzip /tmp/payment.zip &>>$LOGS_FILE
validate $? "Unzip catalogue code"

cd /app 
pip3 install -r requirements.txt &>>$LOGS_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Created systemctl service"

systemctl daemon-reload
systemctl enable payment &>>$LOGS_FILE
systemctl start payment
VALIDATE $? "Enabled and started payment"
