#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/logs/roboshop.logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOG_FOLDER
echo "Sript execution started at:: $(date)" | tee -a $LOG_FILE

# step to identify the user is root or not
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run the script with root accesss $N" | tee -a $LOG_FILE
    exit 1   #if it is failure exit status will be 1 to 127
else
    echo -e " $G Login user has  Root access $N" | tee -a $LOG_FILE
fi 

#this function is to validate the input and print the output
VALIDATE() {
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ...........$G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ...........$R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

cp mongo.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? "Copying mongo repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB Server"

systemctl enable mongod
VALIDATE $? "Enabeling Mongodb Server" &>>$LOG_FILE

systemctl start mongod
VALIDATE $? "Starting Mongodb Server" &>>$LOG_FILE

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Changing the external connection config"

systemctl restart mongod
VALIDATE $? "Restarting the Mongodb Server" &>>$LOG_FILE