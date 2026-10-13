/// Exceção base do domínio de reservas.
abstract class ReservationException implements Exception {
  final String message;
  const ReservationException(this.message);

  @override
  String toString() => message;
}

/// Lançada quando a placa do veículo é inválida ou vazia.
class InvalidPlateException extends ReservationException {
  const InvalidPlateException([super.message = 'Placa do veículo inválida. A placa deve ter 7 caracteres alfanuméricos.']);
}

/// Lançada quando a quantidade de horas solicitada for menor que 1 ou maior que o limite (24h).
class InvalidDurationException extends ReservationException {
  const InvalidDurationException([super.message = 'A duração da reserva deve ser de pelo menos 1 hora e no máximo 24 horas.']);
}

/// Lançada quando a data informada para o início da reserva estiver no passado.
class InvalidReservationDateException extends ReservationException {
  const InvalidReservationDateException([super.message = 'A data/hora da reserva não pode ser no passado.']);
}
