export const metadata = {
  title: 'Apartment Rental API',
  description: 'Backend API for Apartment Rental Management',
};

export default function RootLayout({ children }) {
  return (
    <html lang="ar" dir="rtl">
      <body>{children}</body>
    </html>
  );
}
