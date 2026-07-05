const { NextResponse } = require('next/server');
const pool = require('../../../../lib/db');

export async function PUT(request, { params }) {
  try {
    const { id } = await params;
    const body = await request.json();
    console.log(`PUT /api/rentals/${id} - Received body:`, body);
    
    const { apartment_id, rental_type, amount, days, date } = body;
    const result = await pool.query(
      'UPDATE rentals SET apartment_id=$1, rental_type=$2, amount=$3, days=$4, date=$5 WHERE id=$6 RETURNING *',
      [apartment_id, rental_type, amount, days || 1, date, id]
    );
    
    if (result.rows.length === 0) {
      console.log(`PUT /api/rentals/${id} - Not found in database`);
      return NextResponse.json({ error: 'Not found' }, { status: 404 });
    }
    
    console.log(`PUT /api/rentals/${id} - Success:`, result.rows[0]);
    return NextResponse.json(result.rows[0]);
  } catch (e) {
    console.error(`PUT /api/rentals/${id} - Error:`, e.message);
    return NextResponse.json({ error: e.message }, { status: 500 });
  }
}

export async function DELETE(request, { params }) {
  try {
    const { id } = await params;
    await pool.query('DELETE FROM rentals WHERE id = $1', [id]);
    return NextResponse.json({ success: true });
  } catch (e) {
    return NextResponse.json({ error: e.message }, { status: 500 });
  }
}
