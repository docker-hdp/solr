#!/bin/bash

sudo sed -i s/INFO/DEBUG/ $HADOOP_CONF_DIR/log4j.properties

# Get hostname/ip config
MY_HOSTNAME=`hostname`
HDFS_NAMENODE_HOSTNAME=$MY_HOSTNAME

echo "Current Hostname:" $MY_HOSTNAME
echo "Current Namenode Hostname:" $HDFS_NAMENODE_HOSTNAME
echo "Current Secondary Namenode Hostname:" $HDFS_SECONDARYNAMENODE_HOSTNAME

echo "Configure core-site.xml"
# From run environment
sudo sed -i s~HDFS_NAMENODE_HOSTNAME~$HDFS_NAMENODE_HOSTNAME~g $HADOOP_CONF_DIR/core-site.xml
sudo sed -i s~HDFS_SECONDARYNAMENODE_HOSTNAME~$HDFS_SECONDARYNAMENODE_HOSTNAME~g $HADOOP_CONF_DIR/core-site.xml

echo "Configure hdfs-site.xml"
# From run environment
sudo sed -i s~HDFS_NAMENODE_HOSTNAME~$HDFS_NAMENODE_HOSTNAME~g $HADOOP_CONF_DIR/hdfs-site.xml
sudo sed -i s~HDFS_SECONDARYNAMENODE_HOSTNAME~$HDFS_SECONDARYNAMENODE_HOSTNAME~g $HADOOP_CONF_DIR/hdfs-site.xml

ZOO_CONNECT_STR=''
for ZOO_SERVER in ${!ZOO_SERVER*}
do
	if [[ ${#ZOO_CONNECT_STR} < 1 ]]; then
		ZOO_CONNECT_STR="${!ZOO_SERVER}"
	else
		ZOO_CONNECT_STR="$ZOO_CONNECT_STR,${!ZOO_SERVER}"
	fi
done

echo "Starting solr:"
bin/solr start -c
   -z $ZOO_CONNECT_STR
   -Dsolr.directoryFactory=HdfsDirectoryFactory
   -Dsolr.lock.type=hdfs
   -Dsolr.hdfs.home=hdfs://$HDFS_NAMENODE_HOSTNAME:8020/user/solr