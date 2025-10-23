const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/hello', (req, res) => {
  res.send('Hello, World!');
});
app.get('/', (req, res) => {
  res.send('Welcome to the homepage!');
});
app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
