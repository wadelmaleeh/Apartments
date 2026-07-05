const { NextResponse } = require('next/server');

const USERNAME = 'ahmedalgadi526';
const PASSWORD = 'ahmed12493526';

export async function POST(request) {
  const body = await request.json();
  const { username, password } = body;

  if (username === USERNAME && password === PASSWORD) {
    return NextResponse.json({ success: true, token: 'authenticated' });
  }

  return NextResponse.json(
    { success: false, message: 'Invalid credentials' },
    { status: 401 }
  );
}
