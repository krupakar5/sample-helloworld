FROM frolvlad/alpine-java
ADD target/SpringBootRestApiExample-1.0.0.jar SpringBootRestApiExample-1.0.0.jar
RUN sh -c 'touch /SpringBootRestApiExample-1.0.0.jar'
ENTRYPOINT ["java","-jar","/SpringBootRestApiExample-1.0.0.jar"]
EXPOSE 8080
