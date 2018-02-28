FROM 		tomcat:8.5.9-jre8

MAINTAINER 	DFS-OPS

RUN rm -rf /usr/local/tomcat/webapps
RUN mkdir -p /usr/local/tomcat/webapps
ADD build/*.war /usr/local/tomcat/webapps/
