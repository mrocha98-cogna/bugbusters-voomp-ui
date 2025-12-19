class SalesStatistics {
  double todayRevenue;
  double last30DaysRevenue;
  SalesFunnel salesFunnel;

  SalesStatistics({required this.todayRevenue, required this.last30DaysRevenue, required this.salesFunnel});

  factory SalesStatistics.fromJson(Map<String, dynamic> json) {
    return SalesStatistics(
      todayRevenue: double.tryParse(json['todayRevenue'].toString()) ?? 0,
      last30DaysRevenue: double.tryParse(json['last30DaysRevenue'].toString()) ?? 0,
      salesFunnel: SalesFunnel.fromJson(json['salesFunnel']),
    );
  }
}

class SalesFunnel{
  int totalVisits;
  int totalLeads;
  int totalSales;
  ConversionMetrics conversionMetrics;

  SalesFunnel({required this.totalVisits, required this.totalLeads, required this.totalSales, required this.conversionMetrics});

  factory SalesFunnel.fromJson(Map<String, dynamic> json) {
    return SalesFunnel(
      totalVisits: int.tryParse(json['totalVisits'].toString()) ?? 0,
      totalLeads: int.tryParse(json['totalLeads'].toString()) ?? 0,
      totalSales: int.tryParse(json['totalSales'].toString()) ?? 0,
      conversionMetrics: ConversionMetrics.fromJson(json['conversionMetrics']),
    );
  }
}

class ConversionMetrics{
  double visitsToLeads;
  double leadsToSales;
  double overallConversion;

  ConversionMetrics({required this.visitsToLeads, required this.leadsToSales, required this.overallConversion});

  factory ConversionMetrics.fromJson(Map<String, dynamic> json) {
    return ConversionMetrics(
      visitsToLeads: double.tryParse(json['visitsToLeads'].toString()) ?? 0,
      leadsToSales: double.tryParse(json['leadsToSales'].toString()) ?? 0,
      overallConversion: double.tryParse(json['overallConversion'].toString()) ?? 0,
    );
  }
}