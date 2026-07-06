class ApiConfig {
  // Production URL (Vercel deployment) - Used for ALL builds now
  static const String productionUrl = 'https://apartments-sd.vercel.app';
  
  // Development URL (local server) - Optional, commented out
  // static const String developmentUrl = 'http://localhost:3000';
  
  // Always use production URL (Vercel deployment)
  static const String baseUrl = productionUrl;
  
  static const Duration timeout = Duration(seconds: 30);
  
  // Note: If you want to use localhost for development:
  // 1. Uncomment developmentUrl above
  // 2. Change baseUrl to: developmentUrl
  // 3. Make sure your local backend is running on port 3000
}
