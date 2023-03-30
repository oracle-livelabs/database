<?php
 $con = mysqli_connect('30.0...','admin','Welcome#123','airportdb');
?>
<!DOCTYPE html>
<html lang="en-US">
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
body {
  font-family: Arial;
  color: white;
}

.split {
  height: 100%;
  width: 50%;
  position: fixed;
  z-index: 1;
  top: 0;
  overflow-x: hidden;
  padding-top: 20px;
}

.left {
  left: 0;
  background-color: #111;
}

.right {
  right: 0;
  background-color: red;
}

.centered {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
}

.centered img {
  width: 150px;
  border-radius: 50%;
}
</style>
</head>
<body>

<h1>My Web Page</h1>
<div class="split left">
<div class="centered">
<div id="piechart"></div>

<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>

<script type="text/javascript">
// Load google charts
google.charts.load('current', {'packages':['corechart']});
google.charts.setOnLoadCallback(drawChart);

// Draw the chart and set the chart values
function drawChart() {
 var data = google.visualization.arrayToDataTable([

 ['lastname','count_bookings'],
 <?php
                   	$query = "SELECT lastname, COUNT(booking.passenger_id) AS count_bookings
				  FROM passenger, booking
				  WHERE booking.passenger_id = passenger.passenger_id
				  GROUP BY lastname 
				  ORDER by count_bookings desc
				  LIMIT 8;";

                         $exec = mysqli_query($con,$query);
                         while($row = mysqli_fetch_array($exec)){

                         echo "['".$row['lastname']."',".$row['count_bookings']."],";
                         }
                         ?> 
 
 ]);

  // Optional; add a title and set the width and height of the chart
  var options = {'title':'Top 8 bookers by lastname', 
                'width':550, 'height':400};

  // Display the chart inside the <div> element with id="piechart"
  var chart = new google.visualization.PieChart(document.getElementById('piechart'));
  chart.draw(data, options);
}
</script>
</div>
</div>
<div class="split right">
<div class="centered">
<?php

$link = mysqli_connect('30.0...','admin','Welcome#123','airportdb');
#require_once "config_2.php";
$query = "SELECT booking_id, firstname,lastname, price FROM passenger, booking
 WHERE booking.passenger_id = passenger.passenger_id
 ORDER by booking_id desc LIMIT 10;";
if ($stmt = $link->prepare($query)) {
   $stmt->execute();
   $stmt->bind_result($booking_id,$firstname,$lastname,$price);
echo "<h2>10 Latest Booking entries and updates</h2>";

   echo "<table>";
    echo "<tr>";
    echo "<th>Booking_id</th>";
    echo "<th>Firstname</th>";
    echo "<th>Lastname</th>";
    echo "<th>Price</th>";
echo "</tr>";

while ($stmt->fetch()) {
    echo "<tr>";
       echo "<td>" . $booking_id ."</td>";
       echo "<td>" . $firstname ."</td>";
       echo "<td>" . $lastname . "</td>";
       echo "<td>" . $price . "</td>";
    echo "</tr>";
 }

$stmt->close();
}
?>
</div>
</div>
</body>
</html>
