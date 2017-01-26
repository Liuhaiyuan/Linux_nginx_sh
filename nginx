#!/bin/bash
#chkconfig: - 80 90
#STATIC VARIABLE
NGINX_PID_FILE=/usr/local/nginx/logs/nginx.pid
SERVICE_NAME=nginx
RETVAL=0
EXIST_PID=2
UNEXIST_PID=1

start_nginx="/usr/local/nginx/sbin/nginx"
stop_nginx="nginx -s stop"
#FUNCTION


#Judge pid_file if exist , if exist return 1
nginxpid (){
	if [ -f $NGINX_PID_FILE ];then
		return $EXIST_PID
	else
		return $UNEXIST_PID
	fi
}

start (){
	nginxpid
	if [ $? -eq $EXIST_PID ];then
		echo -e "Starting $SERVICE_NAME \t\t \e[31;1m[Fail]\e[0m"
		echo -e "$SERVICE_NAME already running..."
	else
		$start_nginx
		sleep 0.5
		echo -en "Starting $SERVICE_NAME \t\t"
		nginxpid
		if [ $? -eq $EXIST_PID ];then
			echo -e "\e[32;1m[OK]\e[0m"
		else 
			echo -e "\e[31;1m[Fail]\e[0m"
		fi
	fi
}

stop (){
	nginxpid
	if [ $? -eq $UNEXIST_PID ];then
		echo -e "Stopping $SERVICE_NAME \t\t \e[31;1m[Fail]\e[0m"
		echo -e "$SERVICE_NAME already stopping."
	else
		$stop_nginx
		sleep 0.5
		echo -en "Stopping $SERVICE_NAME \t\t"
		nginxpid
		if [ $? -eq $UNEXIST_PID ];then
			echo -e "\e[32;1m[OK]\e[0m"
		else 
			echo -e "\e[31;1m[Fail]\e[0m"
		fi
	fi
}

reload () {
	nginx -s reload
	[ $? -eq 0 ] &&  echo -e "reload $SERVICE_NAME \t\t  \e[32;1m[OK]\e[0m" || echo -e "reload $SERVICE_NAME \t\t \e[31;1m[Fail]\e[0m"
}

status () {
	if [ -f $NGINX_PID_FILE ];then
		echo -e "$SERVICE_NAME service is running.\n"
	else
		echo -e "$SERVICE_NAME service is stoping.\n"
	fi
}

case $1 in
start)
	start
	;;
stop)
	stop
	;;
restart)
	stop
	start
	;;
status)
	status
	;;
reload)
	reload
	;;
*)
	echo "Usage: nginx {start|stop|restart|status|reload}"
	;;
esac
exit $RETVAL
