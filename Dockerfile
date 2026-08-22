FROM tomcat:10.1.57-jre21-temurin-noble

RUN rm -rf /usr/local/tomcat/webapps/*

COPY nexus-download/employee-webapp.war /usr/local/tomcat/webapps/employee-webapp.war

EXPOSE 8080
