class ModelKategori {
  final String key;
  final String value;

  ModelKategori({
    required this.key,
    required this.value,
  });

  factory ModelKategori.fromJson(Map<String, dynamic> json) {
    return ModelKategori(
      key: json['key'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }
}
