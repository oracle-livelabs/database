# Accelerate complex queries using MySQL HeatWave

## Introduction

In this lab, you will execute a few more long running queries on MySQL HeatWave to appreciate the performance gain using MySQL HeatWave
What we will do is to execute the queries against MySQL and MySQL HeatWave to compare the performance, we will use the magic switch **use&#95;secondary&#95;engine** to specify where are we going to send the queries to. If **use&#95;secondary&#95;engine** is enabled, the query will be sent to MySQL HeatWave, otherwise, the query will be sent to MySQL

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* Experience how to accelerate long running queries using MySQL HeatWave engine

### Prerequisites (Optional)

This lab assumes you have:

* You have an Oracle account
* You have enough privileges to use OCI
* You have one Compute instance having <a href="https://dev.mysql.com/doc/mysql-shell/8.0/en/mysql-shell-install.html" target="\_blank">**MySQL Shell**</a> installed on it

## Task 1: Execute query 1

  Query 1: Find per-country average age of passengers from Switzerland, Italy and France

	```
	<copy>
	mysqlsh --user=admin --password=<password> --host=<mysql_private_ip_address> --port=3306 --sql
	</copy>
	```
	```
	<copy>
	USE airportdb;
	SET SESSION use_secondary_engine=off;
	</copy>
	```

	```
	<copy>
	SELECT
	airline.airlinename,
	AVG(datediff(departure,birthdate)/365.25) as avg_age,
	count(*) as nb_people
	FROM
	booking, flight, airline, passengerdetails
	WHERE
	booking.flight_id=flight.flight_id AND
	airline.airline_id=flight.airline_id AND
	booking.passenger_id=passengerdetails.passenger_id AND
	country IN ("SWITZERLAND", "FRANCE", "ITALY")
	GROUP BY
	airline.airlinename
	ORDER BY
	airline.airlinename, avg_age
	LIMIT 10;
	</copy>
	```

  This query will take about 13s to execute. Record the response time for comparison.
  Re-execute the query against MySQL HeatWave

	```
	<copy>
	SET SESSION use_secondary_engine=on;
	</copy>
	```
	```
	<copy>
	SELECT
	airline.airlinename,
	AVG(datediff(departure,birthdate)/365.25) as avg_age,
	count(*) as nb_people
	FROM
	booking, flight, airline, passengerdetails
	WHERE
	booking.flight_id=flight.flight_id AND
	airline.airline_id=flight.airline_id AND
	booking.passenger_id=passengerdetails.passenger_id AND
	country IN ("SWITZERLAND", "FRANCE", "ITALY")
	GROUP BY
	airline.airlinename
	ORDER BY
	airline.airlinename, avg_age
	LIMIT 10;
	</copy>
	```

  This query will now take less than 1s to execute, record the response time for comparison.

## Task 2: Execute query 2

Query 2: Find top 10 airlines selling the most tickets for planes taking off from US airports. Run Pricing Summary Report Query:

	```
	<copy>
	mysqlsh --user=admin --password=<password> --host=<mysql_private_ip_address> --port=3306 --sql
	</copy>
	```
	```
	<copy>
	SET SESSION use_secondary_engine=off;
	</copy>
	```
	```
	SELECT
	airline.airlinename,
	SUM(booking.price) as price_tickets,
	count(*) as nb_tickets
	FROM
	booking, flight, airline, airport_geo
	WHERE
	booking.flight_id=flight.flight_id AND
	airline.airline_id=flight.airline_id AND
	flight.from=airport_geo.airport_id AND
	airport_geo.country = "UNITED STATES"
	GROUP BY
	airline.airlinename
	ORDER BY
	nb_tickets desc, airline.airlinename
	LIMIT 10;
	```

  This query will take about 24s to execute. Record the response time for comparison.
Re-execute the query against MySQL HeatWave

	```
	<copy>
	SET SESSION use_secondary_engine=on;
	</copy>
	```
	```
	<copy>
	SELECT
	airline.airlinename,
	SUM(booking.price) as price_tickets,
	count(*) as nb_tickets
	FROM
	booking, flight, airline, airport_geo
	WHERE
	booking.flight_id=flight.flight_id AND
	airline.airline_id=flight.airline_id AND
	flight.from=airport_geo.airport_id AND
	airport_geo.country = "UNITED STATES"
	GROUP BY
	airline.airlinename
	ORDER BY
	nb_tickets desc, airline.airlinename
	LIMIT 10;
	</copy>
	```

  This query will now take less than 1s to execute, record the response time for comparison.

## Task 3: Execute query 3

Query 3: Find the number of bookings that Neil Armstrong and Buzz Aldrin made for a price of > $400.00

	```
	<copy>
	mysqlsh --user=admin --password=<password> --host=<mysql_private_ip_address> --port=3306 --sql
	</copy>
	```
	```
	<copy>
	USE airportdb;
	SET SESSION use_secondary_engine=off;
	</copy>
	```
	```
	<copy>
	SELECT
	firstname,
	lastname,
	COUNT(booking.passenger_id) AS count_bookings
	FROM
	passenger,
	booking
	WHERE
	booking.passenger_id = passenger.passenger_id
		AND passenger.lastname = 'Aldrin'
		OR (passenger.firstname = 'Neil'
		AND passenger.lastname = 'Armstrong')
		AND booking.price > 400.00
	GROUP BY firstname,lastname;
	</copy>
	```

  This query will take about 40s to execute, record the response time for comparison.

  Re-execute the query against MySQL HeatWave

	```
	<copy>
	SET SESSION use_secondary_engine=on;
	</copy>
	```
	```
	<copy>
	SELECT
	firstname,
	lastname,
	COUNT(booking.passenger_id) AS count_bookings
	FROM
	passenger,
	booking
	WHERE
	booking.passenger_id = passenger.passenger_id
		AND passenger.lastname = 'Aldrin'
		OR (passenger.firstname = 'Neil'
		AND passenger.lastname = 'Armstrong')
		AND booking.price > 400.00
	GROUP BY firstname , lastname;
	</copy>
	```

  This query will now take less than 4s to execute, record the response time for comparison.

  With HeatWave enabled, you can accelerate long running queries without any change to your existing SQL queries!

## Acknowledgements

* **Author**
	* Rayes Huang, Cloud Solution Architect, OCI APAC
	* Ryan Kuan, MySQL Cloud Engineer, MySQL APAC

* **Contributors**

	* Perside Foster, MySQL Solution Engineering
	* Howie Owi, OCI Solution Specialist, OCI APAC

* **Last Updated By/Date** - Ryan Kuan, March 2022
