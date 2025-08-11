const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.get('/', (req, res) => {
  res.send(`
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>Renewable Energy Web App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
      body { font-family: Arial, sans-serif; margin: 2rem; }
      code { background: #f4f4f4; padding: 2px 4px; }
    </style>
  </head>
  <body>
    <h1>Renewable Energy Web App</h1>
    <p>Frontend is running.</p>
    <ul>
      <li>API: <code>${process.env.REACT_APP_API_URL || 'http://localhost:3001'}</code></li>
      <li>Health: <code>/health</code></li>
    </ul>
  </body>
</html>
    `);
});

app.listen(port, () => {
  console.log(`Frontend listening on port ${port}`);
});
