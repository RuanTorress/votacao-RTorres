enum AppEnvironment { development, production }

class Env {
  static const AppEnvironment current = AppEnvironment.production;

  static String get apiUrl {
    switch (current) {
      case AppEnvironment.production:
        return 'http://localhost:3000';
      case AppEnvironment.development:
      return 'http://192.168.1.8:3000'; 
    }
  }

  static String get apiUrl2 {
    switch (current) {
      case AppEnvironment.production:
        return 'http://localhost:3001';
      case AppEnvironment.development:
      return 'http://192.168.1.8:3000'; 
    }
  }

  // Adicione aqui outras configurações se quiser
  static bool get isProd => current == AppEnvironment.production;
  static bool get isDev => current == AppEnvironment.development;
}