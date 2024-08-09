class RegisterModel {
  // ignore: non_constant_identifier_names
  int? id;
  String UserID;
  String name;
  String phone;
  String email;
  String alamat;
  String noReferal;
  String password;
  String pin;

  RegisterModel({
    // ignore: non_constant_identifier_names
    required this.id,
    required this.UserID,
    required this.name,
    required this.phone,
    required this.email,
    required this.alamat,
    required this.password,
    required this.pin,
    required this.noReferal,
  });

  // Fungsi untuk mengubah dari JSON ke model
  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      id: json['id'],
      UserID: json['userid'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      alamat: json['alamat'],
      password: json['password'],
      pin: json['pin'],
      noReferal: json['referralCode'],
    );
  }

  // Fungsi untuk mengubah dari model ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userid': UserID,
      'name': name,
      'phone':phone,
      'email': email,
      'alamat': alamat,
      'password': password,
      'pin': pin,
      'referralCode': noReferal,
    };
  }
}
