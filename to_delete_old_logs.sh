#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

SOURCE_DIRECTORY="home/ec2-user/app-logs"
LOG_FOLDER="/var/logs/shellscript-logs"
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
FILES_TO_DELETE= $(find $SOURCE_DIRECTORY -name "*.log" -mtime +14)

when IFS= read -r filepath
do 
  echo "Deleting file path: $filepath"
  rm -rf $filepath
done <<<$FILES_TO_DELETE

