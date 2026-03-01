#!/bin/bash/
USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
MYSQL_HOST="mysql.laddudevops86.fun"

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

dnf install maven -y
validate $? "installing maven"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app 
validate $? "create the directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
validate $? "download the shipping code"

cd /app &>>$LOGS_FILE
validate $? "Moving to app directory"

rm -rf /app/* &>>$LOGS_FILE
validate $? "removing existing code"

unzip /tmp/shipping.zip &>>$LOGS_FILE
validate $? "Unzip shipping code"

mvn clean package 
validate $? "Packages downloading"

mv target/shipping-1.0.jar shipping.jar 
validate $? "Rename the shipping file"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOGS_FILE
validate $? "Create systemctl service"

systemctl daemon-reload
validate $? "daemon-reload"

systemctl enable shipping 
validate $? "enable-shipping"

systemctl start shipping
validate $? "start shipping"

dnf install mysql -y  &>>$LOGS_FILE
VALIDATE $? "Installing MySQL"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]; then

    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOGS_FILE
    VALIDATE $? "Loaded data into MySQL"
else
    echo -e "data is already loaded ... $Y SKIPPING $N"
fi

systemctl enable shipping &>>$LOGS_FILE
systemctl start shipping
VALIDATE $? "Enabled and started shipping"