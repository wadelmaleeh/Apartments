export default function Home() {
  return (
    <div style={{ padding: '40px', fontFamily: 'sans-serif', textAlign: 'center' }}>
      <h1>Apartment Rental API</h1>
      <p>Backend is running.</p>
      <ul style={{ listStyle: 'none', padding: 0 }}>
        <li><code>POST /api/login</code></li>
        <li><code>GET /api/apartments</code></li>
        <li><code>POST /api/apartments</code></li>
        <li><code>GET /api/apartments/[id]</code></li>
        <li><code>PUT /api/apartments/[id]</code></li>
        <li><code>DELETE /api/apartments/[id]</code></li>
        <li><code>GET /api/rentals</code></li>
        <li><code>POST /api/rentals</code></li>
        <li><code>PUT /api/rentals/[id]</code></li>
        <li><code>DELETE /api/rentals/[id]</code></li>
        <li><code>GET /api/expenses</code></li>
        <li><code>POST /api/expenses</code></li>
        <li><code>PUT /api/expenses/[id]</code></li>
        <li><code>DELETE /api/expenses/[id]</code></li>
      </ul>
    </div>
  );
}
