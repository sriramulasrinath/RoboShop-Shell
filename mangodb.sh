#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copied mongo repo"

dnf install mongodb-org -y  &>> $LOGFILE
VALIDATE $? "installed mangodb"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "enabled mangodb"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "starting mangodb"

sed -i 's/ 127.0.0.1 to 0.0.0.0/g' /etc/mangod.conf &>> $LOGFILE
VALIDATE $? "Remote server access"

systemctl restart mongod
VALIDATE $? "restarted mangodb"