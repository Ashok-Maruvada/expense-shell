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

dnf install mysql-server -y &>>$LOGFILE
validate $? "installing mysql server"

systemctl enable mysqld &>>$LOGFILE
validate $? "Enabling mysql server"

systemctl start mysqld &>>$LOGFILE
validate $? "starting mysql"

# mysql_secure_installation --set-root-password ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "Setting up root password"
# below code is to make script idempotent 

mysql -h 172.31.87.1 -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    validate $? " setting root password "
else
    echo -e " root password is already set up : $G skipping $N "
fi
