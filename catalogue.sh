#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script excecution started at:: $(date)" | tee -a $LOG_FILE

#checking the user is root user or not
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please Login with root user access $N"| tee -a $LOG_FILE
    exit 1
else
    echo -e "$G Login user is root user $N" | tee -a $LOG_FILE
fi

#this function is used to validate the input return the output
VALIDATE() {
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is......$G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is...... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabiling Node JS"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabiling Nodejs:20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing Node JS"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop already created ... $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip
VALIDATE $? "Downloading catalogie"

rm -rf /app/*
cd /app 
unzip /tmp/catalogue.zip
VALIDATE $? "Unzipping the catalogue"

npm install &>>$LOG_FILE
VALIDATE $? "Installing Dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Adding the system user in catalogu"

systemctl daemon-realod &>>$LOG_FILE
systemctl enable catalogue &>>$LOG_FILE
systemctl start catalogue
VALIDATE $? "Starting catalogue service"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing Mongod client"

STATUS=$(mongosh --host mongodb.maheshdevops.shop --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.maheshdevops.shop </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into MongoDB"
else
    echo -e "Data is already loaded ... $Y SKIPPING $N"
fi

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Time taken to execute the script is:: $Y $TOTAL_TIME $N" | tee -a $LOG_FILE
