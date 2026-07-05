const { NextResponse } = require('next/server');
const pool = require('../../../lib/db');

export async function GET(request) {
  try {
    // Check rentals table columns
    const columns = await pool.query(`
      SELECT column_name, data_type, column_default, is_nullable
      FROM information_schema.columns
      WHERE table_name = 'rentals'
      ORDER BY ordinal_position
    `);
    
    // Check if there's any data in rentals
    const rentalsCount = await pool.query('SELECT COUNT(*) FROM rentals');
    
    // Try a simple insert to see what fails
    const testId = 'test-' + Date.now();
    let testInsert = null;
    try {
      const result = await pool.query(
        'INSERT INTO rentals (id, apartment_id, rental_type, amount, days, date, created_at) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *',
        [testId, '00000000-0000-0000-0000-000000000000', 'monthly', 100, 1, new Date().toISOString(), new Date().toISOString()]
      );
      testInsert = { success: true, data: result.rows[0] };
      // Clean up
      await pool.query('DELETE FROM rentals WHERE id = $1', [testId]);
    } catch (insertError) {
      testInsert = { success: false, error: insertError.message };
    }
    
    return NextResponse.json({
      columns: columns.rows,
      rentalsCount: rentalsCount.rows[0].count,
      testInsert
    });
  } catch (e) {
    return NextResponse.json({ error: e.message, stack: e.stack }, { status: 500 });
  }
}
