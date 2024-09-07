enum Exposure {
  external,
  internal;

  String get indexStr => index.toString();

  factory Exposure.from({String? name, int? index}) {
    switch ((name ?? index?.toString())?.toLowerCase()) {
      case 'external':
        return Exposure.external;
      case 'internal':
        return Exposure.internal;
      case '0':
        return Exposure.external;
      case '1':
        return Exposure.internal;
      case 0:
        return Exposure.external;
      case 1:
        return Exposure.internal;
      case 'e':
        return Exposure.external;
      case 'i':
        return Exposure.internal;
      case 'public':
        return Exposure.external;
      case 'change':
        return Exposure.internal;
      default:
        return Exposure.external;
    }
  }
}
