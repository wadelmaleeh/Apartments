const { NextResponse } = require('next/server');
const pool = require('../../../lib/db');
const { v4: uuidv4 } = require('uuid');

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const apartmentId = searchParams.get('apartment_id');

    let query = 'SELECT * FROM expenses';
    let params = [];
    if (apartmentId) {
      query += ' WHERE apartment_id = $1';
      params.push(apartmentId);
    }
    query += ' ORDER BY date DESC';

    const result = await pool.query(query, params);
    return NextResponse.json(result.rows);
  } catch (e) {
    return NextResponse.json({ error: e.message }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    const id = uuidv4();
    const now = new Date().toISOString();
    const { apartment_id, expense_type, amount, date } = await request.json();
    const result = await pool.query(
      'INSERT INTO expenses (id, apartment_id, expense_type, amount, date, created_at) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [id, apartment_id, expense_type, amount, date, now]
    );
    return NextResponse.json(result.rows[0], { status: 201 });
  } catch (e) {
    return NextResponse.json({ error: e.message }, { status: 500 });
  }
}
