class ApiConfig {
  // Production URL (Vercel deployment)
  static const String productionUrl = 'https://apartments-sd.vercel.app';
  
  // Development URL (local server)
  static const String developmentUrl = 'http://localhost:3000';
  
  // Automatically use production URL for release builds, localhost for debug
  static const String baseUrl = bool.fromEnvironment('dart.vm.product')
      ? productionUrl
      : developmentUrl;
  
  static const Duration timeout = Duration(seconds: 30);
}
