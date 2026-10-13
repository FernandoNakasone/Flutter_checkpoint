import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/exceptions.dart';
import '../../services/reservation_manager.dart';

class ReservationScreen extends StatefulWidget {
  final ReservationManager manager;

  const ReservationScreen({super.key, required this.manager});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _plateController = TextEditingController(text: 'BRA2E19');
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  int _selectedHours = 2;

  PricingDetails? _currentPricing;
  bool _isLoadingPricing = false;

  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _refreshPricing();
  }

  Future<void> _refreshPricing() async {
    setState(() {
      _isLoadingPricing = true;
    });

    try {
      final pricing = await widget.manager.calculatePricing(
        startTime: _selectedDate,
        hours: _selectedHours,
      );
      setState(() {
        _currentPricing = pricing;
      });
    } catch (_) {
      setState(() {
        _currentPricing = null;
      });
    } finally {
      setState(() {
        _isLoadingPricing = false;
      });
    }
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
        await _refreshPricing();
      }
    }
  }

  Future<void> _confirmReservation() async {
    try {
      await widget.manager.createReservation(
        plate: _plateController.text.trim(),
        startTime: _selectedDate,
        hours: _selectedHours,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva realizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {});
      }
    } on ReservationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpotReserve - Reserva de Vagas'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Formulário de Reserva
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nova Reserva',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Campo de Placa
                    TextField(
                      controller: _plateController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Placa do Veículo (7 caracteres)',
                        hintText: 'Ex: BRA2E19',
                        prefixIcon: Icon(Icons.directions_car),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Seletor de Data e Hora
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickDateTime,
                            icon: const Icon(Icons.calendar_month),
                            label: Text(_dateFormat.format(_selectedDate)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quantidade de Horas
                    Row(
                      children: [
                        const Text(
                          'Duração:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          onPressed: _selectedHours > 1
                              ? () {
                                  setState(() => _selectedHours--);
                                  _refreshPricing();
                                }
                              : null,
                          icon: const Icon(Icons.remove),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '$_selectedHours ${_selectedHours == 1 ? "hora" : "horas"}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: _selectedHours < 24
                              ? () {
                                  setState(() => _selectedHours++);
                                  _refreshPricing();
                                }
                              : null,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Detalhamento do Preço
                    if (_isLoadingPricing)
                      const Center(child: CircularProgressIndicator())
                    else if (_currentPricing != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            _pricingRow('Tarifa Base:', _currencyFormat.format(_currentPricing!.baseAmount)),
                            if (_currentPricing!.durationDiscount > 0)
                              _pricingRow(
                                'Desconto por Duração:',
                                '- ${_currencyFormat.format(_currentPricing!.durationDiscount)}',
                                color: Colors.green.shade700,
                              ),
                            if (_currentPricing!.isHoliday)
                              _pricingRow(
                                'Acréscimo de Feriado (+25%):',
                                '+ ${_currencyFormat.format(_currentPricing!.holidaySurcharge)}',
                                color: Colors.deepOrange,
                              ),
                            const Divider(),
                            _pricingRow(
                              'Total da Reserva:',
                              _currencyFormat.format(_currentPricing!.totalAmount),
                              isBold: true,
                              fontSize: 18,
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _confirmReservation,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Confirmar Reserva', style: TextStyle(fontSize: 16)),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Lista de Reservas
            const Text(
              'Reservas Registradas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (widget.manager.reservations.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('Nenhuma reserva registrada ainda.'),
                ),
              )
            else
              ...widget.manager.reservations.reversed.map((res) {
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.directions_car),
                    ),
                    title: Text(
                      'Placa: ${res.plate} (${res.hours}h)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Início: ${_dateFormat.format(res.startTime)}'),
                        Text('Valor Total: ${_currencyFormat.format(res.totalAmount)}'),
                      ],
                    ),
                    trailing: const Chip(
                      label: Text('Confirmada'),
                      backgroundColor: Colors.greenAccent,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _pricingRow(String label, String value, {bool isBold = false, double fontSize = 14, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
