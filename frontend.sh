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

VALIDATE() {
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ...........$G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ...........$R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf module disable nginx -y $>>$LOG_FILE
VALIDATE $? "Disabiling nginx"

dnf module enable nginx:1.24 -y $>>$LOG_FILE
VALIDATE $? "Enabiling  module nginx1.24"

dnf install nginx -y $>>$LOG_FILE
VALIDATE $? "Installing nginx 1.24"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enable nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Removing nginx default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Downloading frontend service"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzipping frontend"

rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Remove default nginx conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying nginx.conf"

systemctl restart nginx 
VALIDATE $? "Restarting nginx"