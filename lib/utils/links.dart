abstract class Links {
  static Links? _instance;
  static Links get instance {
    return _instance ??= Links._();
  }

  factory Links._() {
    return Links.instance;
  }

  String get server {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'prod');
    switch (flavor) {
      case 'dev': return devUrl;
      case 'staging': return stagingUrl;
      default: return productionUrl;
    }
  }

  String get productionUrl;
  String get stagingUrl;
  String get devUrl;
}