#!/bin/bash

userid=$(id -u)
timestamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$script_name-$timestamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo " please enter DB password"
read -s mysql_root_password
validate(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 : $R failed $N "
        exit 1
    else
        echo -e "$2 : $G sucees $N "
    fi
}
if [ $userid -ne 0 ]
then
    echo "please use root access"
    exit 1
else
    echo " u are super user"
fi

dnf module disable nodejs -y &>>$LOGFILE
validate $? "disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
validate $? "enabling nodejs:20 version "

dnf install nodejs -y &>>$LOGFILE
validate $? "installing nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense
    validate $? " creating user: expense"
else 
    echo -e " user expense is already exist: $Y skipping $N "
fi

mkdir -p /app
validate $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
validate $? "downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip
validate $? "unzipping backend code to app dir"

npm install
validate $? "installing nodejs dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service
validate $? "copied backend service"

systemctl daemon-reload &>>$LOGFILE
validate $? "reloading daemon service"

systemctl start backend &>>$LOGFILE
validate $? "starting backend"

systemctl enable backend &>>$LOGFILE
validate $? "enabling backend"

dnf install mysql -y &>>$LOGFILE
validate $? "installing mysql client"

mysql -h 172.31.87.240 -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
validate $? "loading schema"

systemctl restart backend &>>$LOGFILE
validate $? "restarting the backend"
