#!/bin/bash

userid=$(id -u)
timestamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$script_name-$timestamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf install nginx -y &>>$LOGFILE
validate $? "installing nginx"

systemctl enable nginx &>>$LOGFILE
validate $? "enabling nginx"

systemctl start nginx &>>$LOGFILE
validate $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
validate $? "removing default content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
validate $? "downloading frontend code"

cd /usr/share/nginx/html &>>$LOGFILE
unzip /tmp/frontend.zip &>>$LOGFILE
validate $? "unzipping the code "

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
validate $? "coping expense code"

systemctl restart nginx &>>$LOGFILE
validate $? "restarting nginx"
