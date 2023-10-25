<?php
 $con = mysqli_connect('10.0.1.183','admin','Welcome#123','airportdb');
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
                'width':650, 'height':400};

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

$link = mysqli_connect('10.0.1.183','admin','Welcome#123','airportdb');
#require_once "config_2.php";
$query = "SELECT satisfaction_v2, Customer_Type, Type_of_Travel, count(*) Departure_Delay_in_Minutes
FROM airportdb.passenger_survey where Departure_Delay_in_Minutes > 120 group by Customer_Type,Type_of_Travel,satisfaction_v2
order by satisfaction_v2 desc,Customer_Type, Type_of_Travel;";
if ($stmt = $link->prepare($query)) {
   $stmt->execute();
   $stmt->bind_result($sastifaction,$customer_type, $travel_type,$departure_delay);
echo "<h2>Customer response based on 120 second Delayed flight</h2>";

   echo "<table>";
    echo "<tr>";
    echo "<th>sastifaction</th>";
    echo "<th>customer_type</th>";
    echo "<th>travel_type</th>";
    echo "<th>departure_delay</th>";
echo "</tr>";

while ($stmt->fetch()) {
    echo "<tr>";
       echo "<td>" . $sastifaction ."</td>";
       echo "<td>" . $customer_type ."</td>";
       echo "<td>" . $travel_type ."</td>";
       echo "<td>" . $departure_delay ."</td>";
    echo "</tr>";
 }

$stmt->close();
}
?>
</div>
</div>
<!-- Code injected by live-server -->
<script>
	// <![CDATA[  <-- For SVG support
	if ('WebSocket' in window) {
		(function () {
			function refreshCSS() {
				var sheets = [].slice.call(document.getElementsByTagName("link"));
				var head = document.getElementsByTagName("head")[0];
				for (var i = 0; i < sheets.length; ++i) {
					var elem = sheets[i];
					var parent = elem.parentElement || head;
					parent.removeChild(elem);
					var rel = elem.rel;
					if (elem.href && typeof rel != "string" || rel.length == 0 || rel.toLowerCase() == "stylesheet") {
						var url = elem.href.replace(/(&|\?)_cacheOverride=\d+/, '');
						elem.href = url + (url.indexOf('?') >= 0 ? '&' : '?') + '_cacheOverride=' + (new Date().valueOf());
					}
					parent.appendChild(elem);
				}
			}
			var protocol = window.location.protocol === 'http:' ? 'ws://' : 'wss://';
			var address = protocol + window.location.host + window.location.pathname + '/ws';
			var socket = new WebSocket(address);
			socket.onmessage = function (msg) {
				if (msg.data == 'reload') window.location.reload();
				else if (msg.data == 'refreshcss') refreshCSS();
			};
			if (sessionStorage && !sessionStorage.getItem('IsThisFirstTime_Log_From_LiveServer')) {
				console.log('Live reload enabled.');
				sessionStorage.setItem('IsThisFirstTime_Log_From_LiveServer', true);
			}
		})();
	}
	else {
		console.error('Upgrade your browser. This Browser is NOT supported WebSocket for Live-Reloading.');
	}
	// ]]>
</script>
<!-- Code injected by live-server -->
<script>
	// <![CDATA[  <-- For SVG support
	if ('WebSocket' in window) {
		(function () {
			function refreshCSS() {
				var sheets = [].slice.call(document.getElementsByTagName("link"));
				var head = document.getElementsByTagName("head")[0];
				for (var i = 0; i < sheets.length; ++i) {
					var elem = sheets[i];
					var parent = elem.parentElement || head;
					parent.removeChild(elem);
					var rel = elem.rel;
					if (elem.href && typeof rel != "string" || rel.length == 0 || rel.toLowerCase() == "stylesheet") {
						var url = elem.href.replace(/(&|\?)_cacheOverride=\d+/, '');
						elem.href = url + (url.indexOf('?') >= 0 ? '&' : '?') + '_cacheOverride=' + (new Date().valueOf());
					}
					parent.appendChild(elem);
				}
			}
			var protocol = window.location.protocol === 'http:' ? 'ws://' : 'wss://';
			var address = protocol + window.location.host + window.location.pathname + '/ws';
			var socket = new WebSocket(address);
			socket.onmessage = function (msg) {
				if (msg.data == 'reload') window.location.reload();
				else if (msg.data == 'refreshcss') refreshCSS();
			};
			if (sessionStorage && !sessionStorage.getItem('IsThisFirstTime_Log_From_LiveServer')) {
				console.log('Live reload enabled.');
				sessionStorage.setItem('IsThisFirstTime_Log_From_LiveServer', true);
			}
		})();
	}
	else {
		console.error('Upgrade your browser. This Browser is NOT supported WebSocket for Live-Reloading.');
	}
	// ]]>
</script>
</body>
</html>
