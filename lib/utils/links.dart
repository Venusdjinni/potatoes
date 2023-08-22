abstract class Links {
  static Links? _instance;
  static Links get instance {
    if (_instance == null) {
      throw UnimplementedError('Links is not globally defined yet');
    }
    return _instance!;
  }

  static set instance(Links value) {
    _instance ??= value;
  }

  const Links();

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