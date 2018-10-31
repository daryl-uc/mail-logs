#! /bin/bash

SERVICE="postfix";
GMAIL_AUTHENTICATION="/etc/postfix/sasl_passwd";
POSTFIX_CONFIG="/etc/postfix/main.cf";

function checkServiceExist() {
	ps auwx | grep $1 | grep -v grep > /dev/null
	if [ $? != 0 ]
	then
		echo $1" not installed";
		echo "Installing postfix and mailutils";
#		apt-get update;
		apt-get install postfix mailutils;
		read -p "Enter the from email address: " fromEmail;
		read -p "Enter the from email address password: " fromEmailPass;
		echo "[smtp.gmail.com]:587    " $fromEmail ":" $fromEmailPass >> $GMAIL_AUTHENTICATION;
		chmod 600 $GMAIL_AUTHENTICATION;
		echo "relayhost = [smtp.gmail.com]:587" >> $POSTFIX_CONFIG;
		echo "smtp_use_tls = yes" >> $POSTFIX_CONFIG;
		echo "smtp_sasl_auth_enable = yes" >> $POSTFIX_CONFIG;
		echo "smtp_sasl_security_options =" >> $POSTFIX_CONFIG;
		echo "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd" >> $POSTFIX_CONFIG;
		echo "smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt" >> $POSTFIX_CONFIG;
		postmap /etc/postfix/sasl_passwd;
		systemctl restart postfix.service;
		# install and config the postfix file
		exit 0;
	fi;
}


function checkConfig() {
	echo "checking the config files";
	if [ -e ./mailInfo.conf ]
	then
    	echo "Fetching data from config file";
		sendMessage;

	else
    	echo "file doesnot exist";
		echo "creating config file";
		read -p "Enter the email address to send the daily logs: " userEmail;
		read -p "Enter the path to read the logs from: " pathToLog;
		read -p "Enter the log file name: " logFileName;
		echo "email="$userEmail >> mailInfo.conf;
		echo "path="$pathToLog >> mailInfo.conf;
		echo "file="$logFileName >> mailInfo.conf;
		echo "config file is created."
		sendMessage;
	fi
}

function sendMessage() {
	source ./mailInfo.conf;
	echo "fetching log data from path" $path;
	#mail -s "Daily Logs" $email < $path$file;
	echo "Mail Sent";
}

checkServiceExist $SERVICE;
checkConfig;
