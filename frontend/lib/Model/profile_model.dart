class Profile {
  final int id;
  final String profilePict;
  final String name;
  final String status;
  final String expDate;
  final int tradvoucher;
  final int tradPoint;
  final int targetRefProgress;
  final int targetRefValue;
  final String tradLevel;
  final String bonusRadarTradBulanIni;

  Profile({
    required this.id,
    required this.profilePict,
    required this.name,
    required this.status,
    required this.expDate,
    required this.tradvoucher,
    required this.tradPoint,
    required this.targetRefProgress,
    required this.targetRefValue,
    required this.tradLevel,
    required this.bonusRadarTradBulanIni,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      profilePict: json['profilePict'],
      name: json['name'],
      status: json['status'],
      expDate: json['expDate'],
      tradvoucher: json['tradvoucher'],
      tradPoint: json['tradPoint'],
      targetRefProgress: json['targetRefProgress'],
      targetRefValue: json['targetRefValue'],
      tradLevel: json['tradLevel'],
      bonusRadarTradBulanIni: json['bonusRadarTradBulanIni'],
    );
  }
}
