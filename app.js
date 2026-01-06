const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send(`
    <html>
      <body style="font-family: Arial; text-align: center; padding: 50px;">
        <h1>🚀 Hello from CI/CD Pipeline!</h1>
        <p>Version: 1.0.0</p>
        <p>Build: ${process.env.BUILD_NUMBER || 'local'}</p>
        <p>Deployed via Jenkins + Docker + Kubernetes</p>
      </body>
    </html>
  `);
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', timestamp: new Date() });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`App listening on port ${port}`);
});