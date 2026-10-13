import '../models/exceptions.dart';
import '../models/reservation.dart';
import 'holiday_service.dart';

/// Resultado intermediário do cálculo detalhado de preços da reserva.
class PricingDetails {
  final double baseAmount;
  final double durationDiscount;
  final double holidaySurcharge;
  final double totalAmount;
  final bool isHoliday;

  const PricingDetails({
    required this.baseAmount,
    required this.durationDiscount,
    required this.holidaySurcharge,
    required this.totalAmount,
    required this.isHoliday,
  });
}

/// Gerenciador central de regras de negócio para reservas de vagas.
class ReservationManager {
  final HolidayService holidayService;
  final double baseHourlyRate;
  final DateTime Function() currentTimeProvider;

  final List<Reservation> _reservations = [];

  List<Reservation> get reservations => List.unmodifiable(_reservations);

  ReservationManager({
    required this.holidayService,
    this.baseHourlyRate = 10.0,
    DateTime Function()? currentTimeProvider,
  }) : currentTimeProvider = currentTimeProvider ?? DateTime.now;

  /// Valida a placa informada (deve ter 7 caracteres alfanuméricos).
  void validatePlate(String? plate) {
    if (plate == null) {
      throw const InvalidPlateException('A placa não pode ser nula.');
    }
    final cleanPlate = plate.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    if (cleanPlate.length != 7) {
      throw const InvalidPlateException('A placa deve conter 7 caracteres alfanuméricos.');
    }
  }

  /// Valida a duração da reserva (mínimo 1 hora, máximo 24 horas).
  void validateDuration(int hours) {
    if (hours < 1 || hours > 24) {
      throw const InvalidDurationException('A reserva deve ter entre 1 e 24 horas de duração.');
    }
  }

  /// Valida se a data de início não está no passado.
  void validateStartTime(DateTime startTime) {
    final now = currentTimeProvider();
    // Tolerância de 1 minuto para evitar falso-positivo em testes com timestamp próximo
    if (startTime.isBefore(now.subtract(const Duration(minutes: 1)))) {
      throw const InvalidReservationDateException('A data de início da reserva não pode ser no passado.');
    }
  }

  /// Realiza o cálculo dos valores e descontos da reserva.
  Future<PricingDetails> calculatePricing({
    required DateTime startTime,
    required int hours,
  }) async {
    validateDuration(hours);

    // 1. Valor base
    final baseAmount = hours * baseHourlyRate;

    // 2. Desconto por tempo de permanência:
    // >= 8 horas: 20%
    // >= 4 horas e < 8: 10%
    // < 4 horas: 0%
    double durationDiscount = 0.0;
    if (hours >= 8) {
      durationDiscount = baseAmount * 0.20;
    } else if (hours >= 4) {
      durationDiscount = baseAmount * 0.10;
    }

    // 3. Consulta de feriado via serviço externo (HolidayService)
    bool isHoliday = false;
    try {
      isHoliday = await holidayService.isHoliday(startTime);
    } catch (_) {
      // Fallback gracioso: caso o serviço externo falhe, assume false
      isHoliday = false;
    }

    // Se for feriado: acréscimo de 25% sobre o valor base
    final holidaySurcharge = isHoliday ? (baseAmount * 0.25) : 0.0;

    // Total final = Valor base - Desconto por duração + Acréscimo de feriado
    final rawTotal = (baseAmount - durationDiscount) + holidaySurcharge;
    final totalAmount = double.parse(rawTotal.clamp(0.0, double.infinity).toStringAsFixed(2));

    return PricingDetails(
      baseAmount: double.parse(baseAmount.toStringAsFixed(2)),
      durationDiscount: double.parse(durationDiscount.toStringAsFixed(2)),
      holidaySurcharge: double.parse(holidaySurcharge.toStringAsFixed(2)),
      totalAmount: totalAmount,
      isHoliday: isHoliday,
    );
  }

  /// Cria e confirma uma nova reserva.
  Future<Reservation> createReservation({
    required String plate,
    required DateTime startTime,
    required int hours,
  }) async {
    validatePlate(plate);
    validateStartTime(startTime);
    validateDuration(hours);

    final pricing = await calculatePricing(
      startTime: startTime,
      hours: hours,
    );

    final cleanPlate = plate.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    final reservation = Reservation(
      id: 'RES-${DateTime.now().millisecondsSinceEpoch}-${_reservations.length + 1}',
      plate: cleanPlate,
      startTime: startTime,
      hours: hours,
      baseRatePerHour: baseHourlyRate,
      isHoliday: pricing.isHoliday,
      holidaySurcharge: pricing.holidaySurcharge,
      durationDiscount: pricing.durationDiscount,
      totalAmount: pricing.totalAmount,
    );

    _reservations.add(reservation);
    return reservation;
  }

  /// Remove todas as reservas (útil para testes ou reinicialização).
  void clearReservations() {
    _reservations.clear();
  }
}
