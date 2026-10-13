class Reservation {
  final String id;
  final String plate;
  final DateTime startTime;
  final int hours;
  final double baseRatePerHour;
  final bool isHoliday;
  final double holidaySurcharge;
  final double durationDiscount;
  final double totalAmount;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.plate,
    required this.startTime,
    required this.hours,
    required this.baseRatePerHour,
    required this.isHoliday,
    required this.holidaySurcharge,
    required this.durationDiscount,
    required this.totalAmount,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Retorna o horário de término previsto da reserva.
  DateTime get endTime => startTime.add(Duration(hours: hours));
}
