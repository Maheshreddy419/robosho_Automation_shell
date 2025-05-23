#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/logs/roboshop-logs"
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOG_FOLDER
echo "Starting executing script at:: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please Login with root access $N" | tee -a $LOG_FILE
    exit 1
else
    echo -e "Login User is root user"
fi

VALIDATE(){

    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ....... SUCCESS" | tee -a $LOG_FILE
    else
        echo -e "$2 is ....... FAILURE" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabiling redis"

dnf enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabiling redis"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing redis"

sed -i  's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/  c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Edited redis.conf to accept remote connections"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling Redis"

systemctl start redis  &>>$LOG_FILE
VALIDATE $? "Started Redis"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE