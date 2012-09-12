#!/bin/bash

# package name
JDK_TAR_PACKAGE="jdk1.6.0_26.tar.gz"
HADOOP_TAR_PACKAGE="hadoop-0.20.2-cdh3u0.tar.gz"
ANT_TAR_PACKAGE="apache-ant-1.8.4.tar.gz"
LZO_TAR_PACKAGE="lzo-2.04.tar.gz"

HADOOP_LZO_PACKAGE="hadoop-lzo"
HADOOP_LZO_DEPENDENCY_PACKAGE="hadoop-lzo-dependency"
HADOOP_LZO_BUILD_PACKAGE="hadoop-lzo-build"

JDK_PACKAGE=${JDK_TAR_PACKAGE%.*.*}
HADOOP_PACKAGE=${HADOOP_TAR_PACKAGE%.*.*}
ANT_PACKAGE=${ANT_TAR_PACKAGE%.*.*}
LZO_PACKAGE=${LZO_TAR_PACKAGE%.*.*}


BASE_DIR=`dirname "$0"`
BASE_DIR=`cd "${BASE_DIR}"; pwd`
OS_BIT=$(getconf LONG_BIT)


#help
function help(){
	echo "Usage:" 
	echo "  sudo ./install-hadoop.sh COMMAND"
    echo "COMMAND:"
    echo "  -install				install hadoop and its dependency"
    echo "  -install_no_hadoop_lzo 	install hadoop and its dependency but not use ant to compile hadoop-lzo,use local replace"
    echo "  -clean   				clean"

	echo "  -install_jdk   			only install jdk"
	echo "  -install_ant   			only install ant"
	echo "  -install_hadoop     	only install hadoop"
	echo "	-install_lzo			only install lzo"
	echo "	-install_hadoop_lzo		only install hadoop-lzo"
}

function check_jdk() {
	echo "start checking jdk ..."
 	if [ ! -f "${BASE_DIR}/dependency/${JDK_TAR_PACKAGE}" ]; then
		echo "jdk library not exists"
		exit 1
	fi
	
	if [ !$JDK_PACKAGE ]; then
		JDK_PACKAGE=${JDK_TAR_PACKAGE%.*.*}
	fi

	if [ -d "${BASE_DIR}/dependency/${JDK_PACKAGE}" ]; then
		rm -rf "${BASE_DIR}/dependency/${JDK_PACKAGE}"
	fi
	echo "finish checking jdk"
}



function check_hadoop() {
	echo "start checking hadoop ..."
 	if [ ! -f "${BASE_DIR}/${HADOOP_TAR_PACKAGE}" ]; then
		echo "jdk library not exists"
		exit 1
	fi

	if [ !$HADOOP_PACKAGE ]; then
		HADOOP_PACKAGE=${HADOOP_TAR_PACKAGE%.*.*}
	fi

	if [ -d "${BASE_DIR}/${HADOOP_PACKAGE}" ]; then
		rm -rf "${BASE_DIR}/${HADOOP_PACKAGE}"
	fi
	echo "finish checking hadoop"
}

function check_ant(){
	echo "start checking ant ..."
 	if [ ! -f "${BASE_DIR}/dependency/${ANT_TAR_PACKAGE}" ]; then
		echo "ant library not exists"
		exit 1
	fi

	if [ !$ANT_PACKAGE ]; then
		ANT_PACKAGE=${ANT_TAR_PACKAGE%.*.*}
	fi

	if [ -d "${BASE_DIR}/dependency/${ANT_PACKAGE}" ]; then
		rm -rf "${BASE_DIR}/dependency/${ANT_PACKAGE}"
	fi
	echo "finish checking ant"
}

function check_lzo(){
	echo "start checking lzo ..."
 	if [ ! -f "${BASE_DIR}/dependency/${LZO_TAR_PACKAGE}" ]; then
		echo "lzo library not exists"
		exit 1
	fi
	
	if [ !$LZO_PACKAGE ]; then
		LZO_PACKAGE=${LZO_TAR_PACKAGE%.*.*}
	fi

	if [ -d "${BASE_DIR}/dependency/${LZO_PACKAGE}" ]; then
		rm -rf "${BASE_DIR}/dependency/${LZO_PACKAGE}"
	fi
	echo "finish checking lzo"
}

function check_hadoop_lzo(){
	echo "start checking hadoop lzo ..."
	if [ ! -d "${BASE_DIR}/dependency/${HADOOP_LZO_PACKAGE}" ]; then
		echo "hadoop-lzo library not exists"
		exit 1
	fi
	echo "finish checking hadoop lzo"
}


# check all
function check_all(){
	echo "start checking dependent library"
	check_jdk
	check_hadoop
	check_ant
	check_lzo
	check_hadoop_lzo
	echo "finish checking dependent library"
}


#install jdk
function install_jdk(){
	echo "=========================== start installing jdk ====================================="
	
	check_jdk	

	cd "${BASE_DIR}/dependency/" 
	tar xzf ${JDK_TAR_PACKAGE} 

	if [ -d "${BASE_DIR}/dependency/java" ]; then
		sudo rm -rf ${BASE_DIR}/dependency/java
	fi   
	mv ${JDK_PACKAGE} java
	sudo cp -r java /opt/
	sudo echo "export JAVA_HOME=/opt/java" >> "/etc/profile"
	sudo echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> "/etc/profile"
	source /etc/profile

	echo "============================= finish installing jdk ==================================="
}

#install ant
function install_ant(){
	echo "=========================== start installing ant ====================================="
	
	check_ant	

	cd "${BASE_DIR}/dependency/" 
	tar xzf ${ANT_TAR_PACKAGE} 
	
	if [ $? -ne 0 ] ; then
        echo "Fail to decompress ${ANT_TAR_PACKAGE}"
        exit 1
    fi
	
	if [ -d "${BASE_DIR}/dependency/ant" ]; then
		sudo rm -rf ${BASE_DIR}/dependency/ant
	fi 
	mv ${ANT_PACKAGE} ant
	sudo cp -r ant /opt/
	sudo echo "export ANT_HOME=/opt/ant" >> "/etc/profile"
	sudo echo "export PATH=\$PATH:\$ANT_HOME/bin" >> "/etc/profile"
	source /etc/profile

	echo "============================= finish installing ant ==================================="
}

#install jdk
function install_hadoop(){
	echo "=========================== start installing hadoop ====================================="
	
	check_hadoop	

	cd "${BASE_DIR}" 
	tar xzf ${HADOOP_TAR_PACKAGE} 
	
	if [ $? -ne 0 ] ; then
        echo "Fail to decompress ${HADOOP_TAR_PACKAGE}"
        exit 1
    fi

	if [ -d "${BASE_DIR}/current" ]; then
		sudo rm -rf ${BASE_DIR}/current
	fi 

	mv ${HADOOP_PACKAGE} current
	sudo mkdir -p /opt/hadoop
	sudo cp -r current /opt/hadoop
	sudo echo "export HADOOP_HOME=/opt/hadoop/current" >> "/etc/profile"
	sudo echo "export PATH=\$PATH:\$HADOOP_HOME/bin" >> "/etc/profile"
	source /etc/profile

	sudo mv /etc/hosts /etc/hosts-backup
	sudo cp "${BASE_DIR}/hosts" /etc/

	sudo echo "export HADOOP_CONF_DIR=/etc/hadoop/conf" >> "/etc/profile"
	source /etc/profile
	sudo mkdir -p /etc/hadoop
	sudo cp -r "${BASE_DIR}/conf" /etc/hadoop/
	
	sudo chmod 777 -R /opt/hadoop
	echo "============================= finish installing hadoop ==================================="
}

#install jdk
function install_lzo(){
	echo "=========================== start installing lzo ====================================="
	
	check_lzo	

	cd "${BASE_DIR}/dependency" 
	tar xzf ${LZO_TAR_PACKAGE} 
	
	if [ $? -ne 0 ] ; then
        echo "Fail to decompress ${LZO_TAR_PACKAGE}"
        exit 1
    fi

	cd "${LZO_PACKAGE}"
	./configure --enable-shared
	make
	sudo make install

	move_lib64so

	echo "============================= finish installing lzo ==================================="
}

function install_hadoop_lzo_dependency(){
	echo "============================= start installing hadoop-lzo-dependency =================="
	cd "${BASE_DIR}/dependency/${HADOOP_LZO_DEPENDENCY_PACKAGE}"
	if [ ${OS_BIT} == "64" ]; then
		rpm -ivh lzo-2.04-1.el5.rf.x86_64.rpm
		rpm -ivh lzo-devel-2.04-1.el5.rf.x86_64.rpm
	elif [ ${OS_BIT} == "32"]; then
		rpm -ivh lzo-2.04-1.el5.rf.i386.rpm
		rpm -ivh lzo-devel-2.04-1.el5.rf.i386.rpm
	fi

	echo "============================ finish installing hadoop-lzo-dependeny ==================="
}

function install_hadoop_lzo(){
	echo "=========================== start installing hadoop-lzo ================================"
	
	check_hadoop_lzo
	install_hadoop_lzo_dependency

	if [ !$ANT_HOME ]; then
		install_ant
	fi
	
	cd "${BASE_DIR}/dependency/${HADOOP_LZO_PACKAGE}" 
	ant compile-native tar

	if [ $? -ne 0 ] ; then
        echo "Fail to install hadoop-lzo"
        exit 1
    fi

	cp build/hadoop-lzo-0.4.15.jar "${HADOOP_HOME}/lib/"
	tar -cBf - -C build/native . | tar -xBvf - -C "${HADOOP_HOME}/lib/native"  

	echo "============================= finish installing hadoop-lzo ============================="
}


function move_lib64so(){
	echo "================================  start moving necessary .so file ========================"

	if [ ${OS_BIT} == "64" ]; then
		# move lzo.so
		if [ ! -f '/usr/lib64/liblzo2.so' ]; then
			if [ ! -f '/usr/local/lib/liblzo2.so' ]; then
				echo "ERROR:lzo is not installed correctly"
				exit 1
			else
				sudo cp  /usr/local/lib/liblzo* /usr/lib64/
			fi
		fi
	
	elif [ ${OS_BIT} == "32" ]; then
		# move lzo.so
		if [ ! -f '/usr/lib/liblzo2.so' ]; then
			if [ ! -f '/usr/local/lib/liblzo2.so' ]; then
				echo "ERROR:lzo is not installed correctly"
				exit 1
			else
				sudo cp  /usr/local/lib/liblzo* /usr/lib/
			fi
		fi
	fi
	
	if [ $? -ne 0 ] ; then
        echo "Fail to move necessary .so file"
        exit 1
    fi
	
	echo "================================   finish moving necessary .so file ================================"
}

function move_hadoop_lzo_build(){
	echo "================================ start moving hadoop-lzo/build ====================================="
	cd "${BASE_DIR}/dependency/${HADOOP_LZO_BUILD_PACKAGE}"
	cp build/hadoop-lzo-0.4.15.jar "${HADOOP_HOME}/lib/"
	tar -cBf - -C build/native . | tar -xBvf - -C "${HADOOP_HOME}/lib/native"
	echo "================================ finish moving hadoop-lzo/build ==================================="
}


# install all
function install_all(){
	install_jdk
	install_ant
	install_hadoop
	install_lzo

	if [ $1 == 'no-hadoop-lzo' ]; then
		move_hadoop_lzo_build
	else
		install_hadoop_lzo
	fi
}

function clean(){
	if [ -d "${BASE_DIR}/dependency/${JDK_PACKAGE}" ]; then
		rm -rf "${BASE_DIR}/dependency/${JDK_PACKAGE}"
	fi

	if [ -d "${BASE_DIR}/${HADOOP_PACKAGE}" ]; then
		rm -rf "${BASE_DIR}/${HADOOP_PACKAGE}"
	fi

	if [ -d "${BASE_DIR}/dependency/${ANT_PACKAGE}" ]; then
		rm -rf "${BASE_DIR}/dependency/${ANT_PACKAGE}"
	fi

	if [ -d "${BASE_DIR}/dependency/${LZO_PACKAGE}" ]; then
		rm -rf "${BASE_DIR}/dependency/${LZO_PACKAGE}"
	fi
}


INSTALL_JDK=false
INSTALL_ANT=false
INSTALL_HADOOP=false
INSTALL_LZO=false
INSTALL_HADOOP_LZO=false
INSTALL=false
INSTALL_NO_HADOOP_LZO=false
CLEAN=false

while [ -n "$1" ]; do
case $1 in
	-help) 
		help;
		shift 1;;
	-install_jdk) 
		INSTALL_JDK=true;
		shift 1;;
	-install_ant) 
		INSTALL_ANT=true;
		shift 1;;
	-install_hadoop) 
		INSTALL_HADOOP=true;
		shift 1;;
	-install_lzo) 
		INSTALL_LZO=true;
		shift 1;;
	-install_hadoop_lzo)
		INSTALL_HADOOP_LZO=true;
		shift 1;;
	-install) 
		INSTALL=true;
		shift 1;;
	-install_no_hadoop_lzo) 
		INSTALL_NO_HADOOP_LZO=true;
		shift 1;;
	-clean) 
		CLEAN=true;
		shift 1;;
	*) 
		echo "error:no such option $1. -help for help";
		exit 1;;
esac
done


# install jdk
if [ "$INSTALL_JDK" = true ]; then
	install_jdk
fi
# install ant
if [ "$INSTALL_ANT" = true ]; then
	install_ant
fi
# install hadoop
if [ "$INSTALL_HADOOP" = true ]; then
	install_hadoop
fi
# install lzo
if [ "$INSTALL_LZO" = true ]; then
	install_lzo
fi
# install hadoop-lzo
if [ "$INSTALL_HADOOP_LZO" = true ]; then
	install_hadoop_lzo
fi
# install all
if [ "$INSTALL" = true ]; then
	install_all
fi
# install all but without hadoop-lzo
if [ "$INSTALL_NO_HADOOP_LZO" = true ]; then
	install_all 'no-hadoop-lzo'
fi
# clean
if [ "$CLEAN" = true ]; then
	clean
fi


