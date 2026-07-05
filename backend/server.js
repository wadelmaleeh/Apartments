const { createServer } = require('http');
const next = require('next');
const initDB = require('./lib/init-db');

const dev = process.env.NODE_ENV !== 'production';
const port = process.env.PORT || 3000;

const app = next({ dev });
const handle = app.getRequestHandler();

app.prepare().then(async () => {
  try {
    await initDB();
    console.log('Database initialized');
  } catch (e) {
    console.error('DB init failed:', e.message);
  }

  createServer((req, res) => handle(req, res)).listen(port, () => {
    console.log(`> Server running on http://localhost:${port}`);
  });
});
