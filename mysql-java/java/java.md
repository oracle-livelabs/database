# Create a simple Java program and run it in Docker

## Introduction

In this lab, we will create a small java program that gets data from MySQL and run it in Docker.

Estimated Time: 10 minutes

### About Java
Java is a high-level, class-based, object-oriented programming language that is designed to have as few implementation dependencies as possible. It is a general-purpose programming language intended to let programmers write once, run anywhere (WORA), meaning that compiled Java code can run on all platforms that support Java without the need to recompile.

### Objectives

In this lab, you will:
* Create a Java program that gets data from MySQL 
* Create a docker container
* Run it

### Prerequisites 

This lab assumes you have:
* Followed the previous labs

## Task 1: Check the files

Check the Dockerfile 

```bash
<copy>cd oke_mysql_java_101/demo1
cat Dockerfile</copy>
```
```
FROM openjdk:11
COPY . /app
COPY lib /app/lib
WORKDIR /app
RUN javac QueryDB.java
CMD ["java", "-classpath",  "lib/*:.", "QueryDB", "jdbc:mysql://127.0.0.1/db1", "root", "Welcome1!"] 
```
Note: in the previous labs, we have forwarded the MySQL 3306 to localhost(127.0.0.1):3306. 

Check the java program

```
<copy>cat QueryDB.java</copy>
```
```
import java.sql.*;
public class QueryDB {
  public static void main(String[] args) {
    try {
      Connection cnx = DriverManager.getConnection(args[0], args[1], args[2]);
      Statement stmt = cnx.createStatement();
      ResultSet rs = stmt.executeQuery("SELECT id, name FROM t1");
      while (rs.next()) {
        System.out.println(rs.getInt(1) + " " + rs.getString(2));
      }
      cnx.close();
    } catch (SQLException e) {
      e.printStackTrace();
    }
  }
} 
```

## Task 2: Build and test

To build and run the docker container, do this:

```bash
<copy>bin/build.sh
docker run --net=host querydb</copy>
```
Comment: The "-net=host" is needed because MySQL is accessed on 127.0.0.1.

You will see:

```
1 DOLPHIN
2 TIGER
3 PENGUIN
4 LION
```

To check what the container contains:

```bash
<copy>docker run -it --entrypoint /bin/bash querydb
ls
exit</copy>
```

## Acknowledgements
* Marc Gueury - Application Development EMEA
* Stuart Davey - MySQL EMEA
* Mario Beck - MySQL EMEA
* Olivier Dasini - MySQL EMEA
* Last Updated <Feb 2022>
