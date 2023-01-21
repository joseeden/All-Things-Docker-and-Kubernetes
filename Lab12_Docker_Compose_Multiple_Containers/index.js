// Import express and redis library
const express = require('express');
const redis = require('redis');
// const process = require('process');

// Creates instance of the express application
// Setup connection to Redis server
const app = express();
const client = redis.createClient({
  host:  'redis-server',
  port: 6379
});

// Initializes the number of visits to zero at the start
client.set('visits', 0);

// App handler
// Gets the number of visits and update visit counter
app.get('/', (req, res) => {
  // process.exit(0);
  client.get('visits', (err, visits) => {
    res.send('Number of visits is ' + visits);
    client.set('visits', parseInt(visits) + 1);
  });
});

// If application is launched successfully,
// it'll show the "Listening..." message
app.listen(8081, () => {
  console.log('Listening on port 4001');
}); 