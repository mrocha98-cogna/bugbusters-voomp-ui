class PendingSteps {
  bool hasPersonalData;
  bool hasIdentityValidated;
  bool hasBusinessData;
  bool hasProducts;
  bool hasSales;
  int totalSteps;
  int completedSteps;
  double completionPercentage;
  bool hasWhatsappNotification = false;
  bool hasBankingData;

  PendingSteps({
    required this.hasPersonalData,
    required this.hasIdentityValidated,
    required this.hasBusinessData,
    required this.hasProducts,
    required this.hasSales,
    required this.totalSteps,
    required this.completedSteps,
    required this.completionPercentage,
    required this.hasWhatsappNotification,
    required this.hasBankingData
  });

  factory PendingSteps.fromJson(Map<String, dynamic> json) {
    return PendingSteps(
      hasPersonalData: json['hasPersonalData'],
      hasIdentityValidated: json['hasIdentityValidated'],
      hasBusinessData: json['hasBusinessData'],
      hasProducts: json['hasProducts'],
      hasSales: json['hasSales'],
      totalSteps: int.tryParse(json['totalSteps'].toString()) ?? 0,
      completedSteps: int.tryParse(json['completedSteps'].toString()) ?? 0,
      completionPercentage: double.tryParse(json['completionPercentage'].toString()) ?? 0,
      hasWhatsappNotification: false,
      hasBankingData: json['hasBankingData'],
    );
  }
}
