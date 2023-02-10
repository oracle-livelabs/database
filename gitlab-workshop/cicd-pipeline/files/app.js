const http = require('http');
const os = require('os');
const dns = require('dns');

console.log("Web Application starting and listening on 8080...");

var handler = function(request, response) {
  console.log("Received request from " + request.connection.remoteAddress);
  response.writeHead(200);
  response.end( "Container ID: " + os.hostname() + "\n"
    + "OS Platform is: " + os.platform() +  "\n"
    + "Host Architecture is: " + os.machine() + "\n"
    + "OS Release is: "+ os.release() + "\n"
    + "Load Averages (1, 5, and 15 minute): " + os.loadavg() + "\n"
    + "Host Endianness ('BE' for big endian and 'LE' for little endian): " + os.endianness() + "\n"
    + "Host Total Memory: " + os.totalmem()/1000/1000/1000 + "\n"
    + "Free Memory: " + os.freemem()/1000/1000/1000 + "\n"
    + "Host Uptime in Seconds: "+ os.uptime() + "\n");
};
var www = http.createServer(handler);
www.listen(8080);