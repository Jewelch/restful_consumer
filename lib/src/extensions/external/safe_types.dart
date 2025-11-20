extension SafeInt on int? {
  int get safe => this ?? 0;
}

extension SafeString on String? {
  String get safe => this ?? "";
}

extension SafeBool on bool? {
  bool get safe => this ?? false;
}

extension SafeDouble on double? {
  double get safe => this ?? 0;
}

extension SafeDateTime on DateTime? {
  DateTime get safe => this ?? DateTime.now();
}

extension SafeNum on num? {
  num get safe => this ?? 0;
}

extension SafeList<T> on List<T>? {
  List<T> get safe => this ?? <T>[];
}

extension SafeMap<K, V> on Map<K, V>? {
  Map<K, V> get safe => this ?? <K, V>{};
}
