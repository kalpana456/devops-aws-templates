#!/bin/bash
#set up jetty as a service 

#init
echo "RUNNING: setupJettyService.sh"

#needs to be run with elevated access
if [ "$EUID" -ne 0 ]
then
    echo "this script needs sudo access to continue installation"
    echo "current user: " $(whoami)
    exit
fi

#helper functions
function getMyIP() {
    instanceIp=$(curl -s ipinfo.io/ip)
}

#TODO: set up proper CWD 
cd /tmp/

#make sure java is installed
#yum -y install java-1.7.0-openjdk wget

#download the latest version of jetty for your java version
wget http://download.eclipse.org/jetty/9.2.15.v20160210/dist/jetty-distribution-9.2.15.v20160210.tar.gz

#extract jetty in tmp folder
tar zxvf jetty-distribution-9.2.15.v20160210.tar.gz

#move jetty binaries to /usr/share/
mv jetty-distribution-9.2.15.v20160210 /usr/share/

#create symbolic link to jetty folder in /opt/
ln -s /usr/share/jetty-distribution-9.2.15.v20160210 /opt/jetty

#create jetty user
useradd -m jetty

#set permissions for /opt/jetty
chown -R jetty:jetty /opt/jetty/

#create symbolic link for jetty startup script inside init.d
ln -s /opt/jetty/bin/jetty.sh /etc/init.d/jetty

#add script to init.d service
chkconfig --add jetty

#set auto start levels
chkconfig --level 345 jetty on

getMyIP

#set up jetty config file
echo "JETTY_HOME=/opt/jetty
JETTY_USER=jetty
JETTY_PORT=8080
JETTY_HOST=${instanceIp}
JETTY_LOGS=/opt/jetty/logs/" > /etc/default/jetty

echo "ALL DONE: setupJettyService.sh"
exit 0
