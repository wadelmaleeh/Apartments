const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(cors());
app.use(express.json());

const pool = new Pool({
  connectionString: 'postgresql://neondb_owner:npg_JVeE9MmP6cyw@ep-quiet-scene-atd68osz-pooler.c-9.us-east-1.aws.neon.tech/neondb?sslmode=require',
  ssl: { rejectUnauthorized: false }
});

const USERNAME = 'ahmedalgadi526';
const PASSWORD = 'ahmed12493526';

async function initDB() {
  const client = await pool.connect();
  try {
    await client.query(`
      CREATE TABLE IF NOT EXISTS apartments (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    `);
    await client.query(`
      CREATE TABLE IF NOT EXISTS rentals (
        id TEXT PRIMARY KEY,
        apartment_id TEXT NOT NULL REFERENCES apartments(id) ON DELETE CASCADE,
        rental_type TEXT NOT NULL,
        amount REAL NOT NULL,
        days INTEGER DEFAULT 1,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    `);
    await client.query(`
      CREATE TABLE IF NOT EXISTS expenses (
        id TEXT PRIMARY KEY,
        apartment_id TEXT NOT NULL REFERENCES apartments(id) ON DELETE CASCADE,
        expense_type TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    `);
    
    // Migration: Add days column to rentals if it doesn't exist
    await client.query(`
      ALTER TABLE rentals ADD COLUMN IF NOT EXISTS days INTEGER DEFAULT 1
    `);
    
    console.log('Database initialized');
  } finally {
    client.release();
  }
}

// Auth
app.post('/api/login', (req, res) => {
  const { username, password } = req.body;
  if (username === USERNAME && password === PASSWORD) {
    res.json({ success: true, token: 'authenticated' });
  } else {
    res.status(401).json({ success: false, message: 'Invalid credentials' });
  }
});

// Apartments
app.get('/api/apartments', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM apartments ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/apartments/:id', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM apartments WHERE id = $1', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Not found' });
    res.json(result.rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/apartments', async (req, res) => {
  try {
    const id = uuidv4();
    const now = new Date().toISOString();
    const { name, description } = req.body;
    const result = await pool.query(
      'INSERT INTO apartments (id, name, description, created_at, updated_at) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [id, name, description || '', now, now]
    );
    res.status(201).json(result.rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/api/apartments/:id', async (req, res) => {
  try {
    const { name, description } = req.body;
    const now = new Date().toISOString();
    const result = await pool.query(
      'UPDATE apartments SET name=$1, description=$2, updated_at=$3 WHERE id=$4 RETURNING *',
      [name, description, now, req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Not found' });
    res.json(result.rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete('/api/apartments/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM apartments WHERE id = $1', [req.params.id]);
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Rentals
app.get('/api/rentals', async (req, res) => {
  try {
    const { apartment_id } = req.query;
    let query = 'SELECT * FROM rentals';
    let params = [];
    if (apartment_id) {
      query += ' WHERE apartment_id = $1';
      params.push(apartment_id);
    }
    query += ' ORDER BY date DESC';
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/rentals', async (req, res) => {
  try {
    const id = uuidv4();
    const now = new Date().toISOString();
    const { apartment_id, rental_type, amount, days = 1, date } = req.body;
    const result = await pool.query(
      'INSERT INTO rentals (id, apartment_id, rental_type, amount, days, date, created_at) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *',
      [id, apartment_id, rental_type, amount, days, date, now]
    );
    res.status(201).json(result.rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/api/rentals/:id', async (req, res) => {
  try {
    const { apartment_id, rental_type, amount, days = 1, date } = req.body;
    const result = await pool.query(
      'UPDATE rentals SET apartment_id=$1, rental_type=$2, amount=$3, days=$4, date=$5 WHERE id=$6 RETURNING *',
      [apartment_id, rental_type, amount, days, date, req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Not found' });
    res.json(result.rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete('/api/rentals/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM rentals WHERE id = $1', [req.params.id]);
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Expenses
app.get('/api/expenses', async (req, res) => {
  try {
    const { apartment_id } = req.query;
    let query = 'SELECT * FROM expenses';
    let params = [];
    if (apartment_id) {
      query += ' WHERE apartment_id = $1';
      params.push(apartment_id);
    }
    query += ' ORDER BY date DESC';
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/expenses', async (req, res) => {
  try {
    const id = uuidv4();
    const now = new Date().toISOString();
    const { apartment_id, expense_type, amount, date } = req.body;
    const result = await pool.query(
      'INSERT INTO expenses (id, apartment_id, expense_type, amount, date, created_at) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [id, apartment_id, expense_type, amount, date, now]
    );
    res.status(201).json(result.rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/api/expenses/:id', async (req, res) => {
  try {
    const { apartment_id, expense_type, amount, date } = req.body;
    const result = await pool.query(
      'UPDATE expenses SET apartment_id=$1, expense_type=$2, amount=$3, date=$4 WHERE id=$5 RETURNING *',
      [apartment_id, expense_type, amount, date, req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Not found' });
    res.json(result.rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete('/api/expenses/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM expenses WHERE id = $1', [req.params.id]);
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

const PORT = process.env.PORT || 3000;
initDB().then(() => {
  app.listen(PORT, () => console.log(`API running on port ${PORT}`));
}).catch(console.error);
