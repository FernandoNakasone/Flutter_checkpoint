/// Contrato abstrato para consulta externa de feriados.
/// Em produção, este serviço consultaria uma API externa de calendário governamental.
abstract class HolidayService {
  /// Retorna `true` se a data fornecida for um feriado ou evento tarifado, `false` caso contrário.
  Future<bool> isHoliday(DateTime date);
}

/// Implementação fake para uso na aplicação de demonstração.
/// Nas aulas e na prova, este serviço deve ser MOCKADO com Mockito.
class FakeHolidayService implements HolidayService {
  // Lista padrão de feriados (mês e dia)
  final Set<String> _knownHolidays = {
    '01-01', // Ano Novo
    '04-21', // Tiradentes
    '05-01', // Dia do Trabalho
    '09-07', // Independência
    '10-12', // N. Sra Aparecida
    '11-02', // Finados
    '11-15', // Proclamação da República
    '12-25', // Natal
  };

  final Duration simulatedDelay;

  FakeHolidayService({this.simulatedDelay = Duration.zero});

  @override
  Future<bool> isHoliday(DateTime date) async {
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }
    final key = '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _knownHolidays.contains(key);
  }
}
