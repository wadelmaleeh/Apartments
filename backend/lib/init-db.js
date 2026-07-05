const pool = require('./db');

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
    
    // Migration: Add days column if it doesn't exist
    const checkColumn = await client.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'rentals' AND column_name = 'days'
    `);
    
    if (checkColumn.rows.length === 0) {
      await client.query(`
        ALTER TABLE rentals ADD COLUMN days INTEGER DEFAULT 1
      `);
      console.log('Added days column to rentals table');
    }
    
    console.log('Database initialized');
  } finally {
    client.release();
  }
}

module.exports = initDB;
