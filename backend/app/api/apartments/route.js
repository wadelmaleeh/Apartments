const { NextResponse } = require('next/server');
const pool = require('../../../lib/db');
const { v4: uuidv4 } = require('uuid');

export async function GET() {
  try {
    const result = await pool.query('SELECT * FROM apartments ORDER BY created_at DESC');
    return NextResponse.json(result.rows);
  } catch (e) {
    return NextResponse.json({ error: e.message }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    const id = uuidv4();
    const now = new Date().toISOString();
    const { name, description } = await request.json();
    const result = await pool.query(
      'INSERT INTO apartments (id, name, description, created_at, updated_at) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [id, name, description || '', now, now]
    );
    return NextResponse.json(result.rows[0], { status: 201 });
  } catch (e) {
    return NextResponse.json({ error: e.message }, { status: 500 });
  }
}
