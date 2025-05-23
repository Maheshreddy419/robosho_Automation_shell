#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/logs/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOG_FOLDER
echo "Script execution started at $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]
then
    echo "$R ERROR:: Please Login with Root User access $N" | tee -a $LOG_FILE
    exit 1
else
    echo "Login user has Root access...." | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is......$G Success $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is........ $R Failure $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabiling node js"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabiling Nodejs 20"

dnf install nodejs -y&>>$LOG_FILE
VALIDATE $? "Node Js Installation"

id roboshop
if [ $? -ne 0 ]
then
   useradd --system --home /app -shell /sbin/nologin/ --comment "Roboshop User" roboshop&>>$LOG_FILE
   VALIDATE $? "roboshop user creation"
else
    echo -e "User already Exists.... $Y skipping new user creation $N"&>>$LOG_FILE
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip
VALIDATE $? "Downloading user service"

rm -rf /app/*
cd /app
unzip /tmp/user.zip
VALIDATE $? "Unzipping user service"

npm install
VALIDATE $? "Installing Dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Copying user service"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable user  &>>$LOG_FILE
systemctl start user
VALIDATE $? "Starting user"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Time taken to execute the script is:: $Y $TOTAL_TIME $N" | tee -a $LOG_FILE