const http = require('http');
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/html');
  res.end('<h1>Hello from CI/CD Pipeline!</h1><p>Version: 1.0</p>');
});

server.listen(port, () => {
  console.log(`Server running at http://localhost:${port}/`);
});