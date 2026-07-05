const { NextResponse } = require('next/server');
const pool = require('../../../../lib/db');

export async function GET(request, { params }) {
  try {
    const { id } = await params;
    const result = await pool.query('SELECT * FROM apartments WHERE id = $1', [id]);
    if (result.rows.length === 0) {
      return NextResponse.json({ error: 'Not found' }, { status: 404 });
    }
    return NextResponse.json(result.rows[0]);
  } catch (e) {
    return NextResponse.json({ error: e.message }, { status: 500 });
  }
}

export async function PUT(request, { params }) {
  try {
    const { id } = await params;
    const { name, description } = await request.json();
    const now = new Date().toISOString();
    const result = await pool.query(
      'UPDATE apartments SET name=$1, description=$2, updated_at=$3 WHERE id=$4 RETURNING *',
      [name, description, now, id]
    );
    if (result.rows.length === 0) {
      return NextResponse.json({ error: 'Not found' }, { status: 404 });
    }
    return NextResponse.json(result.rows[0]);
  } catch (e) {
    return NextResponse.json({ error: e.message }, { status: 500 });
  }
}

export async function DELETE(request, { params }) {
  try {
    const { id } = await params;
    await pool.query('DELETE FROM apartments WHERE id = $1', [id]);
    return NextResponse.json({ success: true });
  } catch (e) {
    return NextResponse.json({ error: e.message }, { status: 500 });
  }
}
