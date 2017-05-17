FROM docker-hdp/centos-base:1.0
MAINTAINER Arturo Bayo <arturo.bayo@gmail.com>
USER root

# Adding hdp-solr repository to YUM Repository
COPY files/hdp-solr.repo /etc/yum.repos.d/.
#COPY files/hdp-solr-rpm-key /tmp/.
RUN yum makecache

# Configure environment variables
ENV HADOOP_CONF_DIR /etc/hadoop/conf
ENV HDFS_USER hdfs

# Install software
RUN yum clean all
RUN yum -y install lucidworks-hdpsearch

# Copy configuration files
RUN mkdir -p $HADOOP_CONF_DIR
COPY tmp/conf/ $HADOOP_CONF_DIR/
RUN chown -R $HDFS_USER:$HADOOP_GROUP $HADOOP_CONF_DIR/../ && chmod -R 755 $HADOOP_CONF_DIR/../

RUN echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile
RUN echo "export HADOOP_CONF_DIR=$HADOOP_CONF_DIR" >> /etc/profile
RUN echo "export PATH=$PATH:$JAVA_HOME:$HADOOP_CONF_DIR" >> /etc/profile

# Expose ports
#EXPOSE $ZOO_PORT

# Deploy entrypoint
COPY files/entrypoint.sh /opt/run/00_solr.sh
RUN chmod +x /opt/run/00_solr.sh

# Determine running user
#USER solr

# Execute entrypoint
ENTRYPOINT ["/opt/bin/run_all.sh"]