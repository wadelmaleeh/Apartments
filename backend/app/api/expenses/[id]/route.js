const { NextResponse } = require('next/server');
const pool = require('../../../../lib/db');

export async function PUT(request, { params }) {
  try {
    const { id } = await params;
    const { apartment_id, expense_type, amount, date } = await request.json();
    const result = await pool.query(
      'UPDATE expenses SET apartment_id=$1, expense_type=$2, amount=$3, date=$4 WHERE id=$5 RETURNING *',
      [apartment_id, expense_type, amount, date, id]
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
    await pool.query('DELETE FROM expenses WHERE id = $1', [id]);
    return NextResponse.json({ success: true });
  } catch (e) {
    return NextResponse.json({ error: e.message }, { status: 500 });
  }
}
