// server.js
const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 3000;

// Menyajikan file statis dari folder 'public'
app.use(express.static(path.join(__dirname, 'public')));

// Menjalankan server
app.listen(port, () => {
  console.log(`Aplikasi undangan berjalan di http://undangan.com:${port}`);
});