#!/bin/bash
#  	exit code
# exit 29 tar file error
# exit 30 yum error
# exit 31 depending install error
# exit 32 confingure error
# exit 33 make error
# exit 34 make install error


# static variable
NULL=/var/log/error_install_nginx.log
NGINX_INTAR="nginx-1.12.2.tar.gz"

test_yum () {
	yum clean all &> $NULL
	repolist=$(yum repolist | awk  '/repolist:.*/{print $2}' | sed 's/,//')
	if [ $repolist -gt 0 ];then
		return 0
	fi
	return 1
}

print_info () {
	if [ -n "$1" ] && [ -n "$2" ] ;then
		case "$2" in 
		OK)
			echo -e "$1 \t\t\t \e[32;1m[OK]\e[0m"
			;;
		Fail)
			echo -e "$1 \t\t\t \e[31;1m[Fail]\e[0m"
			;;
		*)
			echo "Usage info {OK|Fail}"
		esac
	fi
}

rotate_line(){
	INTERVAL=0.1
	TCOUNT="0"
	while :
	do
		TCOUNT=`expr $TCOUNT + 1`
		case $TCOUNT in
		"1")
			echo -e '-'"\b\c"
			sleep $INTERVAL
			;;
		"2")
			echo -e '\\'"\b\c"
			sleep $INTERVAL
			;;
		"3")
			echo -e "|\b\c"
			sleep $INTERVAL
			;;
		"4")
			echo -e "/\b\c"
			sleep $INTERVAL
			;;
		*)
			TCOUNT="0";;
		esac
	done
}

test_yum
if [ $? -ne 0 ];then
  print_info "yum error." "Fail"
  exit 30
fi

grep nginx /etc/passwd > $NULL
if [ $? -ne 0 ];then
	useradd -s /sbin/nologin/ nginx
fi

rotate_line &
disown $!
yum -y install gcc pcre-devel openssl-devel zlib-devel make > $NULL
result=$?
kill -9 $!
[ $result -eq 0 ] ||  exit 31

if [ -f $NGINX_INTAR ];then
	nginx_indir=$(tar -tf $NGINX_INTAR | head -1 )
	tar -xf $NGINX_INTAR > $NULL
	if [ -d $nginx_indir ];then
		cd $nginx_indir
	else
		print_info "tar file error" "Fail"
		exit 29
	fi
else
	print_info "tar file error" "Fail"
	exit 29
fi

rotate_line &
disown $!

if [ -f configure ];then
	./configure \
	--prefix=/usr/local/nginx \
	--user=nginx \
	--group=nginx \
	--with-pcre \
	--with-http_ssl_module \
	--with-http_v2_module \
	--with-http_realip_module \
	--with-http_addition_module \
	--with-http_sub_module \
	--with-http_dav_module \
	--with-http_flv_module \
	--with-http_mp4_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_random_index_module \
	--with-http_secure_link_module \
	--with-http_stub_status_module \
	--with-http_auth_request_module \
	--with-http_image_filter_module \
	--with-http_slice_module \
	--with-mail \
	--with-threads \
	--with-file-aio \
	--with-stream \
	--with-mail_ssl_module \
	--with-stream_ssl_module  > $NULL
	result=$?
	kill -9 $!

	if [ $result -eq 0 ];then
		rotate_line &
		disown $!
		make &>/dev/null && make install &>/dev/null
		result=$?
		kill -9 $!
		echo 'PATH=$PATH:/usr/local/nginx/sbin/' >> /etc/profile
		source /etc/profile
		if [ $result -eq 0 ];then
			print_info "Nginx Install" "OK"
		else
			print_info "make | make install" "Fail"
			exit 33
		fi
	else	
		print_info "confingure error" "Fail"
		exit 32
	fi
else 
	print_info "confingure error" "Fail"
	exit 32
fi

#installed configure
#安装完之后，将nginx添加到PATH路径中
ln -s /usr/local/nginx/sbin/nginx /usr/sbin/
#可以使用netstat -anptu | grep nginx 测试

