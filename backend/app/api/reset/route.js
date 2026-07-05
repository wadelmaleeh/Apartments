const { NextResponse } = require('next/server');
const pool = require('../../../lib/db');

export async function POST() {
  try {
    const client = await pool.connect();
    try {
      await client.query('DELETE FROM expenses');
      await client.query('DELETE FROM rentals');
      await client.query('DELETE FROM apartments');
      await client.query('ALTER SEQUENCE IF EXISTS expenses_id_seq RESTART WITH 1');
      await client.query('ALTER SEQUENCE IF EXISTS rentals_id_seq RESTART WITH 1');
      await client.query('ALTER SEQUENCE IF EXISTS apartments_id_seq RESTART WITH 1');
      return NextResponse.json({ success: true, message: 'All data cleared' });
    } finally {
      client.release();
    }
  } catch (e) {
    return NextResponse.json({ error: e.message }, { status: 500 });
  }
}
